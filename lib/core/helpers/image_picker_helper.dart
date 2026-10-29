import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/helpers/logger.dart';
import 'package:go_biky/core/widget/custom_list_tile.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';
import 'package:image_picker/image_picker.dart';

/// اختيار صورة أو فيديو من الكاميرا أو المعرض
abstract final class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// امتدادات الفيديو اللي بنقبلها، عشان نتأكد إن الملف فيديو قبل الرفع
  static const _videoExtensions = {
    'mp4',
    'mov',
    'm4v',
    '3gp',
    'mkv',
    'webm',
    'avi',
  };

  /// بيفتح bottom sheet فيه الكاميرا والمعرض، و`onPicked` بتتنده بالصورة
  /// اللي اتختارت (ومابتتندهش لو المستخدم قفل من غير ما يختار).
  /// `video` بيخليه يصوّر أو يختار فيديو بدل صورة
  static Future<void> showImagePicker(
    BuildContext context,
    ValueChanged<File> onPicked, {
    bool video = false,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (video ? 'common.chooseVideo' : 'common.chooseImage').tr(),
              style: context.textTheme.titleMedium,
            ),
            Gaps.v(8.h),
            _SourceTile(
              icon: video
                  ? Icons.videocam_outlined
                  : Icons.photo_camera_outlined,
              title: 'common.camera'.tr(),
              source: ImageSource.camera,
            ),
            _SourceTile(
              icon: video
                  ? Icons.video_library_outlined
                  : Icons.photo_library_outlined,
              title: 'common.gallery'.tr(),
              source: ImageSource.gallery,
            ),
            Gaps.v(8.h),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    await pickFrom(context, source, onPicked, video: video);
  }

  /// بيفتح الكاميرا أو المعرض على طول من غير الـ bottom sheet، لو الشاشة
  /// فيها زرار لكل واحد
  static Future<void> pickFrom(
    BuildContext context,
    ImageSource source,
    ValueChanged<File> onPicked, {
    bool video = false,
  }) async {
    try {
      final file = video ? await pickVideo(source) : await pickImage(source);
      if (file != null) onPicked(file);
    } catch (e) {
      // غالباً المستخدم رفض صلاحية الكاميرا/الصور أو الجهاز مافيهوش كاميرا
      loggerError('Image picker failed: $e');
      if (context.mounted) {
        context.showErrorMessage('common.somethingWentWrong'.tr());
      }
    }
  }

  /// بيرجع null لو المستخدم رجع من غير ما يختار
  static Future<File?> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    return picked == null ? null : File(picked.path);
  }

  /// بيرجع null لو المستخدم رجع من غير ما يختار
  static Future<File?> pickVideo(ImageSource source) async {
    final picked = await _picker.pickVideo(source: source);
    return picked == null ? null : File(picked.path);
  }

  /// الملف فيديو حسب امتداده
  static bool isVideo(String path) =>
      _videoExtensions.contains(path.split('.').last.toLowerCase());
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.title,
    required this.source,
  });

  final IconData icon;
  final String title;
  final ImageSource source;

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      text: title,
      icon: icon,
      iconColor: context.appColors.primary,
      trailing: const SizedBox.shrink(),
      onTap: () => Navigator.of(context).pop(source),
    );
  }
}
