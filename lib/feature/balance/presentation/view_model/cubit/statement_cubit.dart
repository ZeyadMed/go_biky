import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/feature/balance/data/datasource/balance_data_source.dart';
import 'package:go_biky/feature/balance/data/model/statement_model.dart';

/// كشف الحساب، وكل فتحة للشاشة بتاخد واحد جديد
class StatementCubit extends Cubit<BaseState<StatementModel>> {
  StatementCubit(this._dataSource) : super(const BaseState());

  final BalanceDataSource _dataSource;

  /// الداتا القديمة بتفضل في الـ state وقت التحديث، فالشاشة مابتفضاش
  Future<void> getStatement() async {
    emit(state.copyWith(status: Status.loading, clearError: true));
    final result = await _dataSource.getStatement();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          failure: failure,
        ),
      ),
      (statement) =>
          emit(state.copyWith(status: Status.success, data: statement)),
    );
  }
}
