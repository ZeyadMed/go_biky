import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:go_biky/core/helpers/logger.dart';

/// بيجهز Firebase (مشروع gobiky-2ca80) ويبعت الأخطاء والـ crashes لـ
/// Crashlytics، عشان نعرف اللي بيحصل عند السواقين في الـ release. في الـ
/// debug الأخطاء بتطلع في الكونسول بس ومابتتبعتش.
///
/// بيتنادى في main قبل أي حاجة تانية بتستخدم Firebase (زي الإشعارات). لو
/// ملفات إعداد Firebase ناقصة التطبيق بيكمل عادي من غيره
abstract final class CrashReporter {
  static bool _enabled = false;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      loggerWarn('Firebase init failed, crash reporting is off: $e');
      return;
    }

    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    if (kDebugMode) return;

    _enabled = true;
    // أخطاء الـ framework (build / layout / gestures)
    FlutterError.onError = crashlytics.recordFlutterFatalError;
    // الأخطاء اللي محدش عمل لها catch في الـ async
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// الـ id بس من غير اسم أو رقم، عشان نعرف الـ crash حصل لمين لو اشتكى.
  /// `null` بيمسحه عند الخروج
  static Future<void> setUser(String? userId) async {
    if (!_enabled) return;
    await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
  }

  /// لخطأ اتعمله catch بس محتاجين نعرف إنه حصل (زي parsing فشل)
  static void recordError(Object error, StackTrace? stack, {String? reason}) {
    if (!_enabled) return;
    FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
  }
}
