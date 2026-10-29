import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/feature/oil_change/data/datasource/oil_change_data_source.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_status_model.dart';

/// حالة عداد الزيت، واحدة للرئيسية وسجل الزيت
class OilStatusCubit extends Cubit<BaseState<OilStatusModel>> {
  OilStatusCubit(this._dataSource) : super(const BaseState());

  final OilChangeDataSource _dataSource;

  /// الداتا القديمة بتفضل في الـ state وقت التحديث، فالشاشة مابتفضاش
  Future<void> getOilStatus() async {
    // الـ cubit مشترك وبيتقفل عند الخروج، فممكن ينادي عليه حد شايله
    if (isClosed) return;
    emit(state.copyWith(status: Status.loading, clearError: true));
    final result = await _dataSource.getOilStatus();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          failure: failure,
        ),
      ),
      (oil) => emit(state.copyWith(status: Status.success, data: oil)),
    );
  }
}
