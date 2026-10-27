import 'package:go_biky/core/router/bottom_nav_app.dart';
import 'package:go_biky/feature/auth/presentation/view/login_screen.dart';
import 'package:go_biky/feature/splash/presentation/view/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:go_biky/main.dart';

abstract class AppRouter {
  static const String root = '/';
  static const String login = '/login';
  static const String initialRoute = '/initialRoute';

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
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
    ],
  );
}
