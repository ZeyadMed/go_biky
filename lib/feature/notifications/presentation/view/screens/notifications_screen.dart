import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/notifications/data/model/notification_model.dart';
import 'package:go_biky/feature/notifications/data/model/unread_count_model.dart';
import 'package:go_biky/feature/notifications/presentation/view/widgets/notification_navigation.dart';
import 'package:go_biky/feature/notifications/presentation/view/widgets/notification_widgets.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/notifications_cubit.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/unread_notifications_cubit.dart';

/// الإشعارات متجمعة باليوم من الأحدث للأقدم، والصفحة اللي بعدها بتيجي مع
/// السكرول. الضغط على إشعار بيعلّمه مقروء وبيفتح الشاشة اللي تخصه
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _cubit = getIt<NotificationsCubit>();
  final _unreadCubit = getIt<UnreadNotificationsCubit>();

  @override
  void initState() {
    super.initState();
    // بيتحدث مع كل فتحة عشان الجديد يبان، والقديم بيفضل ظاهر لحد ما يوصل
    _refresh();
  }

  Future<void> _refresh() =>
      Future.wait([_cubit.refresh(), _unreadCubit.getUnreadCount()]);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocBuilder<UnreadNotificationsCubit, BaseState<UnreadCountModel>>(
      bloc: _unreadCubit,
      builder: (context, unreadState) {
        final unreadCount = unreadState.data?.unread ?? 0;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 12.w, 0),
                  child: ResponsiveCenter(
                    child: CustomBackHeader(
                      title: 'notifications.title'.tr(),
                      trailing: IconButton(
                        onPressed: unreadCount == 0
                            ? null
                            : _cubit.markAllAsRead,
                        tooltip: 'notifications.markAllRead'.tr(),
                        icon: Icon(
                          Icons.done_all_rounded,
                          color: unreadCount == 0
                              ? colors.textHint
                              : colors.textPrimary,
                          size: 26.r,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child:
                      BlocBuilder<
                        NotificationsCubit,
                        BaseState<NotificationModel>
                      >(
                        bloc: _cubit,
                        builder: (context, state) {
                          if (state.isFailure && state.items.isEmpty) {
                            return FailureWidget(
                              errorMessage:
                                  state.errorMessage ??
                                  'common.somethingWentWrong'.tr(),
                              onRefresh: _refresh,
                            );
                          }

                          return RefreshIndicator(
                            color: colors.primary,
                            onRefresh: _refresh,
                            child: SingleChildScrollView(
                              controller: _cubit.scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                12.h,
                                20.w,
                                24.h,
                              ),
                              child: ResponsiveCenter(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (unreadCount > 0)
                                      _UnreadBar(
                                        count: unreadCount,
                                        onMarkAllRead: _cubit.markAllAsRead,
                                      ),
                                    _Entries(state: state),
                                    if (state.isLoadingMore) ...[
                                      Gaps.v(16.h),
                                      Center(
                                        child: CircularProgressIndicator(
                                          color: colors.primary,
                                        ),
                                      ),
                                    ],
                                    if (state.isLoadingMoreFauilare) ...[
                                      Gaps.v(8.h),
                                      Center(
                                        child: TextButton(
                                          onPressed: () =>
                                              _cubit.fetch(page: state.page),
                                          style: TextButton.styleFrom(
                                            foregroundColor: colors.primary,
                                          ),
                                          child: Text('common.retry'.tr()),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        );
      },
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

/// الإشعارات متجمعة باليوم، أو shimmer أول تحميل، أو رسالة لو الصندوق فاضي
class _Entries extends StatelessWidget {
  const _Entries({required this.state});

  final BaseState<NotificationModel> state;

  Future<void> _acknowledge(BuildContext context, String id) async {
    final error = await getIt<NotificationsCubit>().acknowledge(id);
    if (error != null && context.mounted) context.showErrorMessage(error);
  }

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty) {
      if (state.isInitial || state.isLoading) {
        return Padding(
          padding: EdgeInsets.only(top: 16.h),
          child: const ListShimmer(itemCount: 5),
        );
      }
      return const _NoNotifications();
    }

    // الإشعارات راجعة من الأحدث للأقدم، فالأيام بتطلع بنفس الترتيب
    final groups = <NotificationDayGroup, List<NotificationModel>>{};
    for (final item in state.items) {
      groups
          .putIfAbsent(
            NotificationDayGroup.of(item.createdAtUtc.toLocal()),
            () => [],
          )
          .add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final MapEntry(key: group, value: items) in groups.entries) ...[
          Gaps.v(16.h),
          RowWidget(title: group.labelKey.tr()),
          for (final item in items) ...[
            Gaps.v(12.h),
            NotificationCard(
              notification: item,
              onTap: () => NotificationNavigation.open(context, item),
              onAcknowledge: () => _acknowledge(context, item.id),
            ),
          ],
        ],
      ],
    );
  }
}

class _NoNotifications extends StatelessWidget {
  const _NoNotifications();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 96.h),
      child: Column(
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
    );
  }
}
