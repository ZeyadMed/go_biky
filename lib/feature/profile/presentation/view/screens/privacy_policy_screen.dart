import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/helpers/url_launcher_helper.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/profile/data/model/policy_page_model.dart';
import 'package:go_biky/feature/profile/presentation/view_model/cubit/privacy_policy_cubit.dart';

/// سياسة الخصوصية زي ما الإدارة كاتباها، والمحتوى HTML
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final _cubit = getIt<PrivacyPolicyCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getPrivacyPolicy();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PrivacyPolicyCubit, BaseState<PolicyPageModel>>(
          bloc: _cubit,
          builder: (context, state) {
            final page = state.data;
            final updatedAt = page?.updatedAtUtc;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 0),
                  child: ResponsiveCenter(
                    child: CustomBackHeader(
                      title: page?.title ?? 'profile.privacyPolicy'.tr(),
                      subtitle: updatedAt == null
                          ? null
                          : 'policy.lastUpdated'.tr(
                              args: [context.formatDate(updatedAt.toLocal())],
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: switch (page) {
                    null when state.isFailure => FailureWidget(
                      errorMessage:
                          state.errorMessage ??
                          'common.somethingWentWrong'.tr(),
                      onRefresh: _cubit.getPrivacyPolicy,
                    ),
                    null => const _Loading(),
                    final page => RefreshIndicator(
                      color: colors.primary,
                      onRefresh: _cubit.getPrivacyPolicy,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsetsDirectional.fromSTEB(
                          20.w,
                          16.h,
                          20.w,
                          32.h,
                        ),
                        child: ResponsiveCenter(
                          child: page.isEmpty
                              ? const _Empty()
                              : _Content(html: page.html),
                        ),
                      ),
                    ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// النص بألوان الثيم: الفقرات `textSecondary` والعناوين `textPrimary`،
/// واللينكات بلون البراند وبتتفتح في المتصفح
class _Content extends StatelessWidget {
  const _Content({required this.html});

  final String html;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final headingColor = _cssColor(colors.textPrimary);

    return HtmlWidget(
      _withoutInlineColors(html),
      textStyle: context.textTheme.bodySmall?.copyWith(
        fontSize: 13.sp,
        color: colors.textSecondary,
        height: 1.8,
      ),
      customStylesBuilder: (element) => switch (element.localName) {
        'h1' ||
        'h2' ||
        'h3' ||
        'h4' ||
        'h5' ||
        'h6' ||
        'strong' ||
        'b' => {'color': headingColor},
        _ => null,
      },
      onTapUrl: UrlLauncherHelper.openUrl,
    );
  }
}

/// الألوان اللي جاية من محرر الإدارة (زي color: #000) بتختفي في الـ dark
/// mode، فبنشيلها من الـ style والنص ياخد ألوان الثيم
String _withoutInlineColors(String html) => html.replaceAllMapped(
  RegExp(r'''style\s*=\s*(["'])(.*?)\1''', caseSensitive: false, dotAll: true),
  (match) {
    final style = match[2]!.replaceAll(
      RegExp(
        r'(?<![\w-])(?:background(?:-color)?|color)\s*:[^;]*;?',
        caseSensitive: false,
      ),
      '',
    );
    return 'style=${match[1]}$style${match[1]}';
  },
);

/// الـ HtmlWidget بياخد الألوان كـ CSS
String _cssColor(Color color) =>
    'rgb(${(color.r * 255).round()}, ${(color.g * 255).round()}, '
    '${(color.b * 255).round()})';

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    Widget paragraph() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(height: 18.h, width: 160.w),
        Gaps.v(12.h),
        ShimmerBox(height: 13.h, width: double.infinity),
        Gaps.v(8.h),
        ShimmerBox(height: 13.h, width: double.infinity),
        Gaps.v(8.h),
        ShimmerBox(height: 13.h, width: 220.w),
      ],
    );

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 32.h),
      child: ResponsiveCenter(
        child: AppShimmer(
          child: Column(
            children: [
              paragraph(),
              Gaps.v(24.h),
              paragraph(),
              Gaps.v(24.h),
              paragraph(),
            ],
          ),
        ),
      ),
    );
  }
}

/// الإدارة لسه مانشرتش المحتوى
class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(top: 80.h),
      child: Column(
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 56.r,
            color: colors.textHint,
          ),
          Gaps.v(12.h),
          Text(
            'policy.empty'.tr(),
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
