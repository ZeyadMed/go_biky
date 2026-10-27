import 'package:go_biky/core/cache_manager/cache_manager.dart';

/// مكان واحد لكل حاجة تخص جلسة المستخدم: مسح بياناته عند الخروج
/// أو انتهاء الجلسة، ومنع التحويل للوجين أكتر من مرة.
abstract final class Session {
  static bool _expiryHandled = false;

  /// فيه جلسة محفوظة؟ الـ access token لو منتهي بيتجدد أوتوماتيك
  /// في أول ريكوست، فوجوده كفاية
  static bool get isLoggedIn {
    final token = CacheManager.getAccessTokenSync();
    return token != null && token.isNotEmpty;
  }

  /// بتمسح التوكنز وبيانات المستخدم، عشان اللي يدخل بعده
  /// مايلاقيش حاجة من الحساب القديم
  static Future<void> clear() async {
    await CacheManager.clearTokens();
    await CacheManager.clearUserData();
  }

  /// لما كذا ريكوست يقعوا بـ 401 مع بعض، أول واحد بس هو اللي
  /// بيرجع true وبيحوّل المستخدم للوجين، والباقي بيتجاهلوا
  static bool claimExpiryRedirect() {
    if (_expiryHandled) return false;
    _expiryHandled = true;
    return true;
  }

  /// بتتنادى بعد لوجين ناجح عشان لو الجلسة الجديدة انتهت نحوّل تاني
  static void started() {
    _expiryHandled = false;
  }
}
