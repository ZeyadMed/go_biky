import 'package:easy_localization/easy_localization.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/style/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/theme/app_colors.dart';
import 'package:go_biky/core/theme/text_styles.dart';
import 'package:go_biky/core/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

import '../view_model/cubit/splash_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // _navigateToOnboarding();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // اسم التطبيق يدخل من اليمين
    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit()..startSplashScreen(),
      child: BlocListener<SplashCubit, String>(
        listener: (context, state) {
          // TODO: الـ 'home' يروح على الهوم لما الشاشة تتعمل
          if (state == 'home' || state == 'login') {
            GoRouter.of(context).go(AppRouter.login);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.blackColor,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(Assets.assetsImagesSplashRider, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.splashOverlay),
              ),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        Gaps.v(80.h),
                        SlideTransition(
                          position: _titleSlideAnimation,
                          child: const _BrandTitle(),
                        ),
                        Gaps.v(12.h),
                        Text(
                          'splash.tagline'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyles.whiteText(
                            15,
                            weight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'splash.headline'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyles.whiteText(26),
                        ),
                        Gaps.v(16.h),
                        Text(
                          'splash.subtitle'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyles.whiteText(
                            14,
                            weight: FontWeight.w400,
                          ).copyWith(
                            color: AppColors.whiteTextMuted,
                            height: 1.6,
                          ),
                        ),
                        Gaps.v(48.h),
                      ],
                    ),
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

/// اسم التطبيق ومعاه الشرطة البرتقالي — الـ Row بيقلب مكانها مع اتجاه اللغة
class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('splash.appName'.tr(), style: TextStyles.whiteText(48)),
        // Gaps.h(12.w),
        // Transform.rotate(
        //   angle: 0.35,
        //   child: Container(
        //     width: 8.w,
        //     height: 40.h,
        //     decoration: BoxDecoration(
        //       color: AppColors.brandOrange,
        //       borderRadius: BorderRadius.circular(8.r),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
