import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/feature/notifications/data/datasource/notifications_data_source.dart';
import 'package:go_biky/feature/notifications/data/model/unread_count_model.dart';

/// عداد غير المقروء لنقطة الجرس وشريط الصندوق. بيتحدث بعد أي قراءة أو
/// تأكيد، ولما يوصل push والتطبيق مفتوح
class UnreadNotificationsCubit extends Cubit<BaseState<UnreadCountModel>> {
  UnreadNotificationsCubit(this._dataSource) : super(const BaseState());

  final NotificationsDataSource _dataSource;

  /// مابيعملش loading، فالنقطة بتفضل على آخر قيمة لحد ما الجديدة توصل
  Future<void> getUnreadCount() async {
    final result = await _dataSource.getUnreadCount();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          failure: failure,
        ),
      ),
      (count) => emit(state.copyWith(status: Status.success, data: count)),
    );
  }
}
