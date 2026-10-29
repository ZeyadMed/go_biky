import 'package:get_it/get_it.dart';
import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/feature/oil_change/data/datasource/oil_change_data_source.dart';
import 'package:go_biky/feature/oil_change/presentation/view_model/cubit/oil_change_cubit.dart';
import 'package:go_biky/feature/oil_change/presentation/view_model/cubit/oil_log_cubit.dart';
import 'package:go_biky/feature/oil_change/presentation/view_model/cubit/oil_status_cubit.dart';

class OilChangeServiceLocator {
  static void execute({required GetIt getIt}) {
    getIt.registerLazySingleton<OilChangeDataSource>(
      () => OilChangeDataSource(getIt<GenericDataSource>()),
    );

    // الرئيسية وسجل الزيت بيعرضوا نفس الحالة ونفس السجل، وبيتحدثوا بعد
    // رفع تغيير جديد، وبيتقفلوا مع الـ reset عند الخروج
    getIt.registerLazySingleton<OilStatusCubit>(
      () => OilStatusCubit(getIt<OilChangeDataSource>()),
      dispose: (cubit) => cubit.close(),
    );
    getIt.registerLazySingleton<OilLogCubit>(
      () => OilLogCubit(getIt<OilChangeDataSource>()),
      dispose: (cubit) => cubit.close(),
    );

    // كل فتحة لشاشة الرفع بتاخد cubit جديد وبتقفله في الـ dispose
    getIt.registerFactory<OilChangeCubit>(
      () => OilChangeCubit(getIt<OilChangeDataSource>()),
    );
  }
}
