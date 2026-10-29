import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/feature/balance/data/datasource/balance_data_source.dart';
import 'package:go_biky/feature/balance/data/model/balance_model.dart';

/// رصيد السواق، واحد للرئيسية وحسابي
class BalanceCubit extends Cubit<BaseState<BalanceModel>> {
  BalanceCubit(this._dataSource) : super(const BaseState());

  final BalanceDataSource _dataSource;

  /// الداتا القديمة بتفضل في الـ state وقت التحديث، فالكارت مابيفضاش
  Future<void> getBalance() async {
    // الـ cubit مشترك وبيتقفل عند الخروج، فممكن ينادي عليه حد شايله
    if (isClosed) return;
    emit(state.copyWith(status: Status.loading, clearError: true));
    final result = await _dataSource.getBalance();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          failure: failure,
        ),
      ),
      (balance) => emit(state.copyWith(status: Status.success, data: balance)),
    );
  }
}
