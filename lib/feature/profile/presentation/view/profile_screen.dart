import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/http/session.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/style/assets.dart';
import 'package:go_biky/core/theme/theme_mode_controller.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/profile/policy_document.dart';
import 'package:go_router/go_router.dart';

// TODO: من بيانات المستخدم لما الـ API يجهز
const _riderName = 'أحمد العتيبي';
const _username = 'أحمد.العتيبي';
const _phone = '055 123 4567';
const String? _riderImage = null;
const _fleetName = 'مدار';
const _bikeName = 'ياماها إف زد ٢٥٠';
const _plateNumber = '٤٥٢١ • ر ب د';
// TODO: يتقري من package_info_plus لو اتضافت
const _appVersion = '1.0.0';

/// حسابي: بيانات الراكب ودراجته، وروابط السياسات والتواصل والخروج
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 0),
              child: ResponsiveCenter(
                child: CustomBackHeader(title: 'profile.title'.tr()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                // الـ padding اللي تحت فيه ارتفاع الـ bottom nav، فآخر
                // المحتوى مايستخباش وراه
                padding: EdgeInsetsDirectional.fromSTEB(
                  20.w,
                  20.h,
                  20.w,
                  MediaQuery.paddingOf(context).bottom + 24.h,
                ),
                child: ResponsiveCenter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _RiderHeader(),
                      Gaps.v(20.h),
                      const _BikeCard(),
                      Gaps.v(16.h),
                      const _SettingsCard(),
                      Gaps.v(12.h),
                      const _MenuCard(),
                      Gaps.v(20.h),
                      Text(
                        '${'profile.footerCompany'.tr(args: [_fleetName])}\n'
                        '${'profile.version'.tr(args: [context.localizeDigits(_appVersion)])}',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 10.sp,
                          color: colors.textHint,
                          height: 1.7,
                        ),
                      ),
                    ],
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

class _RiderHeader extends StatelessWidget {
  const _RiderHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final infoStyle = context.textTheme.bodySmall?.copyWith(
      fontSize: 11.sp,
      color: colors.textSecondary,
    );

    return Row(
      children: [
        FlexibleImage(
          source: _riderImage,
          width: 80.r,
          height: 88.r,
          borderRadius: 20.r,
          placeholder: ColoredBox(
            color: colors.bgTertiary,
            child: Center(
              child: Icon(
                Icons.person_rounded,
                color: colors.textHint,
                size: 40.r,
              ),
            ),
          ),
        ),
        Gaps.h(16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _riderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'profile.username'.tr(args: [_username]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: infoStyle,
              ),
              Text(
                'profile.phone'.tr(args: [context.localizeDigits(_phone)]),
                maxLines: 1,
                style: infoStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BikeCard extends StatelessWidget {
  const _BikeCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return CustomDetailsCard(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'profile.yourBike'.tr(args: [_bikeName]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Gaps.h(8.w),
              CustomBadge(
                text: 'profile.bikeActive'.tr(),
                color: colors.success,
                backgroundColor: colors.successContainer,
              ),
            ],
          ),
          Gaps.v(10.h),
          AspectRatio(
            aspectRatio: 7 / 2,
            child: FlexibleImage(
              source: Assets.assetsImagesMotorcycle,
              borderRadius: 14.r,
            ),
          ),
        ],
      ),
      rows: [(label: 'profile.plateNumber'.tr(), value: _plateNumber)],
    );
  }
}

/// الكارت اللي فيه صفوف حسابي
class _ListCard extends StatelessWidget {
  const _ListCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.appColors.bgSecondary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(children: children),
    );
  }
}

/// السهم اللي في آخر الصف، وقبله القيمة الحالية لو موجودة (زي اللغة)
class _RowTrailing extends StatelessWidget {
  const _RowTrailing({this.value});

  final String? value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value case final value?) ...[
          Text(
            value,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.textHint,
            ),
          ),
          Gaps.h(8.w),
        ],
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15.r,
          color: colors.textHint,
        ),
      ],
    );
  }
}

/// اللغة والمظهر، وكل واحد بيفتح sheet فيه الاختيارات
class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  Future<void> _pick<T>(
    BuildContext context, {
    required String title,
    required T selected,
    required List<(T, String)> options,
    required ValueChanged<T> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.appColors.bgSecondary,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.w, 0, 20.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Gaps.v(8.h),
              for (final (value, label) in options)
                DefaultRadioButton(
                  title: label,
                  selected: value == selected,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    if (value != selected) onSelected(value);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    String languageName(Locale locale) => locale.languageCode == 'ar'
        ? 'settings.arabic'.tr()
        : 'settings.english'.tr();
    final themeModes = [
      (ThemeMode.light, 'settings.lightMode'.tr()),
      (ThemeMode.dark, 'settings.darkMode'.tr()),
      (ThemeMode.system, 'settings.systemMode'.tr()),
    ];

    return _ListCard(
      children: [
        CustomListTile(
          text: 'settings.language'.tr(),
          icon: Icons.language_rounded,
          trailing: _RowTrailing(value: languageName(locale)),
          onTap: () => _pick(
            context,
            title: 'settings.language'.tr(),
            selected: locale,
            options: [
              for (final option in context.supportedLocales)
                (option, languageName(option)),
            ],
            onSelected: context.setLocale,
          ),
        ),
        // الاختيار ممكن يتغير من غير ما الثيم نفسه يتغير (زي "حسب الجهاز"
        // والجهاز فاتح)، فالصف بيسمع للـ notifier على طول
        ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeModeController.notifier,
          builder: (context, mode, _) => CustomListTile(
            text: 'settings.theme'.tr(),
            icon: Icons.dark_mode_outlined,
            showDivider: false,
            trailing: _RowTrailing(
              value: themeModes.firstWhere((item) => item.$1 == mode).$2,
            ),
            onTap: () => _pick(
              context,
              title: 'settings.theme'.tr(),
              selected: mode,
              options: themeModes,
              onSelected: ThemeModeController.setThemeMode,
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard();

  /// بيمسح الجلسة وكل الـ singletons (السلة والطلبات والإشعارات) عشان اللي
  /// يدخل بعده مايلاقيش حاجة من الحساب القديم
  Future<void> _logout(BuildContext context) async {
    final colors = context.appColors;
    final confirmed = await CustomConfirmDialog.show(
      context,
      icon: Icons.logout_rounded,
      title: 'profile.logoutTitle'.tr(),
      message: 'profile.logoutMessage'.tr(),
      confirmText: 'profile.logout'.tr(),
      confirmColor: colors.secondary,
      confirmTextColor: context.colorScheme.onSecondary,
    );
    if (!confirmed || !context.mounted) return;

    final router = GoRouter.of(context);
    // TODO: إبلاغ الـ API بالخروج لما يجهز
    await Session.clear();
    await DI.resetGetItAndInit();
    router.go(AppRouter.login);
  }

  /// الحذف طلب بيروح للإدارة، والحساب بيفضل شغال لحد ما يتعتمد
  Future<void> _requestDeletion(BuildContext context) async {
    final colors = context.appColors;
    final confirmed = await CustomConfirmDialog.show(
      context,
      icon: Icons.person_remove_outlined,
      iconColor: colors.error,
      iconBackgroundColor: colors.errorContainer,
      title: 'profile.deleteTitle'.tr(),
      message: 'profile.deleteMessage'.tr(),
      confirmText: 'profile.deleteConfirm'.tr(),
      confirmColor: colors.error,
      confirmTextColor: context.colorScheme.onError,
    );
    if (!confirmed || !context.mounted) return;
    // TODO: إرسال طلب الحذف للـ API
    context.showSuccessMessage('profile.deleteRequested'.tr());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const arrow = _RowTrailing();

    return _ListCard(
      children: [
        CustomListTile(
          text: 'profile.privacyPolicy'.tr(),
          icon: Icons.verified_user_outlined,
          trailing: arrow,
          onTap: () =>
              context.push(AppRouter.policy, extra: PolicyType.privacy),
        ),
        CustomListTile(
          text: 'profile.terms'.tr(),
          icon: Icons.description_outlined,
          trailing: arrow,
          onTap: () => context.push(AppRouter.policy, extra: PolicyType.terms),
        ),
        CustomListTile(
          text: 'profile.contactUs'.tr(),
          icon: Icons.headset_mic_outlined,
          trailing: arrow,
          onTap: () => context.push(AppRouter.contactUs),
        ),
        CustomListTile(
          text: 'profile.deleteAccount'.tr(),
          icon: Icons.delete_outline_rounded,
          iconColor: colors.error,
          textColor: colors.error,
          trailing: arrow,
          onTap: () => _requestDeletion(context),
        ),
        CustomListTile(
          text: 'profile.logout'.tr(),
          icon: Icons.logout_rounded,
          trailing: arrow,
          showDivider: false,
          onTap: () => _logout(context),
        ),
      ],
    );
  }
}
