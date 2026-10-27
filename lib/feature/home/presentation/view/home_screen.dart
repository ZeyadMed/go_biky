import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/router/bottom_nav_app.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/style/assets.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/notifications/app_notification.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/notifications_cubit.dart';
import 'package:go_biky/feature/oil_change/oil_status.dart';
import 'package:go_biky/feature/oil_change/presentation/view/oil_change_screen.dart';
import 'package:go_router/go_router.dart';

// TODO: بيانات مؤقتة لحد ما الـ API يجهز
const _riderName = 'أحمد العتيبي';
const String? _riderImage = null;
const _fleetName = 'مدار';
const _bikeName = 'ياماها إف زد ٢٥٠';
const _plateNumber = 'ر ب د • ٤٥٢١';
const _oilKmUsed = 32;
const _oilKmInterval = 50;
const _odometerKm = 12482;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final oilStatus = OilStatus.from(
      remainingKm: _oilKmInterval - _oilKmUsed,
      intervalKm: _oilKmInterval,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
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
                _Header(
                  name: _riderName,
                  image: _riderImage,
                  oilStatus: oilStatus,
                ),
                Gaps.v(20.h),
                const _BikeCard(
                  image: Assets.assetsImagesMotorcycle,
                  fleetName: _fleetName,
                  bikeName: _bikeName,
                  plateNumber: _plateNumber,
                ),
                Gaps.v(16.h),
                _OilCounterCard(
                  status: oilStatus,
                  kmUsed: _oilKmUsed,
                  kmInterval: _oilKmInterval,
                  odometerKm: _odometerKm,
                ),
                Gaps.v(24.h),
                RowWidget(title: 'home.everythingForTheRoad'.tr()),
                Gaps.v(12.h),
                const _QuickLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// صورة الراكب والتحية في البداية، والإشعارات في الآخر
class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.image,
    required this.oilStatus,
  });

  final String name;
  final String? image;

  /// آخر التحية بيتغير معاها ("طريقك أخضر" / "حان وقت العناية")
  final OilStatus oilStatus;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final greetingKey = DateTime.now().hour < 12
        ? 'home.greetingMorning'
        : 'home.greetingEvening';
    final greeting = greetingKey.tr(args: [oilStatus.greetingKey.tr()]);

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
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Gaps.h(12.w),
        BlocSelector<NotificationsCubit, List<AppNotification>, bool>(
          bloc: getIt<NotificationsCubit>(),
          selector: (notifications) =>
              notifications.any((item) => !item.isRead),
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

/// صورة الدراجة والنص فوقها في الآخر زي الديزاين، ورقم اللوحة تحت
class _BikeCard extends StatelessWidget {
  const _BikeCard({
    required this.image,
    required this.fleetName,
    required this.bikeName,
    required this.plateNumber,
  });

  final String? image;
  final String fleetName;
  final String bikeName;
  final String plateNumber;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // لون الصورة مابيتغيرش مع الوضع، فالهالة دي بلون الكارت بتخلي النص
    // يتقري لو جه فوق جزء غامق أو فاتح من الصورة
    final halo = [
      Shadow(color: colors.bgSecondary, blurRadius: 4.r),
      Shadow(color: colors.bgSecondary, blurRadius: 12.r),
    ];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.bgTertiary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: AspectRatio(
        aspectRatio: 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlexibleImage(source: image),
            // الصورة فاتحة، فالـ dark mode محتاج طبقة غامقة فوق عشان النص
            // الفاتح يبان وعشان الكارت مايبقاش منوّر وسط الشاشة
            if (context.isDarkMode)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.bgSecondary.withValues(alpha: 0.9),
                      colors.bgSecondary.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.6],
                  ),
                ),
              ),
            PositionedDirectional(
              top: 14.h,
              start: 16.w,
              end: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'home.yourBikeAt'.tr(args: [fleetName]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      shadows: halo,
                    ),
                  ),
                  Text(
                    bikeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      shadows: halo,
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              bottom: 12.h,
              end: 14.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: colors.bgSecondary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  plateNumber,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OilCounterCard extends StatelessWidget {
  const _OilCounterCard({
    required this.status,
    required this.kmUsed,
    required this.kmInterval,
    required this.odometerKm,
  });

  final OilStatus status;

  /// المسافة من آخر تغيير
  final int kmUsed;

  /// المسافة المفروض يتغير بعدها
  final int kmInterval;
  final int odometerKm;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final remainingKm = kmInterval - kmUsed;
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
                              remainingKm.clamp(0, kmInterval),
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
                odometerKm: odometerKm,
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

class _QuickLink {
  const _QuickLink(
    this.labelKey,
    this.icon, {
    required this.image,
    this.route,
    this.tab,
  });

  final String labelKey;

  /// بتظهر مكان الصورة لو `image` بـ null
  final IconData icon;
  final String? image;

  /// الشاشة اللي الكارت بيفتحها
  final String? route;

  /// أو التاب اللي بيفتحه لو الشاشة تاب في البار
  final BottomNavTab? tab;
}

// TODO: صور الكروت لسه مش في الـ assets
const _quickLinks = [
  _QuickLink(
    'home.maintenanceAndParts',
    Icons.build_outlined,
    image: null,
    tab: BottomNavTab.spareParts,
  ),
  _QuickLink(
    'bottomNav.orders',
    Icons.assignment_outlined,
    image: null,
    tab: BottomNavTab.orders,
  ),
  _QuickLink(
    'home.oilLog',
    Icons.oil_barrel_outlined,
    image: null,
    route: AppRouter.oilLog,
  ),
];

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _quickLinks.length; i++) ...[
          if (i > 0) Gaps.h(10.w),
          Expanded(child: _QuickLinkCard(link: _quickLinks[i])),
        ],
      ],
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({required this.link});

  final _QuickLink link;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.bgSecondary,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () {
          if (link.tab case final tab?) {
            BottomNavApp.openTab(context, tab);
          } else if (link.route case final route?) {
            context.push(route);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: FlexibleImage(
                source: link.image,
                placeholder: ColoredBox(
                  color: colors.bgTertiary,
                  child: Center(
                    child: Icon(
                      link.icon,
                      color: colors.textSecondary,
                      size: 28.r,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
              // على الموبايل الصغير النص بيصغر بدل ما يتقص
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  link.labelKey.tr(),
                  maxLines: 1,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
