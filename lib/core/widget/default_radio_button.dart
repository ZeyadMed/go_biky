import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// صف اختيار: دايرة راديو + عنوان + أيقونة اختيارية (svg أو صورة).
/// `title` بيتبعت مترجم. `moveToEnd` بيحط الدايرة في الآخر،
/// و`moveIconToStart` بيحط الأيقونة قبل العنوان
class DefaultRadioButton extends StatelessWidget {
  final Color? borderColor;
  final Color? fillColor;
  final double? fillRadios;
  final String title;
  final TextStyle? titleStyle;
  final String iconPath;
  final Color? iconColor;
  final Color? containerBorderColor;
  final Color? backgroundColor;
  final Widget? titleWidget;
  final void Function()? onTap;
  final void Function()? iconOnTap;
  final bool selected;
  final bool moveToEnd;
  final bool moveIconToStart;
  final bool withMargin;
  final bool isExpanded;
  const DefaultRadioButton({
    super.key,
    this.borderColor,
    this.fillColor,
    this.fillRadios,
    this.title = '',
    this.titleStyle,
    this.iconPath = '',
    this.titleWidget,
    this.iconColor,
    this.onTap,
    required this.selected,
    this.iconOnTap,
    this.containerBorderColor,
    this.moveToEnd = false,
    this.withMargin = false,
    this.moveIconToStart = false,
    this.isExpanded = true,
    this.backgroundColor,
  });

  Widget _radio(BuildContext context) {
    final colors = context.appColors;
    final dotSize = fillRadios ?? 15.r;

    return Container(
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? colors.primary),
        shape: BoxShape.circle,
      ),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 500),
        crossFadeState: selected
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstChild: Container(
          height: dotSize,
          width: dotSize,
          decoration: BoxDecoration(
            color: fillColor ?? colors.primary,
            shape: BoxShape.circle,
          ),
        ),
        secondChild: SizedBox.square(dimension: dotSize),
      ),
    );
  }

  Widget _icon() {
    final Widget icon = iconPath.toLowerCase().endsWith('.svg')
        ? SvgPicture.asset(
            iconPath,
            width: 30.r,
            height: 30.r,
            colorFilter: iconColor == null
                ? null
                : ColorFilter.mode(iconColor!, BlendMode.srcIn),
          )
        : Image.asset(iconPath, width: 30.r, height: 30.r, color: iconColor);

    return InkWell(onTap: iconOnTap, child: icon);
  }

  @override
  Widget build(BuildContext context) {
    final hasIcon = iconPath.isNotEmpty;
    final titleText = Text(
      title,
      style: titleStyle ?? context.textTheme.titleMedium,
    );

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        margin: withMargin
            ? EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w)
            : null,
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: containerBorderColor != null
              ? Border.all(color: containerBorderColor!)
              : null,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!moveToEnd) ...[_radio(context), Gaps.h(10.w)],
            if (hasIcon && moveIconToStart) ...[_icon(), Gaps.h(10.w)],
            if (title.isNotEmpty)
              isExpanded
                  ? Expanded(child: titleText)
                  : Flexible(child: titleText),
            ?titleWidget,
            if (hasIcon && !moveIconToStart) _icon(),
            if (moveToEnd) ...[Gaps.h(10.w), _radio(context)],
          ],
        ),
      ),
    );
  }
}

/// DefaultRadioButton جوه كارت بحدود
class BorderRadioButton extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final Widget? titleWidget;
  final bool selected;
  final bool isExpanded;
  final VoidCallback? onTap;

  const BorderRadioButton({
    super.key,
    required this.title,
    this.titleStyle,
    this.titleWidget,
    this.isExpanded = false,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        border: Border.all(color: context.appColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: DefaultRadioButton(
        title: title,
        titleStyle: titleStyle,
        titleWidget: titleWidget,
        selected: selected,
        isExpanded: isExpanded,
        onTap: onTap,
      ),
    );
  }
}
