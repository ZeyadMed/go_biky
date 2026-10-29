import 'package:get_it/get_it.dart';
import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/feature/balance/data/datasource/balance_data_source.dart';
import 'package:go_biky/feature/balance/presentation/view_model/cubit/balance_cubit.dart';
import 'package:go_biky/feature/balance/presentation/view_model/cubit/statement_cubit.dart';

class BalanceServiceLocator {
  static void execute({required GetIt getIt}) {
    getIt.registerLazySingleton<BalanceDataSource>(
      () => BalanceDataSource(getIt<GenericDataSource>()),
    );

    // الرئيسية وحسابي بيعرضوا نفس الرصيد، وبيتقفل مع الـ reset عند الخروج
    getIt.registerLazySingleton<BalanceCubit>(
      () => BalanceCubit(getIt<BalanceDataSource>()),
      dispose: (cubit) => cubit.close(),
    );

    // كل فتحة لكشف الحساب بتاخد cubit جديد وبتقفله في الـ dispose
    getIt.registerFactory<StatementCubit>(
      () => StatementCubit(getIt<BalanceDataSource>()),
    );
  }
}
