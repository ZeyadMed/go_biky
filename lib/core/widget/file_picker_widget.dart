import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/helpers/image_picker_helper.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// كارت لاختيار صورة (كاميرا أو معرض) وبيعرضها بعد الاختيار.
/// `headerText` و `footerText` بيتبعتوا مترجمين
class FilePickerWidget extends StatefulWidget {
  final String headerText;
  final String footerText;
  final ValueChanged<File?> onFilePicked;
  final File? selectedFile;

  const FilePickerWidget({
    super.key,
    required this.headerText,
    required this.footerText,
    required this.onFilePicked,
    this.selectedFile,
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  File? _localFile;

  @override
  void initState() {
    super.initState();
    _localFile = widget.selectedFile;
  }

  @override
  void didUpdateWidget(covariant FilePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedFile != oldWidget.selectedFile) {
      _localFile = widget.selectedFile;
    }
  }

  void _pick() {
    ImagePickerHelper.showImagePicker(context, (image) {
      if (!mounted) return;
      setState(() {
        _localFile = image;
      });
      widget.onFilePicked(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;

    return InkWell(
      onTap: _pick,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.headerText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textHint,
              ),
            ),
            Gaps.v(8.h),
            if (_localFile != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(
                    _localFile!,
                    height: 120.h,
                    fit: BoxFit.contain,
                  ),
                ),
              )
            else ...[
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 48.r,
                color: colors.primary,
              ),
              Gaps.v(8.h),
              Text(
                widget.footerText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
