import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/router/bottom_nav_app.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/notifications/app_notification.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/notifications_cubit.dart';
import 'package:go_biky/feature/orders/presentation/view_model/cubit/orders_cubit.dart';
import 'package:go_router/go_router.dart';

enum _DayGroup {
  today('notifications.today'),
  yesterday('notifications.yesterday'),
  earlier('notifications.earlier');

  const _DayGroup(this.labelKey);

  final String labelKey;

  static _DayGroup of(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return today;
    if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return yesterday;
    }
    return earlier;
  }
}

/// الإشعارات متجمعة باليوم من الأحدث للأقدم. الضغط على إشعار بيعلّمه مقروء
/// وبيفتح الشاشة اللي تخصه
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<NotificationsCubit>(),
      child: BlocBuilder<NotificationsCubit, List<AppNotification>>(
        builder: (context, notifications) {
          final cubit = context.read<NotificationsCubit>();
          final unreadCount = cubit.unreadCount;
          final groups = <_DayGroup, List<AppNotification>>{};
          for (final item in notifications) {
            groups
                .putIfAbsent(_DayGroup.of(item.createdAt), () => [])
                .add(item);
          }

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      20.w,
                      12.h,
                      12.w,
                      0,
                    ),
                    child: ResponsiveCenter(
                      child: CustomBackHeader(
                        title: 'notifications.title'.tr(),
                        trailing: IconButton(
                          onPressed: unreadCount == 0
                              ? null
                              : cubit.markAllAsRead,
                          tooltip: 'notifications.markAllRead'.tr(),
                          icon: Icon(
                            Icons.done_all_rounded,
                            color: unreadCount == 0
                                ? context.appColors.textHint
                                : context.appColors.textPrimary,
                            size: 26.r,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: notifications.isEmpty
                        ? const _NoNotifications()
                        : SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              20.w,
                              12.h,
                              20.w,
                              24.h,
                            ),
                            child: ResponsiveCenter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (unreadCount > 0)
                                    _UnreadBar(
                                      count: unreadCount,
                                      onMarkAllRead: cubit.markAllAsRead,
                                    ),
                                  for (final MapEntry(key: group, value: items)
                                      in groups.entries) ...[
                                    Gaps.v(16.h),
                                    RowWidget(title: group.labelKey.tr()),
                                    for (final item in items) ...[
                                      Gaps.v(12.h),
                                      _NotificationCard(notification: item),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// عدد غير المقروء في البداية، و"تحديد الكل كمقروء" في الآخر
class _UnreadBar extends StatelessWidget {
  const _UnreadBar({required this.count, required this.onMarkAllRead});

  final int count;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomBadge(
          text: 'notifications.unreadCount'.plural(
            count,
            args: [context.formatNumber(count)],
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onMarkAllRead,
          style: TextButton.styleFrom(
            foregroundColor: context.appColors.primary,
            textStyle: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('notifications.markAllRead'.tr()),
        ),
      ],
    );
  }
}

/// غير المقروء بخلفية الكروت وحدود ونقطة جنب العنوان، والمقروء بخلفية باهتة
class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  /// "منذ ٥ دقائق" / "منذ ساعة" / "اليوم، ١٠:٣٠ صباحاً" / "أمس، ..." / "٢٤ أكتوبر، ..."
  String _timeLabel(BuildContext context) {
    final date = notification.createdAt;
    final elapsed = DateTime.now().difference(date);
    if (elapsed.inMinutes < 1) return 'notifications.justNow'.tr();
    if (elapsed.inMinutes < 60) {
      return 'notifications.minutesAgo'.plural(
        elapsed.inMinutes,
        args: [context.formatNumber(elapsed.inMinutes)],
      );
    }
    if (elapsed.inHours < 3) {
      return 'notifications.hoursAgo'.plural(
        elapsed.inHours,
        args: [context.formatNumber(elapsed.inHours)],
      );
    }
    final time = context.formatTime(date);
    return switch (_DayGroup.of(date)) {
      _DayGroup.today => 'notifications.todayAt'.tr(args: [time]),
      _DayGroup.yesterday => 'notifications.yesterdayAt'.tr(args: [time]),
      _DayGroup.earlier => 'notifications.dateAt'.tr(
        args: [context.formatDayMonth(date), time],
      ),
    };
  }

  void _open(BuildContext context) {
    context.read<NotificationsCubit>().markAsRead(notification.id);
    switch (notification.type) {
      // الإشعارات بتتفتح من الرئيسية، وزرار تغيير الزيت هناك
      case NotificationType.oilDue:
        BottomNavApp.openTab(context, BottomNavTab.home);
      case NotificationType.oilProof:
        context.push(AppRouter.oilLog);
      case NotificationType.order:
        final order = getIt<OrdersCubit>().state
            .where((order) => order.id == notification.orderId)
            .firstOrNull;
        if (order != null) context.push(AppRouter.orderDetails, extra: order);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final isRead = notification.isRead;
    final radius = BorderRadius.circular(22.r);

    return Material(
      color: isRead ? colors.bgTertiary : colors.bgSecondary,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: isRead ? BorderSide.none : BorderSide(color: colors.border),
      ),
      child: InkWell(
        onTap: () => _open(context),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              SizedBox(
                width: 64.r,
                height: 80.r,
                child: FlexibleImage(
                  source: notification.image,
                  borderRadius: 14.r,
                  placeholder: ColoredBox(
                    color: isRead ? colors.bgSecondary : colors.bgTertiary,
                    child: Center(
                      child: Icon(
                        notification.type.icon,
                        color: colors.textHint,
                        size: 26.r,
                      ),
                    ),
                  ),
                ),
              ),
              Gaps.h(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color:
                                  notification.type == NotificationType.oilDue
                                  ? colors.error
                                  : colors.textPrimary,
                            ),
                          ),
                        ),
                        if (!isRead) ...[
                          Gaps.h(8.w),
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Gaps.v(2.h),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
                        color: colors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    Gaps.v(2.h),
                    Text(
                      _timeLabel(context),
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10.sp,
                        color: colors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoNotifications extends StatelessWidget {
  const _NoNotifications();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: colors.textHint,
              size: 52.r,
            ),
            Gaps.v(12.h),
            Text(
              'notifications.empty'.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
