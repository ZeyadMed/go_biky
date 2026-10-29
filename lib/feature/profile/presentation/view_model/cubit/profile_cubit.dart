import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/feature/profile/data/datasource/profile_data_source.dart';
import 'package:go_biky/feature/profile/data/model/profile_model.dart';

/// بيانات السواق، واحد للرئيسية وحسابي ورسالة الواتساب في تواصل معنا
class ProfileCubit extends Cubit<BaseState<ProfileModel>> {
  ProfileCubit(this._dataSource) : super(const BaseState());

  final ProfileDataSource _dataSource;

  /// الداتا القديمة بتفضل في الـ state وقت التحديث، فالشاشة مابتفضاش
  Future<void> getProfile() async {
    emit(state.copyWith(status: Status.loading));
    final result = await _dataSource.getProfile();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          failure: failure,
        ),
      ),
      (profile) => emit(state.copyWith(status: Status.success, data: profile)),
    );
  }
}
