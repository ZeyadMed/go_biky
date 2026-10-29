import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/core/http/either.dart';
import 'package:go_biky/core/http/endpoints.dart';
import 'package:go_biky/core/http/failure.dart';
import 'package:go_biky/feature/notifications/data/model/notifications_page.dart';
import 'package:go_biky/feature/notifications/data/model/unread_count_model.dart';

class NotificationsDataSource {
  NotificationsDataSource(this._dataSource);

  final GenericDataSource _dataSource;

  static const _pageSize = 20;

  /// `page` بيبدأ من 1
  Future<Either<Failure, NotificationsPage>> getNotifications({
    required int page,
    bool unreadOnly = false,
  }) {
    return _dataSource.fetchResult<NotificationsPage>(
      endpoint: Endpoints.notifications,
      queryParameters: {
        'PageIndex': page,
        'PageSize': _pageSize,
        if (unreadOnly) 'UnreadOnly': true,
      },
      fromJson: NotificationsPage.fromJson,
    );
  }

  Future<Either<Failure, UnreadCountModel>> getUnreadCount() {
    return _dataSource.fetchResult<UnreadCountModel>(
      endpoint: Endpoints.notificationsUnreadCount,
      fromJson: UnreadCountModel.fromJson,
    );
  }

  Future<Either<Failure, String>> markAsRead(String id) =>
      _post(Endpoints.notificationRead(id));

  Future<Either<Failure, String>> markAllAsRead() =>
      _post(Endpoints.notificationsReadAll);

  Future<Either<Failure, String>> acknowledge(String id) =>
      _post(Endpoints.notificationAcknowledge(id));

  /// توكن FCM لازم يكون من مشروع Firebase بتاع الباك (gobiky-2ca80)
  Future<Either<Failure, String>> registerDevice(String fcmToken) =>
      _post(Endpoints.notificationDevices, data: {'fcmToken': fcmToken});

  Future<Either<Failure, Null>> unregisterDevice(String fcmToken) {
    return _dataSource.deleteData<Null>(
      endpoint: Endpoints.notificationDevices,
      queryParameters: {'fcmToken': fcmToken},
    );
  }

  /// الطلبات دي مابترجعش غير رسالة
  Future<Either<Failure, String>> _post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) {
    return _dataSource.postData<String>(
      endpoint: endpoint,
      data: data,
      fromJson: (json) => json['message']?.toString() ?? '',
    );
  }
}
