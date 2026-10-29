import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/style/assets.dart';

/// اسم التطبيق في البداية و"مساحة الراكب" في الآخر — بيقلبوا مع اتجاه اللغة
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'splash.appName'.tr(),
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// مكان صورة الموتوسيكل في الديزاين — بيعرض لوجو التطبيق
class LoginLogoCard extends StatelessWidget {
  const LoginLogoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(Assets.assetsImagesGoBikyLogo, fit: BoxFit.contain);
  }
}

class LoginInfoCard extends StatelessWidget {
  const LoginInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        'auth.accountInfo'.tr(),
        textAlign: TextAlign.center,
        style: context.textTheme.bodySmall?.copyWith(
          color: colors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }
}
