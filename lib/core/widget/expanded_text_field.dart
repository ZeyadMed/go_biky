import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/custom_text_field.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// كارت بيفتح ويقفل وجواه حقل (زي "عندك كود خصم؟"). النصوص بتتبعت مترجمة
class ExpandableTextField extends StatefulWidget {
  final String collapsedText;
  final String expandedLabel;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? textEditingController;
  final Color? backgroundColor;
  final Color? borderColor;

  final Duration animationDuration;

  const ExpandableTextField({
    super.key,
    required this.collapsedText,
    required this.expandedLabel,
    required this.hintText,
    this.onChanged,
    this.textEditingController,
    this.backgroundColor,
    this.borderColor,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<ExpandableTextField> createState() => _ExpandableTextFieldState();
}

class _ExpandableTextFieldState extends State<ExpandableTextField> {
  bool isExpanded = false;
  late final TextEditingController _controller =
      widget.textEditingController ?? TextEditingController();

  @override
  void dispose() {
    if (widget.textEditingController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AnimatedSize(
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
      alignment: AlignmentDirectional.topCenter,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? colors.bgSecondary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: widget.borderColor ?? colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الضغط على العنوان بس هو اللي بيفتح ويقفل، عشان الضغط على
            // الحقل مايقفلوش
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleExpand,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isExpanded ? widget.expandedLabel : widget.collapsedText,
                      style: context.textTheme.titleSmall,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colors.textSecondary,
                    size: 24.r,
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              Gaps.v(8.h),
              CustomTextField(
                hintText: widget.hintText,
                controller: _controller,
                onChanged: widget.onChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
