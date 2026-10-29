import 'package:go_biky/core/cache_manager/cache_manager.dart';
import 'package:go_biky/core/helpers/crash_reporter.dart';
import 'package:go_biky/core/helpers/push_notifications_helper.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/router/bottom_nav_app.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/feature/auth/data/datasource/auth_data_source.dart';
import 'package:go_biky/feature/notifications/presentation/view/widgets/notification_navigation.dart';

/// مكان واحد لكل حاجة تخص جلسة المستخدم: مسح بياناته عند الخروج
/// أو انتهاء الجلسة، ومنع التحويل للوجين أكتر من مرة.
abstract final class Session {
  static bool _expiryHandled = false;
  static bool _ending = false;

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
    await CrashReporter.setUser(null);
  }

  /// الخروج من الحساب، سواء المستخدم داس "خروج" أو الجلسة انتهت:
  /// 1. لو `callBackend`: الجهاز بيتشال من الإشعارات والـ refresh token
  ///    بيتلغي عند الباك وهو لسه بالتوكن. الفشل هنا مابيمنعش الخروج
  /// 2. التوكنز وبيانات المستخدم بتتمسح، وأي إشعار مستني يتفتح بيتلغي
  /// 3. التحويل للوجين
  /// 4. بعد ما التابات تتشال من الشجرة، الـ cubits المشتركة (الرصيد،
  ///    البروفايل، الإشعارات...) بتتقفل وتتسجل من جديد فاضية، عشان اللي
  ///    يدخل بعده مايشوفش بيانات الحساب ده. لو اتقفلت والتابات لسه
  ///    معروضة أي refresh بيرمي "Cannot emit new states after calling close"
  static Future<void> end({bool callBackend = true}) async {
    if (_ending) return;
    _ending = true;
    // الطلبات اللي هتقع بـ 401 وإحنا خارجين مش "جلسة منتهية"
    _expiryHandled = true;
    try {
      if (callBackend) {
        await PushNotificationsHelper.unregisterDevice();
        await getIt<AuthDataSource>().logout();
      }
      await clear();
      NotificationNavigation.clearPending();
      AppRouter.router.go(AppRouter.login);
      await BottomNavApp.whenDisposed().timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      );
      await DI.resetGetItAndInit();
    } finally {
      _ending = false;
    }
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
