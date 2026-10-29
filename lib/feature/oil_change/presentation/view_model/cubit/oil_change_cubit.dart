import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/feature/oil_change/data/datasource/oil_change_data_source.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_change_model.dart';

/// رفع فيديو إثبات تغيير الزيت
class OilChangeCubit extends Cubit<BaseState<OilChangeModel>> {
  OilChangeCubit(this._dataSource) : super(const BaseState());

  final OilChangeDataSource _dataSource;

  Future<void> submit({required File video, String? notes}) async {
    emit(state.copyWith(status: Status.loading, clearError: true));
    final result = await _dataSource.submitOilChange(
      video: video,
      notes: notes,
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
      (change) => emit(state.copyWith(status: Status.success, data: change)),
    );
  }
}
