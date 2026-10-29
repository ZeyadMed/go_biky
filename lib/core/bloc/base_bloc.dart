import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/core/http/either.dart';
import 'package:go_biky/core/http/failure.dart';
part 'base_state.dart';

abstract class BaseCubit<T> extends Cubit<BaseState<T>> {
  final Future<Either<Failure, List<T>>> Function() fetchFunction;
  final Future<Either<Failure, T>> Function()? fetchFunctionMap;

  BaseCubit({required this.fetchFunction, this.fetchFunctionMap})
    : super(BaseState<T>()) {
    // fetchData();
  }

  Future<void> fetchData() async {
    if (isClosed) return;
    emit(state.copyWith(status: Status.loading, clearError: true));
    final result = await fetchFunction();
    // الشاشة ممكن تكون اتقفلت والطلب شغال
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (data) => emit(state.copyWith(status: Status.success, items: data)),
    );
  }

  Future<void> fetchDataMap() async {
    if (isClosed) return;
    emit(state.copyWith(status: Status.loading, clearError: true));
    final result = await fetchFunctionMap!();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.failure, errorMessage: failure.message),
      ),
      (data) => emit(state.copyWith(status: Status.success, data: data)),
    );
  }
}
