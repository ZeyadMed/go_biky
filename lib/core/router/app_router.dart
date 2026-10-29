import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/http/session.dart';
import 'package:go_biky/core/router/bottom_nav_app.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/auth/presentation/view/screens/login_screen.dart';
import 'package:go_biky/feature/balance/presentation/view/screens/statement_screen.dart';
import 'package:go_biky/feature/notifications/data/model/notification_model.dart';
import 'package:go_biky/feature/notifications/presentation/view/screens/notification_details_screen.dart';
import 'package:go_biky/feature/notifications/presentation/view/screens/notifications_screen.dart';
import 'package:go_biky/feature/oil_change/presentation/view/screens/oil_change_status_screen.dart';
import 'package:go_biky/feature/oil_change/presentation/view/screens/oil_change_screen.dart';
import 'package:go_biky/feature/profile/presentation/view/screens/contact_us_screen.dart';
import 'package:go_biky/feature/profile/presentation/view/screens/privacy_policy_screen.dart';
import 'package:go_biky/feature/splash/presentation/view/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:go_biky/core/router/app_keys.dart';

abstract class AppRouter {
  static const String root = '/';
  static const String login = '/login';
  static const String initialRoute = '/initialRoute';
  static const String oilChange = '/oilChange';
  static const String oilChangeStatus = '/oilChangeStatus';
  static const String notifications = '/notifications';
  static const String notificationDetails = '/notificationDetails';
  static const String contactUs = '/contactUs';
  static const String privacyPolicy = '/privacyPolicy';
  static const String statement = '/statement';

  /// السبلاش واللوجين بس اللي بيتفتحوا من غير جلسة
  static const _publicRoutes = {root, login};

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    // أي شاشة بعد الدخول من غير جلسة (التوكنز اتمسحت مثلاً) بترجع للوجين،
    // بدل ما تفتح وكل طلباتها تقع بـ 401
    redirect: (context, state) =>
        _publicRoutes.contains(state.matchedLocation) || Session.isLoggedIn
        ? null
        : login,
    // من غيره go_router بيعرض "Page Not Found" بالإنجليزي
    errorBuilder: (context, state) => const _RouteErrorScreen(),
    routes: [
      // -----------------------------------Splash Screen--------------------------------
      GoRoute(path: root, builder: (context, state) => const SplashScreen()),

      // AUTHENTICATION ROUTES
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),

      // -----------------------------------Bottom Nav--------------------------------
      // التنقل بين التابات جوه BottomNavApp نفسها
      GoRoute(
        path: initialRoute,
        builder: (context, state) => const BottomNavApp(),
      ),

      // -----------------------------------Oil Change--------------------------------
      // الشاشات اللي محتاجة `extra` لو اتفتحت من غيره (deep link أو
      // restoration) بترجع للتابات بدل crash الـ `!`
      GoRoute(
        path: oilChange,
        redirect: (context, state) => _requireExtra<OilChangeArgs>(state),
        builder: (context, state) =>
            OilChangeScreen(args: state.extra as OilChangeArgs),
      ),
      GoRoute(
        path: oilChangeStatus,
        redirect: (context, state) => _requireExtra<OilChangeStatusArgs>(state),
        builder: (context, state) =>
            OilChangeStatusScreen(args: state.extra as OilChangeStatusArgs),
      ),

      // -----------------------------------Notifications--------------------------------
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: notificationDetails,
        redirect: (context, state) => _requireExtra<NotificationModel>(state),
        builder: (context, state) => NotificationDetailsScreen(
          notification: state.extra as NotificationModel,
        ),
      ),

      // -----------------------------------Profile--------------------------------
      GoRoute(
        path: contactUs,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // -----------------------------------Balance--------------------------------
      GoRoute(
        path: statement,
        builder: (context, state) => const StatementScreen(),
      ),
    ],
  );

  static String? _requireExtra<T>(GoRouterState state) =>
      state.extra is T ? null : initialRoute;
}

/// لينك لشاشة مش موجودة
class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: ResponsiveCenter(
            child: Column(
              children: [
                // FailureWidget فيها scroll خاص بيها، فمحتاجة ارتفاع محدد
                Expanded(
                  child: FailureWidget(
                    errorMessage: 'common.somethingWentWrong'.tr(),
                  ),
                ),
                // السبلاش بيحدد يروح للتابات ولا اللوجين حسب الجلسة
                CustomButton(
                  title: 'bottomNav.home'.tr(),
                  onPressed: () => context.go(AppRouter.root),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
