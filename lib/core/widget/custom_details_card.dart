import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// كارت فيه صفوف عنوان وقيمة (تاريخ، قراءة عداد، حالة...): العنوان في
/// البداية والقيمة في الآخر، وكلهم بيتبعتوا مترجمين
class CustomDetailsCard extends StatelessWidget {
  const CustomDetailsCard({
    super.key,
    required this.rows,
    this.header,
    this.footer,
  });

  final List<({String label, String value})> rows;

  /// بيظهر فوق الصفوف (زي رقم الطلب وحالته)
  final Widget? header;

  /// بيظهر تحت الصفوف بعد خط فاصل (زي الإجمالي)
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: context.appColors.bgSecondary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 20.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header case final header?) ...[header, Gaps.v(12.h)],
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Gaps.v(10.h),
            _DetailRow(label: rows[i].label, value: rows[i].value),
          ],
          if (footer case final footer?) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Divider(
                height: 1,
                thickness: 1,
                color: context.appColors.border,
              ),
            ),
            footer,
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    // القيمة بعرضها الطبيعي لحد ٦٠٪ من الصف، ولو أطول بتنزل سطر تاني بدل
    // ما تعمل overflow، والعنوان بياخد الباقي
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          Gaps.h(12.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
