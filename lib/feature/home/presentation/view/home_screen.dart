import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/router/bottom_nav_app.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/balance/presentation/view/widgets/balance_card.dart';
import 'package:go_biky/feature/balance/presentation/view_model/cubit/balance_cubit.dart';
import 'package:go_biky/feature/notifications/data/model/unread_count_model.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/unread_notifications_cubit.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_status_model.dart';
import 'package:go_biky/feature/oil_change/presentation/view/screens/oil_change_screen.dart';
import 'package:go_biky/feature/oil_change/presentation/view/widgets/oil_status.dart';
import 'package:go_biky/feature/oil_change/presentation/view_model/cubit/oil_status_cubit.dart';
import 'package:go_biky/feature/profile/data/model/profile_model.dart';
import 'package:go_biky/feature/profile/presentation/view_model/cubit/profile_cubit.dart';
import 'package:go_router/go_router.dart';

// TODO: صورة الراكب مش في ريسبونس الـ profile
const String? _riderImage = null;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _oilCubit = getIt<OilStatusCubit>();
  final _profileCubit = getIt<ProfileCubit>();
  final _unreadCubit = getIt<UnreadNotificationsCubit>();

  @override
  void initState() {
    super.initState();
    _oilCubit.getOilStatus();
    // حسابي بيعرض نفس البيانات والتابات بتتبني مع بعض، فأول واحد بس بيطلب
    if (_profileCubit.state.isInitial) _profileCubit.getProfile();
    _unreadCubit.getUnreadCount();
  }

  /// الرصيد بيتطلب أول مرة من الكارت نفسه، والسحب بيحدّث كل حاجة
  Future<void> _refresh() => Future.wait([
    _oilCubit.getOilStatus(),
    _profileCubit.getProfile(),
    getIt<BalanceCubit>().getBalance(),
    _unreadCubit.getUnreadCount(),
  ]);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<OilStatusCubit, BaseState<OilStatusModel>>(
          bloc: _oilCubit,
          builder: (context, state) {
            final oil = state.data;

            return RefreshIndicator(
              color: colors.primary,
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                // الـ padding اللي تحت فيه ارتفاع الـ bottom nav، فآخر المحتوى
                // مايستخباش وراه
                padding: EdgeInsetsDirectional.fromSTEB(
                  24.w,
                  16.h,
                  24.w,
                  MediaQuery.paddingOf(context).bottom + 24.h,
                ),
                child: ResponsiveCenter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BlocBuilder<ProfileCubit, BaseState<ProfileModel>>(
                        bloc: _profileCubit,
                        builder: (context, profileState) {
                          final profile = profileState.data;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Header(
                                name: profile?.fullName,
                                isLoading:
                                    profile == null && !profileState.isFailure,
                                image: _riderImage,
                                oilStatus: oil == null
                                    ? null
                                    : OilStatus.of(oil),
                              ),
                              Gaps.v(20.h),
                              switch (profile) {
                                final profile? => _BikeCard(profile: profile),
                                null when profileState.isFailure =>
                                  FailureWidget(
                                    compact: true,
                                    errorMessage: 'profile.loadFailed'.tr(),
                                    onRefresh: _profileCubit.getProfile,
                                  ),
                                null => AppShimmer(
                                  child: ShimmerBox(
                                    height: 72.h,
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                ),
                              },
                            ],
                          );
                        },
                      ),
                      Gaps.v(16.h),
                      if (oil != null)
                        _OilCounterCard(oil: oil)
                      else if (state.isFailure)
                        FailureWidget(
                          errorMessage:
                              state.errorMessage ??
                              'common.somethingWentWrong'.tr(),
                          onRefresh: _oilCubit.getOilStatus,
                        )
                      else
                        AppShimmer(
                          child: ShimmerBox(
                            height: 270.h,
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                      Gaps.v(16.h),
                      const BalanceCard(),
                      Gaps.v(24.h),
                      RowWidget(title: 'home.everythingForTheRoad'.tr()),
                      Gaps.v(12.h),
                      const _OilLogLink(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// صورة الراكب والتحية في البداية، والإشعارات في الآخر
class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.isLoading,
    required this.image,
    required this.oilStatus,
  });

  /// null لحد ما بيانات الراكب توصل، ومكانه shimmer وقت `isLoading`
  final String? name;
  final bool isLoading;
  final String? image;

  /// آخر التحية بيتغير معاها ("طريقك أخضر" / "حان وقت العناية")، ولحد
  /// ما الحالة توصل بتظهر التحية لوحدها
  final OilStatus? oilStatus;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isMorning = DateTime.now().hour < 12;
    final greeting = switch (oilStatus) {
      final status? =>
        (isMorning ? 'home.greetingMorning' : 'home.greetingEvening').tr(
          args: [status.greetingKey.tr()],
        ),
      null => (isMorning ? 'home.goodMorning' : 'home.goodEvening').tr(),
    };

    return Row(
      children: [
        FlexibleImage(
          source: image,
          isCircular: true,
          width: 48.r,
          height: 48.r,
          placeholder: ColoredBox(
            color: colors.bgTertiary,
            child: Center(
              child: Icon(
                Icons.person_rounded,
                color: colors.textHint,
                size: 28.r,
              ),
            ),
          ),
        ),
        Gaps.h(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              if (name case final name?)
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                )
              else if (isLoading)
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: AppShimmer(
                    child: ShimmerBox(height: 20.h, width: 140.w),
                  ),
                ),
            ],
          ),
        ),
        Gaps.h(12.w),
        BlocSelector<
          UnreadNotificationsCubit,
          BaseState<UnreadCountModel>,
          bool
        >(
          bloc: getIt<UnreadNotificationsCubit>(),
          selector: (state) => (state.data?.unread ?? 0) > 0,
          builder: (context, hasNew) => _NotificationButton(hasNew: hasNew),
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.hasNew});

  final bool hasNew;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return IconButton(
      onPressed: () => context.push(AppRouter.notifications),
      tooltip: 'home.notifications'.tr(),
      style: IconButton.styleFrom(
        backgroundColor: colors.bgSecondary,
        fixedSize: Size.square(46.r),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: colors.textPrimary,
            size: 24.r,
          ),
          if (hasNew)
            PositionedDirectional(
              top: 1.r,
              start: 3.r,
              child: Container(
                width: 9.r,
                height: 9.r,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.bgSecondary, width: 1.5.r),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// اسم الدراجة ورقم اللوحة بس، لأن الـ API مابيرجعش صورة للدراجة
class _BikeCard extends StatelessWidget {
  const _BikeCard({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final bikeName = profile.currentMotorcycleType;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(14.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.two_wheeler_rounded,
              color: colors.primary,
              size: 24.r,
            ),
          ),
          Gaps.h(12.w),
          Expanded(
            child: Text(
              profile.hasBike
                  ? bikeName ?? 'profile.bike'.tr()
                  : 'profile.noBike'.tr(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: profile.hasBike
                  ? textTheme.titleMedium?.copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                    )
                  : textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
          ),
          if (profile.currentMotorcyclePlate case final plateNumber?) ...[
            Gaps.h(8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: colors.bgTertiary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                context.localizeDigits(plateNumber),
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// الدايرة من `maxKm`، والمتبقي هو `remainingToMaxKm` من غير سالب
class _OilCounterCard extends StatelessWidget {
  const _OilCounterCard({required this.oil});

  final OilStatusModel oil;

  // TODO: العداد الكلي للدراجة مش في ريسبونس oil-status، وسطره بيظهر
  // لما يتضاف
  static const int? _odometerKm = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final status = OilStatus.of(oil);
    final kmUsed = oil.kmSinceOilChange;
    final kmInterval = oil.maxKm;
    final statusColor = status.color(colors);
    final infoStyle = textTheme.bodySmall?.copyWith(
      fontSize: 11.sp,
      color: colors.textSecondary,
    );

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(18.w, 16.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'home.oilCounter'.tr(),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Gaps.h(8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: status.containerColor(colors),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  status.labelKey.tr(),
                  style: textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Gaps.v(12.h),
          Row(
            children: [
              _OilRing(
                progress: kmInterval > 0
                    ? (kmUsed / kmInterval).clamp(0.0, 1.0)
                    : 1.0,
                color: statusColor,
                kmUsed: kmUsed,
                kmInterval: kmInterval,
              ),
              Gaps.h(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home.remainingToChange'.tr(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'home.km'.tr(
                          args: [
                            context.formatNumber(
                              oil.remainingToMaxKm.clamp(0, kmInterval),
                            ),
                          ],
                        ),
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                    Gaps.v(4.h),
                    if (_odometerKm case final odometerKm?)
                      Text(
                        'home.totalOdometer'.tr(
                          args: [context.formatNumber(odometerKm)],
                        ),
                        style: infoStyle,
                      ),
                    Text('home.sinceLastChange'.tr(), style: infoStyle),
                  ],
                ),
              ),
            ],
          ),
          Gaps.v(16.h),
          CustomButton(
            title: 'home.changeOilNow'.tr(),
            onPressed: () => context.push(
              AppRouter.oilChange,
              extra: OilChangeArgs(
                odometerKm: _odometerKm,
                kmUsed: kmUsed,
                kmInterval: kmInterval,
              ),
            ),
            backgroundColor: colors.secondary,
            textColor: context.colorScheme.onSecondary,
          ),
        ],
      ),
    );
  }
}

/// الدايرة بتتملي بالمسافة اللي اتمشت من آخر تغيير
class _OilRing extends StatelessWidget {
  const _OilRing({
    required this.progress,
    required this.color,
    required this.kmUsed,
    required this.kmInterval,
  });

  final double progress;
  final Color color;
  final int kmUsed;
  final int kmInterval;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox.square(
      dimension: 132.r,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 14.r,
            strokeAlign: CircularProgressIndicator.strokeAlignInside,
            strokeCap: StrokeCap.round,
            color: color,
            backgroundColor: colors.border,
          ),
          Padding(
            padding: EdgeInsets.all(24.r),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.formatNumber(kmUsed),
                    style: context.textTheme.displaySmall?.copyWith(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'home.ofKm'.tr(args: [context.formatNumber(kmInterval)]),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// صف واحد بيفتح تاب سجل الزيت
class _OilLogLink extends StatelessWidget {
  const _OilLogLink();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.appColors.bgSecondary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: CustomListTile(
        text: 'home.oilLog'.tr(),
        icon: Icons.oil_barrel_outlined,
        showDivider: false,
        onTap: () => BottomNavApp.openTab(context, BottomNavTab.oilLog),
      ),
    );
  }
}
