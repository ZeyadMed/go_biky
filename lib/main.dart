import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/cache_manager/cache_manager.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/helpers/push_notifications_helper.dart';
import 'package:go_biky/core/internet_connenction/internet_connection_state.dart';
import 'package:go_biky/core/internet_connenction/internet_connenction_cubit.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/style/assets.dart';
import 'package:go_biky/core/theme/theme.dart';
import 'package:go_biky/core/theme/theme_mode_controller.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:lottie/lottie.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'navigatorKey-${DateTime.now().millisecondsSinceEpoch}',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await CacheManager.init();
  await ThemeModeController.loadSavedTheme();
  await DI.getItInit();
  await PushNotificationsHelper.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      saveLocale: true,
      useOnlyLangCode: true,
      // من غيرها الجمع بيعرف 0/1/2 بس، والعربي محتاج few (٣-١٠) و many (١١-٩٩)
      ignorePluralRules: false,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // التابلت بياخد design size أكبر عشان الـ .w و .sp مايكبّروش كل حاجة
    final shortestSide = MediaQueryData.fromView(
      View.of(context),
    ).size.shortestSide;
    final isTablet = shortestSide >= Breakpoints.tablet;

    return ScreenUtilInit(
      designSize: isTablet ? const Size(768, 1024) : const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => InternetCubit(),
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeModeController.notifier,
            builder: (context, themeMode, _) {
              return MaterialApp.router(
                onGenerateTitle: (context) => 'splash.appName'.tr(),
                debugShowCheckedModeBanner: false,
                scaffoldMessengerKey: scaffoldMessengerKey,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: AppThemeData.light(),
                darkTheme: AppThemeData.dark(),
                themeMode: themeMode,
                routerConfig: AppRouter.router,
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.noScaling),
                    child: BlocBuilder<InternetCubit, InternetState>(
                      builder: (context, state) {
                        if (state is InternetOffState) {
                          return const _NoInternetView();
                        }
                        return child!;
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _NoInternetView extends StatelessWidget {
  const _NoInternetView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(Assets.assetsSvgNoInternet, height: 200.h),
                Gaps.v(18.h),
                Text(
                  'common.noInternet'.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
