import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_router/go_router.dart';

// TODO: بيانات التواصل بتيجي من الـ API
const _companyName = 'مدار';
const _workingHours = 'السبت–الخميس، ٨ صباحاً–٨ مساءً';
const _phone = '011 500 2040';
const _whatsapp = '055 008 2040';
const _email = 'support@madar.example';
const _centerName = 'مركز مدار • الياسمين';
const _centerAddress = 'طريق أنس بن مالك، حي الياسمين، الرياض';
const String? _centerMapImage = null;

/// تواصل معنا: طرق التواصل ومكان المركز، ورسالة للدعم
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    // TODO: إرسال الرسالة للدعم لما الـ API يجهز
    context.showSuccessMessage('contactUs.sent'.tr());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;

    return DismissKeyboardWrapper(
      child: Scaffold(
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
                  child: ResponsiveCenter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'contactUs.headline'.tr(),
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                          ),
                        ),
                        Text(
                          _workingHours,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            color: colors.textSecondary,
                          ),
                        ),
                        Gaps.v(16.h),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _ChannelCard(
                                  icon: Icons.phone_outlined,
                                  label: 'contactUs.call'.tr(
                                    args: [_companyName],
                                  ),
                                  value: _phone,
                                ),
                              ),
                              Gaps.h(12.w),
                              Expanded(
                                child: _ChannelCard(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label: 'contactUs.whatsapp'.tr(),
                                  value: _whatsapp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gaps.v(12.h),
                        const _EmailCard(),
                        Gaps.v(12.h),
                        const _CenterCard(),
                        Gaps.v(20.h),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextField(
                                controller: _subjectController,
                                labelText: 'contactUs.subjectLabel'.tr(),
                                hintText: 'contactUs.subjectHint'.tr(),
                                textInputAction: TextInputAction.next,
                              ),
                              Gaps.v(14.h),
                              CustomTextField(
                                controller: _messageController,
                                labelText: 'contactUs.messageLabel'.tr(),
                                hintText: 'contactUs.messageHint'.tr(),
                                keyboardType: TextInputType.multiline,
                                minLines: 3,
                                maxLines: 6,
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'contactUs.messageRequired'.tr()
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 8.h, 20.w, 16.h),
                child: ResponsiveCenter(
                  child: CustomButton(
                    title: 'contactUs.send'.tr(),
                    onPressed: _submit,
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

/// بينسخ الرقم أو البريد ويعرض رسالة.
// TODO: الاتصال وفتح واتساب والبريد على طول محتاجين url_launcher
void _copy(BuildContext context, String value) {
  Clipboard.setData(ClipboardData(text: value.replaceAll(' ', '')));
  context.showSuccessMessage(
    'contactUs.copied'.tr(args: [context.localizeDigits(value)]),
  );
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.bgSecondary,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: () => _copy(context, value),
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

class _EmailCard extends StatelessWidget {
  const _EmailCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.bgSecondary,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () => _copy(context, _email),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                Icons.mail_outline_rounded,
                color: colors.primary,
                size: 22.r,
              ),
              Gaps.h(10.w),
              Expanded(
                child: Text(
                  'contactUs.email'.tr(args: [_email]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
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

/// صورة الخريطة واسم المركز وعنوانه، ولحد ما الصورة تيجي بيظهر دبوس مكانها
class _CenterCard extends StatelessWidget {
  const _CenterCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 5,
            child: FlexibleImage(
              source: _centerMapImage,
              placeholder: ColoredBox(
                color: colors.bgTertiary,
                child: Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    color: colors.primary,
                    size: 34.r,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _centerName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _centerAddress,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    color: colors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
