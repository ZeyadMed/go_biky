import 'package:go_biky/core/bloc/genaric_pagination.dart';
import 'package:go_biky/core/http/either.dart';
import 'package:go_biky/core/http/failure.dart';
import 'package:go_biky/feature/notifications/data/datasource/notifications_data_source.dart';
import 'package:go_biky/feature/notifications/data/model/notification_model.dart';
import 'package:go_biky/feature/notifications/data/model/notifications_page.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/unread_notifications_cubit.dart';

/// صندوق الإشعارات بالصفحات من الأحدث للأقدم، والصفحة اللي بعدها بتيجي لما
/// السكرول يوصل للآخر. القراءة والتأكيد بيبانوا على طول، ولو الطلب فشل
/// الإشعار بيرجع زي ما كان
class NotificationsCubit extends GenericPaginationCubit<NotificationModel> {
  NotificationsCubit(this._dataSource, this._unreadCubit) {
    initPagination();
  }

  final NotificationsDataSource _dataSource;
  final UnreadNotificationsCubit _unreadCubit;

  @override
  Future<Either<Failure, NotificationsPage>> loadPage(int page) =>
      _dataSource.getNotifications(page: page);

  /// الإشعار اللي جاي من push ممكن مايكونش في القايمة لسه، فالطلب
  /// بيتبعت برضه
  Future<void> markAsRead(String id) async {
    final item = _find(id);
    if (item != null && item.isRead) return;
    if (item != null) _replace(item.copyWith(readAtUtc: _now));

    final result = await _dataSource.markAsRead(id);
    if (isClosed) return;
    if (result.isError && item != null) _replace(item);
    await _unreadCubit.getUnreadCount();
  }

  Future<void> markAllAsRead() async {
    final previous = state.items;
    final now = _now;
    emit(
      state.copyWith(
        items: [
          for (final item in previous)
            item.isRead ? item : item.copyWith(readAtUtc: now),
        ],
      ),
    );

    final result = await _dataSource.markAllAsRead();
    if (isClosed) return;
    if (result.isError) emit(state.copyWith(items: previous));
    await _unreadCubit.getUnreadCount();
  }

  /// "تم" على إشعار مهم. بترجع رسالة الخطأ لو فشل عشان الشاشة تعرضها،
  /// والزرار بيرجع يبان تاني
  Future<String?> acknowledge(String id) async {
    final item = _find(id);
    if (item != null) {
      final now = _now;
      _replace(item.copyWith(readAtUtc: now, acknowledgedAtUtc: now));
    }

    final result = await _dataSource.acknowledge(id);
    if (isClosed) return null;
    final error = result.fold<String?>((failure) => failure.message, (_) => null);
    if (error != null && item != null) _replace(item);
    await _unreadCubit.getUnreadCount();
    return error;
  }

  DateTime get _now => DateTime.now().toUtc();

  NotificationModel? _find(String id) {
    for (final item in state.items) {
      if (item.id == id) return item;
    }
    return null;
  }

  void _replace(NotificationModel updated) => emit(
    state.copyWith(
      items: [
        for (final item in state.items) item.id == updated.id ? updated : item,
      ],
    ),
  );
}
