import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/feature/auth/data/datasource/auth_data_source.dart';
import 'package:go_biky/feature/auth/data/model/user_token.dart';

class LoginCubit extends Cubit<BaseState<UserToken>> {
  LoginCubit(this._authDataSource) : super(const BaseState());

  final AuthDataSource _authDataSource;

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    emit(state.copyWith(status: Status.loading, clearError: true));
    final result = await _authDataSource.login(
      phoneNumber: phoneNumber,
      password: password,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          failure: failure,
        ),
      ),
      (token) => emit(state.copyWith(status: Status.success, data: token)),
    );
  }
}
