import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/app_input_decoration.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

/// حقل رقم الموبايل بكود الدولة، بنفس شكل CustomTextField.
/// `hintText` و `labelText` بيتبعتوا مترجمين
class CustomPhoneField extends StatelessWidget {
  final void Function(PhoneNumber)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;

  /// الدول المسموح بيها بالـ ISO code، وأول واحدة هي الافتراضية.
  /// الافتراضي ليبيا بس
  final List<String> countryCodes;

  const CustomPhoneField({
    super.key,
    this.onChanged,
    this.validator,
    this.controller,
    this.hintText,
    this.labelText,
    this.countryCodes = const ['LY'],
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final allowedCountries = countries
        .where((country) => countryCodes.contains(country.code))
        .toList();

    // الباكدج مابتندهش الـ validator بتاعنا وقت validate() لو الحقل فاضي
    // ومحدش لمسه، فالحقل كان بيعدي فاضي. الـ FormField ده بيندهه دايماً
    // وبيعرض الغلط في نفس مكان غلط الباكدج. الرقم الناقص بيمسكه فحص الطول
    // اللي في الباكدج (9 أرقام لليبيا)
    return LabeledField(
      label: labelText,
      child: FormField<String>(
        initialValue: controller?.text ?? '',
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        builder: (field) => Directionality(
          textDirection: TextDirection.ltr,
          child: IntlPhoneField(
            controller: controller,
            initialCountryCode: countryCodes.first,
            countries: allowedCountries,
            showDropdownIcon: allowedCountries.length > 1,
            style: textTheme.bodyMedium,
            dropdownTextStyle: textTheme.bodyMedium,
            dropdownDecoration: const BoxDecoration(),
            disableLengthCheck: false,
            disableAutoFillHints: false,
            keyboardType: TextInputType.phone,
            inputFormatters: [_PhoneDigitsFormatter()],
            languageCode: context.locale.languageCode,
            pickerDialogStyle: PickerDialogStyle(
              backgroundColor: colors.bgSecondary,
              countryNameStyle: textTheme.titleMedium,
              countryCodeStyle: textTheme.titleSmall,
              searchFieldPadding: EdgeInsets.all(5.r),
              searchFieldInputDecoration: AppInputDecoration.of(
                context,
                hintText: 'common.search'.tr(),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
            invalidNumberMessage: 'common.invalidPhoneNumber'.tr(),
            onChanged: (phone) {
              field.didChange(phone.number);
              onChanged?.call(phone);
            },
            decoration: AppInputDecoration.of(
              context,
              hintText: hintText ?? 'common.phoneHint'.tr(),
              errorText: field.errorText,
            ),
          ),
        ),
      ),
    );
  }
}

/// الكيبورد العربي بيكتب ٠-٩، والباكدج بيفحص الطول بـ int.tryParse اللي
/// مابيفهمهاش فالرقم الناقص كان بيعدي. فبنحولها لإنجليزي ونشيل أي حاجة
/// غير الأرقام، ونشيل الصفر اللي في الأول عشان 091... تبقى 91... بدل ما
/// الحد الأقصى (9) يقص آخر رقم
class _PhoneDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    for (final rune in newValue.text.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.writeCharCode(rune);
      } else if (rune >= 0x660 && rune <= 0x669) {
        buffer.writeCharCode(rune - 0x660 + 0x30);
      } else if (rune >= 0x6F0 && rune <= 0x6F9) {
        buffer.writeCharCode(rune - 0x6F0 + 0x30);
      }
    }
    final digits = buffer.toString().replaceFirst(RegExp(r'^0+'), '');
    if (digits == newValue.text) return newValue;

    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
