import 'package:go_biky/core/http/http.dart';
import 'package:go_biky/core/local_storage/local_storage.dart';
import 'package:go_biky/core/session/session_manager.dart';
import 'package:get_it/get_it.dart';

class AuthServiceLocator {
  static Future<void> execute({required GetIt getIt}) async {
    getIt.registerLazySingleton<ITokenCache>(() => HiveServiceImpl.instance);
    getIt.registerLazySingleton<IUserCache>(() => HiveServiceImpl.instance);
    getIt.registerLazySingleton<SessionManager>(
      () => SessionManager(getIt<ITokenCache>()),
    );

    // getIt.registerLazySingleton<AuthDataSource>(
    //   () => AuthDataSourceImpl(getIt<ApiConsumer>()),
    // );

    // getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt<AuthDataSource>()));

    // // شاشة التحقق محتاجة رقم الهاتف — بيتمرر وقت الإنشاء.
    // getIt.registerFactoryParam<VerifyOtpCubit, String, int?>(
    //   (phoneNumber, initialCooldown) => VerifyOtpCubit(
    //     getIt<AuthDataSource>(),
    //     getIt<SessionManager>(),
    //     phoneNumber: phoneNumber,
    //     initialCooldown: initialCooldown ?? 60,
    //   ),
    // );
  }
}
