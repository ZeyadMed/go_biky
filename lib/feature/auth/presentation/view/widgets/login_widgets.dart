import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/style/assets.dart';
import 'package:go_biky/feature/profile/data/model/contact_model.dart';
import 'package:go_biky/feature/profile/presentation/view/widgets/contact_channels.dart';
import 'package:go_biky/feature/profile/presentation/view_model/cubit/contacts_cubit.dart';

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

/// أرقام الشركة (اتصال وواتساب) جوه dialog نسيت كلمة المرور، لأن الحساب
/// الشركة هي اللي بتنشئه ومفيش استرجاع من التطبيق
class ForgotPasswordContacts extends StatefulWidget {
  const ForgotPasswordContacts({super.key, this.phone});

  /// رقم السواق لو كتبه صح، بيتكتب في رسالة الواتساب عشان الشركة تعرف
  /// الحساب من غير ما تسأل
  final String? phone;

  @override
  State<ForgotPasswordContacts> createState() => _ForgotPasswordContactsState();
}

class _ForgotPasswordContactsState extends State<ForgotPasswordContacts> {
  final _contactsCubit = getIt<ContactsCubit>();

  @override
  void initState() {
    super.initState();
    _contactsCubit.getContacts();
  }

  @override
  void dispose() {
    _contactsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.phone;

    return BlocBuilder<ContactsCubit, BaseState<ContactModel>>(
      bloc: _contactsCubit,
      builder: (context, state) => ContactChannelsList(
        state: state,
        onRetry: _contactsCubit.getContacts,
        whatsAppMessage: phone == null
            ? 'auth.forgotPasswordWhatsapp'.tr()
            : 'auth.forgotPasswordWhatsappWithPhone'.tr(args: [phone]),
        cardColor: context.appColors.bgTertiary,
      ),
    );
  }
}
