import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/style/assets.dart';
import 'package:go_biky/core/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    // TODO: ربط الـ LoginCubit لما الـ API يجهز
  }

  String? _required(String? value, String messageKey) =>
      (value == null || value.trim().isEmpty) ? messageKey.tr() : null;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: ResponsiveCenter(
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Header(),
                    Gaps.v(12.h),
                    const _LogoCard(),
                    Gaps.v(24.h),
                    Text(
                      'auth.welcomeBack'.tr(),
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Gaps.v(4.h),
                    Text(
                      'auth.subtitle'.tr(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    Gaps.v(24.h),
                    _FieldLabel('auth.username'.tr()),
                    Gaps.v(8.h),
                    _AuthTextField(
                      controller: _usernameController,
                      hint: 'auth.usernameHint'.tr(),
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      validator: (value) =>
                          _required(value, 'auth.usernameRequired'),
                      suffixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: colors.textSecondary,
                        size: 22.r,
                      ),
                    ),
                    Gaps.v(16.h),
                    _FieldLabel('auth.password'.tr()),
                    Gaps.v(8.h),
                    _AuthTextField(
                      controller: _passwordController,
                      hint: 'auth.passwordHint'.tr(),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) =>
                          _required(value, 'auth.passwordRequired'),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colors.textSecondary,
                          size: 22.r,
                        ),
                      ),
                    ),
                    Gaps.v(24.h),
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: Size.fromHeight(52.h),
                        backgroundColor: colors.primary,
                        foregroundColor: context.colorScheme.onPrimary,
                        textStyle: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text('auth.login'.tr()),
                    ),
                    Gaps.v(12.h),
                    Center(
                      child: TextButton(
                        // TODO: فتح وسيلة التواصل مع الشركة لما تتحدد
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: colors.primary,
                          textStyle: context.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(
                          'auth.forgotPassword'.tr(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Gaps.v(12.h),
                    const _InfoCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// اسم التطبيق في البداية و"مساحة الراكب" في الآخر — بيقلبوا مع اتجاه اللغة
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'splash.appName'.tr(),
            style: context.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          'auth.riderSpace'.tr(),
          style: context.textTheme.labelMedium?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// مكان صورة الموتوسيكل في الديزاين — بيعرض لوجو التطبيق
class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.h,
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: context.appColors.bgSecondary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Image.asset(Assets.assetsImagesGoBikyLogo, fit: BoxFit.contain),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: context.textTheme.labelLarge);
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hint,
    required this.suffixIcon,
    this.validator,
    this.obscureText = false,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final Widget suffixIcon;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: context.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: colors.bgTertiary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        suffixIcon: suffixIcon,
        enabledBorder: border(colors.border),
        focusedBorder: border(colors.primary, width: 1.5),
        errorBorder: border(colors.error),
        focusedErrorBorder: border(colors.error, width: 1.5),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

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
