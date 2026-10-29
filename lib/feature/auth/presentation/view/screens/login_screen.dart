import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/auth/data/model/user_token.dart';
import 'package:go_biky/feature/auth/presentation/view/widgets/login_widgets.dart';
import 'package:go_biky/feature/auth/presentation/view_model/cubit/login_cubit.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cubit = getIt<LoginCubit>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_cubit.state.isLoading || !_formKey.currentState!.validate()) return;
    _cubit.login(
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _onStateChanged(BuildContext context, BaseState<UserToken> state) {
    if (state.isSuccess) {
      // go مش push، عشان الرجوع مايفتحش اللوجين تاني
      context.go(AppRouter.initialRoute);
    } else if (state.isFailure) {
      context.showErrorMessage(
        state.errorMessage ?? 'common.somethingWentWrong'.tr(),
      );
    }
  }

  String? _required(String? value, String messageKey) =>
      (value == null || value.trim().isEmpty) ? messageKey.tr() : null;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<LoginCubit, BaseState<UserToken>>(
      bloc: _cubit,
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStateChanged,
      child: Scaffold(
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
                      const LoginHeader(),
                      Gaps.v(12.h),
                      const LoginLogoCard(),
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
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'auth.phone'.tr(),
                        hintText: 'auth.phoneHint'.tr(),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        validator: (value) =>
                            _required(value, 'auth.phoneRequired'),
                        suffix: Icon(Icons.phone_outlined, size: 22.r),
                      ),
                      Gaps.v(16.h),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'auth.password'.tr(),
                        hintText: 'auth.passwordHint'.tr(),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                        validator: (value) =>
                            _required(value, 'auth.passwordRequired'),
                      ),
                      Gaps.v(24.h),
                      BlocBuilder<LoginCubit, BaseState<UserToken>>(
                        bloc: _cubit,
                        buildWhen: (previous, current) =>
                            previous.isLoading != current.isLoading,
                        builder: (context, state) => CustomButton(
                          title: 'auth.login'.tr(),
                          isLoading: state.isLoading,
                          onPressed: _submit,
                        ),
                      ),
                      Gaps.v(12.h),
                      Center(
                        child: CustomButton.text(
                          title: 'auth.forgotPassword'.tr(),
                          // TODO: فتح وسيلة التواصل مع الشركة لما تتحدد
                          onPressed: () {},
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Gaps.v(12.h),
                      const LoginInfoCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
