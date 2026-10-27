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

  const CustomSearchWidget({
    super.key,
    this.onChanged,
    this.onSearchTap,
    this.onFilterTap,
    this.hintText,
    this.controller,
    this.clearSearch = true,
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.search, color: colors.primary, size: 24.r),
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
              IconButton(
                icon: Icon(Icons.close, color: colors.primary, size: 22.r),
                onPressed: _clear,
              ),
            if (widget.onFilterTap != null)
              IconButton(
                icon: Icon(Icons.tune_rounded, color: colors.primary, size: 22.r),
                onPressed: widget.onFilterTap,
              ),
          ],
        ),
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
