import 'package:go_biky/feature/auth/presentation/view/login_screen.dart';
import 'package:go_biky/feature/splash/presentation/view/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:go_biky/main.dart';

abstract class AppRouter {
  static const String root = '/';
  static const String login = '/login';

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      // -----------------------------------Splash Screen--------------------------------
      GoRoute(path: root, builder: (context, state) => const SplashScreen()),

      // AUTHENTICATION ROUTES
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
    ],
  );
}
