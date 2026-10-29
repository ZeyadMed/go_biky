import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_biky/core/helpers/logger.dart';

/// توكن FCM اللي بيتبعت مع اللوجين في `fcmToken` وبيتسجل في
/// `/notifications/devices`. على iOS كمان لازم توكن FCM مش APNs، لأن الباك
/// بيبعت من خلال Firebase
abstract final class PushTokenHelper {
  /// بترجع null لو Firebase مش متجهز (ملفات الإعداد ناقصة) أو التوكن مش
  /// متاح (سيميوليتور، أو مفيش Google Play Services)، واللوجين بيكمل من غيره
  static Future<String?> getToken() async {
    if (Firebase.apps.isEmpty) return null;
    try {
      final messaging = FirebaseMessaging.instance;
      if (Platform.isIOS && await _waitForApnsToken(messaging) == null) {
        return null;
      }
      // register() البديل بيرجع Installation ID مش توكن FCM، والباك لسه
      // بيبعت بالتوكن، فبنفضل على getToken لحد ما الباك يدعم الـ ID
      // ignore: deprecated_member_use
      return await messaging.getToken();
    } catch (e) {
      loggerWarn('FCM token unavailable: $e');
      return null;
    }
  }

  /// على iOS توكن FCM مابيطلعش قبل توكن APNs، واللي ممكن يتأخر شوية بعد
  /// فتح التطبيق
  static Future<String?> _waitForApnsToken(FirebaseMessaging messaging) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      final token = await messaging.getAPNSToken();
      if (token != null) return token;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return null;
  }
}
