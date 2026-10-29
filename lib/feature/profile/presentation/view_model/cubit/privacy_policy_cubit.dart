import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/feature/profile/data/datasource/profile_data_source.dart';
import 'package:go_biky/feature/profile/data/model/policy_page_model.dart';

/// سياسة الخصوصية، وكل فتحة للشاشة بتاخد واحد جديد
class PrivacyPolicyCubit extends Cubit<BaseState<PolicyPageModel>> {
  PrivacyPolicyCubit(this._dataSource) : super(const BaseState());

  final ProfileDataSource _dataSource;

  Future<void> getPrivacyPolicy() async {
    emit(state.copyWith(status: Status.loading));
    final result = await _dataSource.getPrivacyPolicy();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          failure: failure,
        ),
      ),
      (page) => emit(state.copyWith(status: Status.success, data: page)),
    );
  }
}
