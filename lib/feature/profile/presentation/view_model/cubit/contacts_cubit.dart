import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/feature/profile/data/datasource/profile_data_source.dart';
import 'package:go_biky/feature/profile/data/model/contact_model.dart';

/// أرقام التواصل المفعّلة بترتيب الإدارة، في `items`
class ContactsCubit extends Cubit<BaseState<ContactModel>> {
  ContactsCubit(this._dataSource) : super(const BaseState());

  final ProfileDataSource _dataSource;

  Future<void> getContacts() async {
    emit(state.copyWith(status: Status.loading));
    final result = await _dataSource.getContacts();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          failure: failure,
        ),
      ),
      (contacts) => emit(
        state.copyWith(
          status: Status.success,
          items:
              contacts
                  .where(
                    (contact) =>
                        contact.isActive &&
                        (contact.phoneNumber.isNotEmpty ||
                            contact.whatsAppNumber.isNotEmpty),
                  )
                  .toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
        ),
      ),
    );
  }
}
