import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/app_input_decoration.dart';

/// حقل الإدخال الأساسي في التطبيق. `hintText` و `labelText` بيتبعتوا مترجمين.
/// لو `obscureText` و مفيش `suffix` بيظهر زرار إظهار/إخفاء، ولو
/// `onDateSelected` متبعت الحقل بيفتح date picker
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onDateSelected,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.borderRadius,
    this.verticalPadding,
    this.style,
    this.focusNode,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? labelText;

  /// بيتبعت من بره لما الشاشة عايزة تفتح الكيبورد على الخانة دي
  final FocusNode? focusNode;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final ValueChanged<DateTime>? onDateSelected;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final double? borderRadius;
  final double? verticalPadding;
  final TextStyle? style;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _hidden;

  bool get _isDateField => widget.onDateSelected != null;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent changed the obscureText prop, update internal hidden state
    if (oldWidget.obscureText != widget.obscureText) {
      _hidden = widget.obscureText;
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    // الشاشة ممكن تكون اتقفلت والـ picker مفتوح
    if (pickedDate == null || !mounted) return;

    // DD-MM-YYYY with leading zeros for day and month
    final day = pickedDate.day.toString().padLeft(2, '0');
    final month = pickedDate.month.toString().padLeft(2, '0');
    widget.controller.text = '$day-$month-${pickedDate.year}';
    widget.onDateSelected!(pickedDate);
  }

  Widget? _defaultSuffix(BuildContext context) {
    if (widget.obscureText) {
      return IconButton(
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 22.r,
        ),
      );
    }
    if (_isDateField) return Icon(Icons.calendar_today_outlined, size: 20.r);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: widget.labelText,
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        readOnly: _isDateField || widget.readOnly,
        enabled: widget.enabled,
        obscureText: _hidden,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        inputFormatters: widget.inputFormatters,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        onTap: _isDateField ? _selectDate : widget.onTap,
        style: widget.style ?? context.textTheme.bodyMedium,
        decoration: AppInputDecoration.of(
          context,
          hintText: widget.hintText,
          prefixIcon: widget.prefix,
          suffixIcon: widget.suffix ?? _defaultSuffix(context),
          borderRadius: widget.borderRadius,
          contentPadding: widget.verticalPadding == null
              ? null
              : EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: widget.verticalPadding!,
                ),
        ),
      ),
    );
  }
}
