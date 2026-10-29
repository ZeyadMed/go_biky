import 'package:go_biky/feature/notifications/data/model/notification_model.dart';

/// صفحة من صندوق الإشعارات
class NotificationsPage {
  const NotificationsPage({
    required this.pageIndex,
    required this.pageSize,
    required this.count,
    required this.totalPages,
    required this.items,
  });

  final int pageIndex;
  final int pageSize;
  final int count;
  final int totalPages;

  /// الـ `data` اللي جوه الصفحة. اسمها `items` لأن GenericPaginationCubit
  /// بيقراها بالاسم ده
  final List<NotificationModel> items;

  factory NotificationsPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return NotificationsPage(
      pageIndex: (json['pageIndex'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      items: data is List
          ? data
                .map(
                  (item) => NotificationModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
    );
  }

  /// GenericPaginationCubit بيقرا رقم الصفحة وعدد الصفحات من هنا بالأسماء دي
  ({int currentPage, int pagesCount, int perPage, int total}) get pagination =>
      (
        currentPage: pageIndex,
        pagesCount: totalPages,
        perPage: pageSize,
        total: count,
      );
}
