import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/bloc/genaric_pagination.dart';
import 'package:go_biky/core/http/either.dart';
import 'package:go_biky/core/http/failure.dart';

class _Page implements PaginatedPage<int> {
  _Page(this.items, {required int page, required int pages})
    : pagination = (currentPage: page, pagesCount: pages, perPage: 0, total: 0);

  @override
  final List<int> items;

  @override
  final PageInfo pagination;
}

/// كل `loadPage` بيستنى لحد ما التست يرد عليه، عشان نتحكم في ترتيب النتايج
class _Cubit extends GenericPaginationCubit<int> {
  final pending = <(int, Completer<Either<Failure, PaginatedPage<int>>>)>[];

  @override
  Future<Either<Failure, PaginatedPage<int>>> loadPage(int page) {
    final completer = Completer<Either<Failure, PaginatedPage<int>>>();
    pending.add((page, completer));
    return completer.future;
  }

  void respond(int page, Either<Failure, PaginatedPage<int>> result) {
    final index = pending.indexWhere((p) => p.$1 == page);
    pending.removeAt(index).$2.complete(result);
  }
}

void main() {
  late _Cubit cubit;

  setUp(() => cubit = _Cubit());
  tearDown(() => cubit.close());

  test('appends pages and stops at the last one', () async {
    final first = cubit.fetch(page: 1);
    cubit.respond(1, Right(_Page([1, 2], page: 1, pages: 2)));
    await first;

    expect(cubit.state.items, [1, 2]);
    expect(cubit.state.hasReachedMax, isFalse);

    final second = cubit.fetch(page: cubit.state.page);
    cubit.respond(2, Right(_Page([3], page: 2, pages: 2)));
    await second;

    expect(cubit.state.items, [1, 2, 3]);
    expect(cubit.state.hasReachedMax, isTrue);

    await cubit.fetch(page: cubit.state.page);
    expect(cubit.pending, isEmpty);
  });

  test('a refresh discards an older load-more result', () async {
    final first = cubit.fetch(page: 1);
    cubit.respond(1, Right(_Page([1, 2], page: 1, pages: 3)));
    await first;

    final loadMore = cubit.fetch(page: 2);
    final refresh = cubit.refresh();
    cubit.respond(1, Right(_Page([10, 11], page: 1, pages: 3)));
    await refresh;
    cubit.respond(2, Right(_Page([3, 4], page: 2, pages: 3)));
    await loadMore;

    expect(cubit.state.items, [10, 11]);
    expect(cubit.state.page, 2);
  });

  test('a failed load-more keeps the items and clears on retry', () async {
    final first = cubit.fetch(page: 1);
    cubit.respond(1, Right(_Page([1, 2], page: 1, pages: 3)));
    await first;

    final failed = cubit.fetch(page: 2);
    cubit.respond(2, Left(NetworkFailure(message: 'offline')));
    await failed;

    expect(cubit.state.isLoadingMoreFauilare, isTrue);
    expect(cubit.state.items, [1, 2]);

    final retry = cubit.fetch(page: 2);
    cubit.respond(2, Right(_Page([3], page: 2, pages: 3)));
    await retry;

    expect(cubit.state.items, [1, 2, 3]);
    expect(cubit.state.errorMessage, isNull);
  });

  test('closing while a page loads does not throw', () async {
    final first = cubit.fetch(page: 1);
    await cubit.close();
    cubit.respond(1, Right(_Page([1], page: 1, pages: 1)));

    await expectLater(first, completes);
  });
}
