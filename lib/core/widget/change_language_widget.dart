import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_router/go_router.dart';

/// سويتش العربي/الإنجليزي. بعد التغيير بيرجع للشاشة الرئيسية عشان كل
/// الشاشات تتبني من جديد باللغة الجديدة
class ChangeLanguageWidget extends StatelessWidget {
  const ChangeLanguageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.appColors.border, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            // show current language name (localized)
            isArabic ? 'settings.arabic'.tr() : 'settings.english'.tr(),
            style: context.textTheme.titleMedium,
          ),
          CupertinoSwitch(
            value: isArabic,
            activeTrackColor: context.appColors.primary,
            onChanged: (val) {
              context.go(AppRouter.initialRoute);
              context.setLocale(Locale(val ? 'ar' : 'en'));
            },
          ),
        ],
      ),
    );
  }
}
