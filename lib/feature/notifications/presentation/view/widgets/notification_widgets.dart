import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/theme/app_theme_colors.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/notifications/data/model/notification_model.dart';

/// اليوم اللي الإشعارات بتتجمع تحته في الصندوق
enum NotificationDayGroup {
  today('notifications.today'),
  yesterday('notifications.yesterday'),
  earlier('notifications.earlier');

  const NotificationDayGroup(this.labelKey);

  final String labelKey;

  static NotificationDayGroup of(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return today;
    if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return yesterday;
    }
    return earlier;
  }
}

extension NotificationTypeIcon on NotificationType {
  IconData get icon => switch (this) {
    NotificationType.maintenanceWarning ||
    NotificationType.maintenanceCritical ||
    NotificationType.oilChangeOverdue => Icons.oil_barrel_outlined,
    NotificationType.oilChangeReview => Icons.fact_check_outlined,
    NotificationType.zoneExit => Icons.wrong_location_outlined,
    NotificationType.driverCharge => Icons.receipt_long_outlined,
    NotificationType.driverPayment => Icons.payments_outlined,
    NotificationType.documentExpiring => Icons.badge_outlined,
    NotificationType.other => Icons.notifications_none_rounded,
  };
}

/// الأهمية بتحدد لون الأيقونة والشارة، والعاجل عنوانه بلون الخطأ
extension NotificationSeverityStyle on NotificationSeverity {
  Color color(AppThemeColors colors) => switch (this) {
    NotificationSeverity.info => colors.info,
    NotificationSeverity.warning => colors.warning,
    NotificationSeverity.critical => colors.error,
  };

  Color containerColor(AppThemeColors colors) => switch (this) {
    NotificationSeverity.info => colors.infoContainer,
    NotificationSeverity.warning => colors.warningContainer,
    NotificationSeverity.critical => colors.errorContainer,
  };

  /// العادي مالوش شارة
  String? get labelKey => switch (this) {
    NotificationSeverity.info => null,
    NotificationSeverity.warning => 'notifications.severityWarning',
    NotificationSeverity.critical => 'notifications.severityCritical',
  };
}

extension NotificationTimeLabel on NotificationModel {
  /// "منذ ٥ دقائق" / "منذ ساعة" / "اليوم، ١٠:٣٠ صباحاً" / "أمس، ..." / "٢٤ أكتوبر، ..."
  String timeLabel(BuildContext context) {
    final date = createdAtUtc.toLocal();
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
    return switch (NotificationDayGroup.of(date)) {
      NotificationDayGroup.today => 'notifications.todayAt'.tr(args: [time]),
      NotificationDayGroup.yesterday => 'notifications.yesterdayAt'.tr(
        args: [time],
      ),
      NotificationDayGroup.earlier => 'notifications.dateAt'.tr(
        args: [context.formatDayMonth(date), time],
      ),
    };
  }
}

/// أيقونة النوع في مربع بلون الأهمية
class NotificationIconBox extends StatelessWidget {
  const NotificationIconBox({
    super.key,
    required this.notification,
    this.size,
  });

  final NotificationModel notification;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dimension = size ?? 48.r;
    final severity = notification.severity;

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: severity.containerColor(colors),
        borderRadius: BorderRadius.circular(dimension * 0.3),
      ),
      child: Icon(
        notification.type.icon,
        color: severity.color(colors),
        size: dimension * 0.5,
      ),
    );
  }
}

/// غير المقروء بخلفية الكروت وحدود ونقطة جنب العنوان، والمقروء بخلفية باهتة.
/// الإشعار المهم اللي مستني تأكيد بيبان تحته زرار "تم"
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onAcknowledge,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final isRead = notification.isRead;

    return Material(
      color: isRead ? colors.bgTertiary : colors.bgSecondary,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22.r),
        side: isRead ? BorderSide.none : BorderSide(color: colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationIconBox(notification: notification),
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
                                  notification.severity ==
                                      NotificationSeverity.critical
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
                      notification.timeLabel(context),
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10.sp,
                        color: colors.textHint,
                      ),
                    ),
                    if (notification.needsAcknowledgement) ...[
                      Gaps.v(10.h),
                      CustomButton(
                        title: 'notifications.acknowledge'.tr(),
                        onPressed: onAcknowledge,
                        width: 96.w,
                        height: 36.h,
                        fontSize: 13.sp,
                        borderRadius: 12.r,
                      ),
                    ],
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
