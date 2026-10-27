import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// خانة البحث: أيقونة بحث + حقل + زرار مسح (و زرار فلتر لو `onFilterTap`
/// متبعت)، وخط تحت بيتلون وقت الكتابة. `hintText` بيتبعت مترجم، ولو مش
/// متبعت بيبقى "بحث"
class CustomSearchWidget extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSearchTap;
  final VoidCallback? onFilterTap;
  final String? hintText;
  final bool clearSearch;
  final TextEditingController? controller;

  /// خانة بخلفية الكروت وحدود بتتلون وقت الكتابة بدل الخط اللي تحت،
  /// وزرار المسح بيظهر بس لما يكون فيه نص
  final bool filled;

  const CustomSearchWidget({
    super.key,
    this.onChanged,
    this.onSearchTap,
    this.onFilterTap,
    this.hintText,
    this.controller,
    this.clearSearch = true,
    this.filled = false,
  });

  @override
  State<CustomSearchWidget> createState() => _CustomSearchWidgetState();
}

class _CustomSearchWidgetState extends State<CustomSearchWidget> {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final filled = widget.filled;
    final iconColor = filled ? colors.textHint : colors.primary;
    final iconDensity = filled ? VisualDensity.compact : null;

    final field = Row(
      children: [
        IconButton(
          visualDensity: iconDensity,
          icon: Icon(Icons.search, color: iconColor, size: 24.r),
          onPressed: () => widget.onSearchTap?.call(_controller.text),
        ),
        Gaps.h(8.w),
        Expanded(
          child: TextField(
            focusNode: _focusNode,
            controller: _controller,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSearchTap,
            textInputAction: TextInputAction.search,
            style: context.textTheme.bodyLarge,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
              hintText: widget.hintText ?? 'common.search'.tr(),
            ),
          ),
        ),
        Gaps.h(8.w),
        if (widget.clearSearch)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (filled && value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                visualDensity: iconDensity,
                icon: Icon(Icons.close, color: iconColor, size: 22.r),
                onPressed: _clear,
              );
            },
          ),
        if (widget.onFilterTap != null)
          IconButton(
            icon: Icon(Icons.tune_rounded, color: colors.primary, size: 22.r),
            onPressed: widget.onFilterTap,
          ),
      ],
    );

    if (filled) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _hasFocus ? colors.primary : colors.bgSecondary,
          ),
        ),
        child: field,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        field,
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          height: 1,
          color: _hasFocus ? colors.primary : colors.border,
        ),
      ],
    );
  }
}
