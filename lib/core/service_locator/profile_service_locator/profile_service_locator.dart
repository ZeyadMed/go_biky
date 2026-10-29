import 'package:get_it/get_it.dart';
import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/feature/profile/data/datasource/profile_data_source.dart';
import 'package:go_biky/feature/profile/presentation/view_model/cubit/contacts_cubit.dart';
import 'package:go_biky/feature/profile/presentation/view_model/cubit/privacy_policy_cubit.dart';
import 'package:go_biky/feature/profile/presentation/view_model/cubit/profile_cubit.dart';

class ProfileServiceLocator {
  static void execute({required GetIt getIt}) {
    getIt.registerLazySingleton<ProfileDataSource>(
      () => ProfileDataSource(getIt<GenericDataSource>()),
    );

    // الرئيسية وحسابي بيعرضوا نفس البيانات، وبيتقفل مع الـ reset عند الخروج
    getIt.registerLazySingleton<ProfileCubit>(
      () => ProfileCubit(getIt<ProfileDataSource>()),
      dispose: (cubit) => cubit.close(),
    );

    // كل فتحة لسياسة الخصوصية أو تواصل معنا بتجيب أحدث محتوى، وبتقفل
    // الـ cubit بتاعها في الـ dispose
    getIt.registerFactory<PrivacyPolicyCubit>(
      () => PrivacyPolicyCubit(getIt<ProfileDataSource>()),
    );
    getIt.registerFactory<ContactsCubit>(
      () => ContactsCubit(getIt<ProfileDataSource>()),
    );
  }
}
