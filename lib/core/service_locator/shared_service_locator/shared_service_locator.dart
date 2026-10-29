import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/core/http/api_consumer.dart';
import 'package:go_biky/core/http/auth_interceptor.dart';
import 'package:go_biky/core/http/endpoints.dart';
import 'package:go_biky/core/http/token_refresh_service.dart';
import 'package:go_biky/core/service_locator/auth_service_locator/auth_service_locator.dart';
import 'package:go_biky/core/service_locator/balance_service_locator/balance_service_locator.dart';
import 'package:go_biky/core/service_locator/notifications_service_locator/notifications_service_locator.dart';
import 'package:go_biky/core/service_locator/oil_change_service_locator/oil_change_service_locator.dart';
import 'package:go_biky/core/service_locator/profile_service_locator/profile_service_locator.dart';

class SharedServiceLocator {
  static Future<void> execute({required GetIt getIt}) async {
    getIt.registerLazySingleton<TokenRefreshService>(
      () => TokenRefreshService(),
    );

    getIt.registerLazySingleton<Dio>(() {
      final dio = Dio(_baseOptions());

      // Dio تاني بنفس الإعدادات من غير الانترسبتور، الانترسبتور بيعيد بيه
      // الطلب بعد التجديد عشان مايحصلش deadlock في الطابور بتاعه
      final retryDio = Dio(_baseOptions());
      _addLogger(retryDio);

      // الـ Authorization بقى بيتحط في الانترسبتور وقت كل ريكوست،
      // مش هنا وقت التسجيل، عشان ياخد أحدث توكن بعد اللوجين أو التجديد.
      dio.interceptors.add(
        AuthInterceptor(
          retryDio: retryDio,
          refreshService: getIt<TokenRefreshService>(),
        ),
      );
      _addLogger(dio);

      return dio;
    });
    getIt.registerLazySingleton<ApiConsumer>(
      () => BaseApiConsumer(dio: getIt<Dio>()),
    );

    // كل الداتا سورس بتاخده في الكونستراكتور فلازم يكون متسجل قبلهم
    getIt.registerLazySingleton<GenericDataSource>(
      () => GenericDataSource(getIt<ApiConsumer>()),
    );

    // الـ locators بتاعة كل feature تتنادى هنا بعد GenericDataSource
    AuthServiceLocator.execute(getIt: getIt);
    OilChangeServiceLocator.execute(getIt: getIt);
    BalanceServiceLocator.execute(getIt: getIt);
    ProfileServiceLocator.execute(getIt: getIt);
    NotificationsServiceLocator.execute(getIt: getIt);
  }

  static BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        // Disable gzip/deflate from server to avoid malformed compressed responses
        'Accept-Encoding': 'identity',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Accept-Language': 'ar',
      },
    );
  }

  static void _addLogger(Dio dio) {
    if (!kDebugMode) return;
    dio.interceptors.add(
      PrettyDioLogger(
        logPrint: (object) {
          log(object.toString());
        },
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        enabled: true,
        request: true,
        maxWidth: 90,
      ),
    );
  }
}
