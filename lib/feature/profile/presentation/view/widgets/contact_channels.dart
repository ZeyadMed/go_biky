import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/helpers/url_launcher_helper.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/profile/data/model/contact_model.dart';

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

/// الأرقام بترتيب الإدارة: اسم كل رقم فوق، وتحته كارت اتصال وكارت واتساب.
/// بتتعرض في تواصل معنا وفي dialog نسيت كلمة المرور
class ContactChannelsList extends StatelessWidget {
  const ContactChannelsList({
    super.key,
    required this.state,
    required this.onRetry,
    this.whatsAppMessage,
    this.cardColor,
  });

  final BaseState<ContactModel> state;
  final RefreshCallback onRetry;

  /// بتتكتب جاهزة في شات الواتساب
  final String? whatsAppMessage;

  /// من غيره `bgSecondary`. الـ dialog خلفيته `bgSecondary`، فبيبعت لون
  /// تاني عشان الكروت تبان
  final Color? cardColor;

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
          _ContactChannels(
            contact: contact,
            whatsAppMessage: whatsAppMessage,
            cardColor: cardColor ?? colors.bgSecondary,
          ),
        ],
      ],
    );
  }
}

class _ContactChannels extends StatelessWidget {
  const _ContactChannels({
    required this.contact,
    required this.whatsAppMessage,
    required this.cardColor,
  });

  final ContactModel contact;
  final String? whatsAppMessage;
  final Color cardColor;

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
                    color: cardColor,
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
                    color: cardColor,
                    onTap: () => _launchOrCopy(
                      context,
                      UrlLauncherHelper.whatsApp(
                        whatsApp,
                        message: whatsAppMessage,
                      ),
                      whatsApp,
                    ),
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
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: color,
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
