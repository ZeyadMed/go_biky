import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/helpers/image_picker_helper.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/oil_change/oil_change_proof.dart';
import 'package:go_biky/feature/oil_change/presentation/widgets/oil_change_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

// TODO: رقم الإثبات بيرجع من الـ API
const _tempProofId = 782;

/// بيانات العداد اللي بتتعرض في الشاشة، بتيجي من الرئيسية
class OilChangeArgs {
  const OilChangeArgs({
    required this.odometerKm,
    required this.kmUsed,
    required this.kmInterval,
  });

  final int odometerKm;

  /// المسافة من آخر تغيير
  final int kmUsed;

  /// المسافة المفروض يتغير بعدها
  final int kmInterval;
}

/// إثبات تغيير الزيت: أول ما الراكب يختار صورة الشاشة بتقلب لمراجعة
/// الإثبات، والرجوع من المراجعة بيشيل الصورة ويرجّعه لأول خطوة.
/// بعد الإرسال بتتبدل بشاشة حالة الإثبات
class OilChangeScreen extends StatefulWidget {
  const OilChangeScreen({super.key, required this.args});

  final OilChangeArgs args;

  @override
  State<OilChangeScreen> createState() => _OilChangeScreenState();
}

class _OilChangeScreenState extends State<OilChangeScreen> {
  final _notesController = TextEditingController();

  /// تاريخ التغيير هو يوم رفع الإثبات
  final _changeDate = DateTime.now();
  File? _image;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onImagePicked(File image) {
    if (!mounted) return;
    setState(() => _image = image);
  }

  void _showImagePicker() =>
      ImagePickerHelper.showImagePicker(context, _onImagePicked);

  void _pickFrom(ImageSource source) =>
      ImagePickerHelper.pickFrom(context, source, _onImagePicked);

  void _submit() {
    FocusScope.of(context).unfocus();
    final image = _image;
    if (image == null) {
      context.showErrorMessage('oilChange.imageRequired'.tr());
      return;
    }
    // TODO: رفع الصورة والملاحظات لما الـ API يجهز، والإثبات اللي بيرجع
    // منه هو اللي يتبعت لشاشة الحالة
    final args = widget.args;
    context.pushReplacement(
      AppRouter.oilChangeStatus,
      extra: OilChangeProof(
        id: _tempProofId,
        status: OilProofStatus.pending,
        image: image.path,
        submittedAt: DateTime.now(),
        changeDate: _changeDate,
        odometerKm: args.odometerKm,
        kmUsed: args.kmUsed,
        kmInterval: args.kmInterval,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final isReview = _image != null;

    return PopScope(
      canPop: !isReview,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _image = null);
      },
      child: DismissKeyboardWrapper(
        child: OilChangeLayout(
          title: isReview
              ? 'oilChange.reviewTitle'.tr()
              : 'oilChange.proofTitle'.tr(),
          step: isReview ? OilChangeStep.review : OilChangeStep.proof,
          button: CustomButton(
            title: 'oilChange.submit'.tr(),
            onPressed: _submit,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_image case final image?)
                _ReviewSection(image: image, onChangeImage: _showImagePicker)
              else
                _ProofSection(
                  onAddImage: _showImagePicker,
                  onOpenCamera: () => _pickFrom(ImageSource.camera),
                  onOpenGallery: () => _pickFrom(ImageSource.gallery),
                ),
              Gaps.v(16.h),
              OilChangeDetailsCard(
                changeDate: _changeDate,
                odometerKm: args.odometerKm,
                kmUsed: args.kmUsed,
                kmInterval: args.kmInterval,
              ),
              Gaps.v(16.h),
              CustomTextField(
                controller: _notesController,
                labelText: 'oilChange.notesLabel'.tr(),
                hintText: 'oilChange.notesHint'.tr(),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 3,
              ),
              if (isReview) ...[
                Gaps.v(12.h),
                Text(
                  'oilChange.pendingNote'.tr(
                    args: [
                      context.formatNumber(args.kmUsed),
                      context.formatNumber(args.kmInterval),
                    ],
                  ),
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    color: context.appColors.textHint,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// أول خطوة: العنوان ومربع إضافة الصورة وزراير الكاميرا والمعرض
class _ProofSection extends StatelessWidget {
  const _ProofSection({
    required this.onAddImage,
    required this.onOpenCamera,
    required this.onOpenGallery,
  });

  final VoidCallback onAddImage;
  final VoidCallback onOpenCamera;
  final VoidCallback onOpenGallery;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final onSecondary = context.colorScheme.onSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'oilChange.headline'.tr(),
          style: textTheme.headlineSmall?.copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        Gaps.v(6.h),
        Text(
          'oilChange.subtitle'.tr(),
          style: textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            height: 1.7,
          ),
        ),
        Gaps.v(16.h),
        _UploadBox(onTap: onAddImage),
        Gaps.v(12.h),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                title: 'oilChange.openCamera'.tr(),
                onPressed: onOpenCamera,
                backgroundColor: colors.secondary,
                textColor: onSecondary,
                fontSize: 14.sp,
                icon: Icon(
                  Icons.photo_camera_outlined,
                  color: onSecondary,
                  size: 20.r,
                ),
              ),
            ),
            Gaps.h(10.w),
            Expanded(
              child: CustomButton(
                title: 'oilChange.fromGallery'.tr(),
                onPressed: onOpenGallery,
                backgroundColor: colors.bgSecondary,
                borderColor: colors.border,
                textColor: colors.textPrimary,
                fontSize: 14.sp,
                icon: Icon(
                  Icons.photo_outlined,
                  color: colors.textPrimary,
                  size: 20.r,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// المربع المتقطع، الضغط عليه بيفتح اختيار الكاميرا أو المعرض
class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = 20.r;

    return Material(
      color: colors.bgSecondary,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: colors.textHint.withValues(alpha: 0.5),
            radius: radius,
            strokeWidth: 1.5.r,
            dashLength: 6.r,
            gapLength: 4.r,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              children: [
                OilBottleImage(width: 64.r, height: 64.r, borderRadius: 14.r),
                Gaps.v(12.h),
                Text(
                  'oilChange.addProofImage'.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gaps.v(2.h),
                Text(
                  'oilChange.imageHint'.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    color: colors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    // الخط بيترسم على نص الحافة، فبنصغّر المستطيل عشان مايتقصش
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    for (final metric in path.computeMetrics()) {
      for (
        var start = 0.0;
        start < metric.length;
        start += dashLength + gapLength
      ) {
        canvas.drawPath(metric.extractPath(start, start + dashLength), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      radius != oldDelegate.radius ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashLength != oldDelegate.dashLength ||
      gapLength != oldDelegate.gapLength;
}

/// تاني خطوة: الصورة اللي اتختارت ولينك تغييرها
class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.image, required this.onChangeImage});

  final File image;
  final VoidCallback onChangeImage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'oilChange.reviewSubtitle'.tr(),
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 13.sp,
            color: colors.textSecondary,
            height: 1.7,
          ),
        ),
        Gaps.v(12.h),
        AspectRatio(
          aspectRatio: 5 / 3,
          child: FlexibleImage(source: image.path, borderRadius: 18.r),
        ),
        Gaps.v(8.h),
        Row(
          children: [
            CustomBadge(
              text: 'oilChange.oneImageAttached'.tr(),
              color: colors.success,
              backgroundColor: colors.successContainer,
            ),
            const Spacer(),
            TextButton(
              onPressed: onChangeImage,
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                textStyle: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('oilChange.changeImage'.tr()),
            ),
          ],
        ),
      ],
    );
  }
}
