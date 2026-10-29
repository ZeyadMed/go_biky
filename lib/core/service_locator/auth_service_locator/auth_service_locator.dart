import 'package:get_it/get_it.dart';
import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/feature/auth/data/datasource/auth_data_source.dart';
import 'package:go_biky/feature/auth/presentation/view_model/cubit/login_cubit.dart';

class AuthServiceLocator {
  static void execute({required GetIt getIt}) {
    getIt.registerLazySingleton<AuthDataSource>(
      () => AuthDataSource(getIt<GenericDataSource>()),
    );

    // كل فتحة لشاشة اللوجين بتاخد cubit جديد وبتقفله في الـ dispose
    getIt.registerFactory<LoginCubit>(
      () => LoginCubit(getIt<AuthDataSource>()),
    );
  }
}
