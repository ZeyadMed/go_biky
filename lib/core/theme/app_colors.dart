import 'package:flutter/material.dart';

/// ألوان ثابتة مابتتغيرش مع الـ dark mode: البراند والـ gradients والنص
/// الأبيض فوق الصور. أي لون عادي في الشاشات يتقري من `context.appColors`
abstract final class AppColors {
  // ─── Brand (من GoBiky_logo) ──────────────────────
  static const Color brandRed = Color(0xffBF3332);
  static const Color brandRedDeep = Color(0xff8E2322);
  static const Color brandCharcoal = Color(0xff444442);

  // ─── نص وخلفيات فوق الصور ────────────────────────
  static const Color whiteColor = Color(0xffFFFFFF);
  static const Color whiteTextMuted = Color(0xB3FFFFFF);
  static const Color blackColor = Color(0xff000000);

  // ─── Gradients ────────────────────────────────────
  static const LinearGradient mainGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [brandRed, brandRedDeep],
  );

  /// طبقة غامقة فوق صورة السبلاش عشان النص الأبيض يتقري فوق وتحت
  static const LinearGradient splashOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x99000000), Color(0x1A000000), Color(0xD9000000)],
    stops: [0.0, 0.45, 1.0],
  );
}
