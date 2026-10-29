import 'package:get_it/get_it.dart';
import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/feature/notifications/data/datasource/notifications_data_source.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/notifications_cubit.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/unread_notifications_cubit.dart';

class NotificationsServiceLocator {
  static void execute({required GetIt getIt}) {
    getIt.registerLazySingleton<NotificationsDataSource>(
      () => NotificationsDataSource(getIt<GenericDataSource>()),
    );

    // الجرس والصندوق والـ push بيشوفوا نفس العداد ونفس القايمة، وبيتقفلوا
    // مع الـ reset عند الخروج عشان اللي يدخل بعده مايشوفش إشعاراته
    getIt.registerLazySingleton<UnreadNotificationsCubit>(
      () => UnreadNotificationsCubit(getIt<NotificationsDataSource>()),
      dispose: (cubit) => cubit.close(),
    );
    getIt.registerLazySingleton<NotificationsCubit>(
      () => NotificationsCubit(
        getIt<NotificationsDataSource>(),
        getIt<UnreadNotificationsCubit>(),
      ),
      dispose: (cubit) => cubit.close(),
    );
  }
}
