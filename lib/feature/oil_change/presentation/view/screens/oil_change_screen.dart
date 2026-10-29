import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/helpers/image_picker_helper.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/notifications/presentation/view/widgets/notification_navigation.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_change_model.dart';
import 'package:go_biky/feature/oil_change/presentation/view/screens/oil_change_status_screen.dart';
import 'package:go_biky/feature/oil_change/presentation/view/widgets/oil_change_widgets.dart';
import 'package:go_biky/feature/oil_change/presentation/view_model/cubit/oil_change_cubit.dart';
import 'package:go_biky/feature/oil_change/presentation/view_model/cubit/oil_log_cubit.dart';
import 'package:go_biky/feature/oil_change/presentation/view_model/cubit/oil_status_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// بيانات العداد اللي بتتعرض في الشاشة، بتيجي من الرئيسية
class OilChangeArgs {
  const OilChangeArgs({
    required this.kmUsed,
    required this.kmInterval,
    this.odometerKm,
  });

  /// العداد الكلي، ومش في ريسبونس oil-status لسه
  final int? odometerKm;

  /// المسافة من آخر تغيير
  final int kmUsed;

  /// المسافة المفروض يتغير بعدها
  final int kmInterval;
}

/// إثبات تغيير الزيت: أول ما الراكب يختار فيديو الشاشة بتقلب لمراجعة
/// الإثبات، والرجوع من المراجعة بيشيل الفيديو ويرجّعه لأول خطوة.
/// بعد الإرسال بتتبدل بشاشة حالة الإثبات
class OilChangeScreen extends StatefulWidget {
  const OilChangeScreen({super.key, required this.args});

  final OilChangeArgs args;

  @override
  State<OilChangeScreen> createState() => _OilChangeScreenState();
}

class _OilChangeScreenState extends State<OilChangeScreen> {
  final _notesController = TextEditingController();
  final _cubit = getIt<OilChangeCubit>();

  /// تاريخ التغيير هو يوم رفع الإثبات
  final _changeDate = DateTime.now();
  File? _video;

  @override
  void dispose() {
    NotificationNavigation.unlock();
    _notesController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onVideoPicked(File video) {
    if (!mounted) return;
    // المعرض على بعض الأجهزة بيسمح بملفات تانية، والباك بيقبل فيديو بس
    if (!ImagePickerHelper.isVideo(video.path)) {
      context.showErrorMessage('oilChange.invalidVideo'.tr());
      return;
    }
    setState(() => _video = video);
  }

  void _showVideoPicker() =>
      ImagePickerHelper.showImagePicker(context, _onVideoPicked, video: true);

  void _pickFrom(ImageSource source) =>
      ImagePickerHelper.pickFrom(context, source, _onVideoPicked, video: true);

  void _submit() {
    FocusScope.of(context).unfocus();
    final video = _video;
    if (video == null) {
      context.showErrorMessage('oilChange.videoRequired'.tr());
      return;
    }
    if (_cubit.state.isLoading) return;
    _cubit.submit(video: video, notes: _notesController.text.trim());
  }

  void _onStateChanged(BuildContext context, BaseState<OilChangeModel> state) {
    // ضغطة إشعار وقت الرفع كانت بتقفل الشاشة فالنتيجة تضيع ويرفع تاني،
    // فبتستنى لحد ما الرفع يخلص وبعدين تتفتح
    if (state.isLoading) {
      NotificationNavigation.lock();
      return;
    }
    if (state.isFailure) {
      NotificationNavigation.unlock();
      context.showErrorMessage(
        state.errorMessage ?? 'common.somethingWentWrong'.tr(),
      );
      return;
    }
    final change = state.data;
    if (!state.isSuccess || change == null) return;

    // الطلب الجديد بيظهر في السجل، والحالة فيها آخر طلب اتبعت
    getIt<OilStatusCubit>().getOilStatus();
    getIt<OilLogCubit>().refresh();
    context.pushReplacement(
      AppRouter.oilChangeStatus,
      extra: OilChangeStatusArgs(
        change: change,
        kmInterval: widget.args.kmInterval,
      ),
    );
    // بعد التنقل، والإشعار المستني بيتفتح بعد الـ frame
    NotificationNavigation.unlock();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final isReview = _video != null;

    return BlocListener<OilChangeCubit, BaseState<OilChangeModel>>(
      bloc: _cubit,
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStateChanged,
      child: PopScope(
        canPop: !isReview,
        onPopInvokedWithResult: (didPop, _) {
          // وقت الرفع الرجوع مابيعملش حاجة عشان الطلب مايتقطعش
          if (!didPop && !_cubit.state.isLoading) {
            setState(() => _video = null);
          }
        },
        child: DismissKeyboardWrapper(
          child: OilChangeLayout(
            title: isReview
                ? 'oilChange.reviewTitle'.tr()
                : 'oilChange.proofTitle'.tr(),
            step: isReview ? OilChangeStep.review : OilChangeStep.proof,
            button: BlocBuilder<OilChangeCubit, BaseState<OilChangeModel>>(
              bloc: _cubit,
              buildWhen: (previous, current) =>
                  previous.isLoading != current.isLoading,
              builder: (context, state) => CustomButton(
                title: 'oilChange.submit'.tr(),
                isLoading: state.isLoading,
                onPressed: _submit,
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_video case final video?)
                  _ReviewSection(video: video, onChangeVideo: _showVideoPicker)
                else
                  _ProofSection(
                    onAddVideo: _showVideoPicker,
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
      ),
    );
  }
}

/// أول خطوة: العنوان ومربع إضافة الفيديو وزراير الكاميرا والمعرض
class _ProofSection extends StatelessWidget {
  const _ProofSection({
    required this.onAddVideo,
    required this.onOpenCamera,
    required this.onOpenGallery,
  });

  final VoidCallback onAddVideo;
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
        _UploadBox(onTap: onAddVideo),
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
                  Icons.videocam_outlined,
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
                  Icons.video_library_outlined,
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
                  'oilChange.addProofVideo'.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gaps.v(2.h),
                Text(
                  'oilChange.videoHint'.tr(),
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

/// تاني خطوة: الفيديو اللي اتختار ولينك تغييره. مفيش preview للفيديو
/// من غير باكدج، فبيظهر اسم الملف
class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.video, required this.onChangeVideo});

  final File video;
  final VoidCallback onChangeVideo;

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
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.bgTertiary,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  color: colors.textSecondary,
                  size: 56.r,
                ),
                Gaps.v(8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    video.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Gaps.v(8.h),
        Row(
          children: [
            // Expanded بدل Spacer، عشان الـ badge يقصّ النص على الشاشة
            // الصغيرة بدل overflow
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: CustomBadge(
                  text: 'oilChange.oneVideoAttached'.tr(),
                  color: colors.success,
                  backgroundColor: colors.successContainer,
                ),
              ),
            ),
            CustomButton.text(
              title: 'oilChange.changeVideo'.tr(),
              onPressed: onChangeVideo,
              compact: true,
            ),
          ],
        ),
      ],
    );
  }
}
