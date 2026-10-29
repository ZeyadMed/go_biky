import 'package:flutter/widgets.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/router/bottom_nav_app.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/feature/balance/presentation/view_model/cubit/balance_cubit.dart';
import 'package:go_biky/feature/notifications/data/model/notification_model.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/notifications_cubit.dart';
import 'package:go_biky/feature/oil_change/presentation/view_model/cubit/oil_log_cubit.dart';
import 'package:go_biky/feature/oil_change/presentation/view_model/cubit/oil_status_cubit.dart';
import 'package:go_biky/main.dart';
import 'package:go_router/go_router.dart';

/// بيعلّم الإشعار مقروء ويفتح الشاشة اللي تخصه حسب نوعه، سواء اتداس عليه
/// في الصندوق أو في الـ push
abstract final class NotificationNavigation {
  /// ضغطة push وصلت قبل ما التابات تتبني (التطبيق كان مقفول أو لسه على
  /// السبلاش)، فبتستنى لحد ما `BottomNavApp` تنادي `attach`
  static NotificationModel? _pending;
  static bool _attached = false;

  static void attach() {
    _attached = true;
    final pending = _pending;
    _pending = null;
    if (pending != null) openFromPush(pending);
  }

  static void detach() => _attached = false;

  /// الإشعار ممكن مايكونش في الصندوق لسه، فبعد القراءة الصندوق بيتحدث
  static void openFromPush(NotificationModel notification) {
    final context = navigatorKey.currentContext;
    if (!_attached || context == null) {
      _pending = notification;
      return;
    }

    final inbox = getIt<NotificationsCubit>();
    if (notification.id.isEmpty) {
      inbox.refresh();
    } else {
      inbox.markAsRead(notification.id).whenComplete(inbox.refresh);
    }
    _navigate(context, notification);
  }

  static void open(BuildContext context, NotificationModel notification) {
    getIt<NotificationsCubit>().markAsRead(notification.id);
    _navigate(context, notification);
  }

  /// الشاشة لكل نوع زي جدول الباك، والبيانات اللي فيها بتتحدث عشان نتيجة
  /// الإشعار تبان
  static void _navigate(BuildContext context, NotificationModel notification) {
    switch (notification.type) {
      // عداد الزيت وزرار التغيير في الرئيسية
      case NotificationType.maintenanceWarning ||
          NotificationType.maintenanceCritical ||
          NotificationType.oilChangeOverdue:
        getIt<OilStatusCubit>().getOilStatus();
        BottomNavApp.openTab(context, BottomNavTab.home);
      // القبول أو الرفض بيبان على الطلب في سجل الزيت
      case NotificationType.oilChangeReview:
        getIt<OilStatusCubit>().getOilStatus();
        getIt<OilLogCubit>().refresh();
        BottomNavApp.openTab(context, BottomNavTab.oilLog);
      // الرصيد والمديونية في حسابي
      case NotificationType.driverCharge || NotificationType.driverPayment:
        getIt<BalanceCubit>().getBalance();
        BottomNavApp.openTab(context, BottomNavTab.profile);
      case NotificationType.zoneExit ||
          NotificationType.documentExpiring ||
          NotificationType.other:
        context.push(AppRouter.notificationDetails, extra: notification);
    }
  }
}
