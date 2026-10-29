import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/http/either.dart';
import 'package:go_biky/core/http/failure.dart';

/// A ScrollController variant that tolerates being attached to multiple
/// scrollables. Flutter's default [ScrollController] asserts when the same
/// controller is attached to more than one [ScrollPosition]. In codebases
/// where a shared cubit exposes a controller used by multiple screens (for
/// example when screens are kept alive by an `IndexedStack`), that can
/// trigger an assertion.
///
/// This implementation tries the normal attach via `super.attach`. If the
/// framework throws (e.g. an assertion), the controller falls back to
/// listening directly to the provided [ScrollPosition] and forwards metrics
/// via [onPositionScroll]. This allows the cubit to react to scroll events
/// without forcing a single controller instance to be uniquely attached.
class _SafeScrollController extends ScrollController {
  _SafeScrollController({this.onPositionScroll});

  final void Function(ScrollPosition pos)? onPositionScroll;
  final Map<ScrollPosition, VoidCallback> _positionListeners = {};

  @override
  void attach(ScrollPosition position) {
    try {
      super.attach(position);
    } catch (_) {
      // Fallback: add a direct listener to the ScrollPosition so we still
      // receive scroll callbacks even if we cannot attach to the controller
      // positions set (which is where framework would normally register).
      if (!_positionListeners.containsKey(position)) {
        void listener() {
          try {
            onPositionScroll?.call(position);
          } catch (_) {}
        }

        position.addListener(listener);
        _positionListeners[position] = listener;
      }
    }
  }

  @override
  void detach(ScrollPosition position) {
    // Remove any fallback listener we added.
    final l = _positionListeners.remove(position);
    if (l != null) {
      try {
        position.removeListener(l);
      } catch (_) {}
    }
    try {
      super.detach(position);
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final kv in Map<ScrollPosition, VoidCallback>.from(
      _positionListeners,
    ).entries) {
      try {
        kv.key.removeListener(kv.value);
      } catch (_) {}
    }
    _positionListeners.clear();
    try {
      super.dispose();
    } catch (_) {}
  }
}

/// عدد الصفحات ورقم الصفحة زي ما الباك بيرجعهم
typedef PageInfo = ({int currentPage, int pagesCount, int perPage, int total});

/// صفحة من API بالصفحات. موديل الصفحة بيعمل implements عشان الـ cubit يقرا
/// العناصر وعدد الصفحات بأنواعهم، وأي تغيير في الأسماء يطلع وقت الـ compile
/// مش عند المستخدم
abstract interface class PaginatedPage<T> {
  List<T> get items;
  PageInfo get pagination;
}

abstract class GenericPaginationCubit<T> extends Cubit<BaseState<T>> {
  GenericPaginationCubit() : super(BaseState<T>());

  /// A scroll controller that is tolerant to being attached to multiple
  /// scrollables. In the common case the framework will attach the
  /// controller normally and the cubit's listener will be invoked; in
  /// the rare case where attaching to multiple scrollables would throw
  /// an assertion, the controller falls back to listening directly to
  /// the individual [ScrollPosition]s and forwards metrics to the
  /// provided callback.
  late final ScrollController scrollController = _SafeScrollController(
    onPositionScroll: _maybeLoadMore,
  );

  /// كل `fetch(page: 1)` بيبدأ جيل جديد، فنتيجة صفحة قديمة توصل بعد
  /// الـ refresh بتتجاهل بدل ما تتلزق على اللستة الجديدة وتكرر عناصر
  int _generation = 0;

  // استدعيها من initState للـ Widget أو من مكان التهيئة
  void initPagination() {
    scrollController.addListener(_onScroll);
  }

  // لو عايز تُنضّف (close) لما الـ cubit يتقفل
  @override
  Future<void> close() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    return super.close();
  }

  void _onScroll() {
    // لو الـ controller متركب على أكتر من scrollable مالوش position واحدة،
    // والـ position نفسها بتنادي _maybeLoadMore
    if (scrollController.positions.length != 1) return;
    _maybeLoadMore(scrollController.position);
  }

  void _maybeLoadMore(ScrollPosition pos) {
    if (pos.pixels >= pos.maxScrollExtent &&
        !state.hasReachedMax &&
        !state.isFailure &&
        !state.isLoading &&
        !state.isLoadingMore &&
        !state.isLoadingMoreFauilare) {
      fetch(page: state.page);
    }
  }

  // دالة عامة للاستدعاء من الـ UI لو عايز تعيد التحميل
  Future<void> refresh() async => fetch(page: 1);

  /// Apply a filter (metadata) to the pagination and reload from the start.
  ///
  /// - `metadata`: arbitrary key/value map that the subclass `loadPage`
  ///   implementation can read from `state.metadata` to apply filters.
  /// - `reset`: when true (default) the current items/page will be reset
  ///   and fetching will start from page 1.
  Future<void> applyFilter({
    Map<String, dynamic>? metadata,
    bool reset = true,
  }) async {
    if (isClosed) return;
    // Merge provided metadata with existing metadata so filters accumulate
    final Map<String, dynamic> newMeta = {
      ...state.metadata,
      ...(metadata ?? {}),
    };

    if (reset) {
      // Emit a loading state and reset pagination so fetch(page:1)
      // will replace items. Include metadata so it is preserved.
      emit(
        state.copyWith(
          status: Status.loading,
          metadata: newMeta,
          page: 1,
          items: [],
          hasReachedMax: false,
        ),
      );
    } else {
      // Update metadata and set loading, without clearing UI immediately.
      emit(state.copyWith(status: Status.loading, metadata: newMeta));
    }

    await fetch(page: 1);
  }

  /// Remove the `date` filter (if present), reset pagination and fetch
  /// the first page. Useful when you want to clear date filtering and
  /// reload data from scratch.
  Future<void> fetchFirstPageClearDate() async {
    if (isClosed) return;
    final Map<String, dynamic> newMeta = {...state.metadata}..remove('date');

    // Reset pagination state and emit loading so UI shows the loading state.
    emit(
      state.copyWith(
        status: Status.loading,
        metadata: newMeta,
        page: 1,
        items: [],
        hasReachedMax: false,
      ),
    );

    await fetch(page: 1);
  }

  // الدالة العامة اللي تدير الفيتش
  Future<void> fetch({required int page}) async {
    // الـ cubit مشترك وبيتقفل عند الخروج، والشاشة ممكن تكون لسه شايلاه
    if (isClosed) return;
    if (state.hasReachedMax && page != 1) return;

    if (page == 1) _generation++;
    final generation = _generation;

    emit(
      state.copyWith(
        status: page == 1 ? Status.loading : Status.isLoadingMore,
        clearError: true,
      ),
    );

    final result = await loadPage(page);
    if (isClosed || generation != _generation) return;

    result.fold(
      (failure) => _handleFailure(page, failure),
      (data) => _handleSuccess(page, data),
    );
  }

  void _handleFailure(int page, Failure failure) {
    emit(
      state.copyWith(
        status: page == 1 ? Status.failure : Status.isLoadingMoreFauilare,
        errorMessage: failure.message,
        failure: failure,
      ),
    );
  }

  void _handleSuccess(int page, PaginatedPage<T> result) {
    final info = result.pagination;

    // لو الباك مابعتش عدد الصفحات بنحسبه من الإجمالي، ولو مفيش ده كمان
    // الصفحة الفاضية هي الآخر
    var pagesCount = info.pagesCount;
    if (pagesCount <= 0 && info.perPage > 0 && info.total > 0) {
      pagesCount = (info.total / info.perPage).ceil();
    }
    // بالصفحة اللي طلبناها مش اللي راجعة، عشان لو الباك مابعتهاش
    final reachedMax = pagesCount > 0
        ? page >= pagesCount
        : result.items.isEmpty;

    emit(
      state.copyWith(
        status: Status.success,
        items: page == 1 ? result.items : [...state.items, ...result.items],
        page: page + 1,
        hasReachedMax: reachedMax,
      ),
    );
  }

  // الـ subclass لازم ي implement الدالة دي
  Future<Either<Failure, PaginatedPage<T>>> loadPage(int page);
}
