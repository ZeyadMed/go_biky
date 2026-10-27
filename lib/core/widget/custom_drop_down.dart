import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/app_input_decoration.dart';

/// قايمة اختيار بنفس شكل الحقول، وبتشتغل جوه Form (فيها `validator`).
/// `hint` و `labelText` و `itemLabel` بيرجعوا نص مترجم
class CustomDropDown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? labelText;
  final FormFieldValidator<T>? validator;

  const CustomDropDown({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hint,
    this.labelText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;

    return LabeledField(
      label: labelText,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        items: [
          for (final item in items)
            DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: onChanged,
        validator: validator,
        hint: hint == null
            ? null
            : Text(
                hint!,
                style: textTheme.bodyMedium?.copyWith(color: colors.textHint),
              ),
        style: textTheme.bodyMedium,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: colors.textSecondary,
        ),
        dropdownColor: colors.bgSecondary,
        borderRadius: BorderRadius.circular(14.r),
        decoration: AppInputDecoration.of(
          context,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
}
