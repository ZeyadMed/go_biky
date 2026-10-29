import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/helpers/url_launcher_helper.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/profile/data/model/contact_model.dart';
import 'package:go_biky/feature/profile/presentation/view_model/cubit/contacts_cubit.dart';
import 'package:go_biky/feature/profile/presentation/view_model/cubit/profile_cubit.dart';

/// تواصل معنا: أرقام الاتصال والواتساب زي ما الإدارة ضايفاها
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 0),
              child: ResponsiveCenter(
                child: CustomBackHeader(title: 'contactUs.title'.tr()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 24.h),
                child: ResponsiveCenter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'contactUs.headline'.tr(),
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                      ),
                      Gaps.v(16.h),
                      BlocBuilder<ContactsCubit, BaseState<ContactModel>>(
                        bloc: _contactsCubit,
                        builder: (context, state) => _Contacts(
                          state: state,
                          onRetry: _contactsCubit.getContacts,
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

/// بينسخ الرقم ويعرض رسالة، وده بالضغطة الطويلة
void _copy(BuildContext context, String value) {
  Clipboard.setData(ClipboardData(text: value.replaceAll(' ', '')));
  context.showSuccessMessage(
    'contactUs.copied'.tr(args: [context.localizeDigits(value)]),
  );
}

/// لو مفيش تطبيق يفتح الرقم (زي تابلت من غير شريحة أو واتساب مش متسطب
/// ومفيش متصفح)، بننسخه عشان الضغطة ماتضيعش
Future<void> _launchOrCopy(
  BuildContext context,
  Future<bool> launch,
  String value,
) async {
  if (await launch || !context.mounted) return;
  Clipboard.setData(ClipboardData(text: value.replaceAll(' ', '')));
  context.showErrorMessage(
    'contactUs.cannotOpen'.tr(args: [context.localizeDigits(value)]),
  );
}

/// الشات بيتفتح ومعاه رسالة جاهزة فيها اسم الراكب لو بياناته وصلت
void _openWhatsApp(BuildContext context, String phone) {
  final name = getIt<ProfileCubit>().state.data?.fullName;
  final message = name == null || name.isEmpty
      ? 'contactUs.whatsappMessageNoName'.tr()
      : 'contactUs.whatsappMessage'.tr(args: [name]);
  _launchOrCopy(
    context,
    UrlLauncherHelper.whatsApp(phone, message: message),
    phone,
  );
}

/// الأرقام بترتيب الإدارة: اسم كل رقم فوق، وتحته كارت اتصال وكارت واتساب
class _Contacts extends StatelessWidget {
  const _Contacts({required this.state, required this.onRetry});

  final BaseState<ContactModel> state;
  final RefreshCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final contacts = state.items;

    if (contacts.isEmpty) {
      if (state.isInitial || state.isLoading) {
        final card = Expanded(
          child: ShimmerBox(
            height: 104.h,
            borderRadius: BorderRadius.circular(20.r),
          ),
        );
        return AppShimmer(child: Row(children: [card, Gaps.h(12.w), card]));
      }

      if (state.isFailure) {
        return FailureWidget(
          compact: true,
          errorMessage: 'contactUs.loadFailed'.tr(),
          onRefresh: onRetry,
        );
      }

      return Text(
        'contactUs.noContacts'.tr(),
        style: context.textTheme.bodySmall?.copyWith(
          color: colors.textSecondary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, contact) in contacts.indexed) ...[
          if (index > 0) Gaps.v(16.h),
          _ContactChannels(contact: contact),
        ],
      ],
    );
  }
}

class _ContactChannels extends StatelessWidget {
  const _ContactChannels({required this.contact});

  final ContactModel contact;

  @override
  Widget build(BuildContext context) {
    final phone = contact.phoneNumber;
    final whatsApp = contact.whatsAppNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (contact.name.isNotEmpty) ...[
          Text(
            contact.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Gaps.v(8.h),
        ],
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (phone.isNotEmpty)
                Expanded(
                  child: _ChannelCard(
                    icon: Icons.phone_outlined,
                    label: 'contactUs.call'.tr(),
                    value: phone,
                    onTap: () => _launchOrCopy(
                      context,
                      UrlLauncherHelper.call(phone),
                      phone,
                    ),
                  ),
                ),
              if (phone.isNotEmpty && whatsApp.isNotEmpty) Gaps.h(12.w),
              if (whatsApp.isNotEmpty)
                Expanded(
                  child: _ChannelCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'contactUs.whatsapp'.tr(),
                    value: whatsApp,
                    onTap: () => _openWhatsApp(context, whatsApp),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.bgSecondary,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _copy(context, value),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.primary, size: 24.r),
              Gaps.v(10.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                context.localizeDigits(value),
                maxLines: 1,
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: 11.sp,
                  color: colors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
