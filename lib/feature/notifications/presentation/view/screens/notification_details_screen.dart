import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/notifications/data/model/notification_model.dart';
import 'package:go_biky/feature/notifications/presentation/view/widgets/notification_widgets.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/notifications_cubit.dart';

/// تفاصيل الإشعارات اللي مالهاش شاشة تخصها (الخروج من المنطقة، الرخصة...).
/// بتعرض نسخة الصندوق لو موجودة، لأن اللي جاي من push مافيهوش وقته ولا
/// إذا كان محتاج "تم"
class NotificationDetailsScreen extends StatelessWidget {
  const NotificationDetailsScreen({super.key, required this.notification});

  final NotificationModel notification;

  Future<void> _acknowledge(BuildContext context, String id) async {
    final error = await getIt<NotificationsCubit>().acknowledge(id);
    if (error != null && context.mounted) context.showErrorMessage(error);
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      NotificationsCubit,
      BaseState<NotificationModel>,
      NotificationModel
    >(
      bloc: getIt<NotificationsCubit>(),
      selector: (state) => state.items.firstWhere(
        (item) => item.id == notification.id,
        orElse: () => notification,
      ),
      builder: (context, notification) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 0),
                child: ResponsiveCenter(
                  child: CustomBackHeader(
                    title: 'notifications.detailsTitle'.tr(),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                  child: ResponsiveCenter(
                    child: _DetailsCard(notification: notification),
                  ),
                ),
              ),
              if (notification.needsAcknowledgement)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.w, 0, 20.w, 16.h),
                  child: ResponsiveCenter(
                    child: CustomButton(
                      title: 'notifications.acknowledge'.tr(),
                      onPressed: () => _acknowledge(context, notification.id),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final severity = notification.severity;
    final createdAt = notification.createdAtUtc.toLocal();

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NotificationIconBox(notification: notification, size: 56.r),
              Gaps.h(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (severity.labelKey case final labelKey?) ...[
                      CustomBadge(
                        text: labelKey.tr(),
                        color: severity.color(colors),
                        backgroundColor: severity.containerColor(colors),
                      ),
                      Gaps.v(6.h),
                    ],
                    Text(
                      'notifications.dateAt'.tr(
                        args: [
                          context.formatDate(createdAt),
                          context.formatTime(createdAt),
                        ],
                      ),
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gaps.v(16.h),
          Text(
            notification.title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: severity == NotificationSeverity.critical
                  ? colors.error
                  : colors.textPrimary,
            ),
          ),
          Gaps.v(8.h),
          Text(
            notification.body,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
