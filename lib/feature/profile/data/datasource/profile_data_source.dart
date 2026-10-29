import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/core/http/either.dart';
import 'package:go_biky/core/http/endpoints.dart';
import 'package:go_biky/core/http/failure.dart';
import 'package:go_biky/feature/profile/data/model/contact_model.dart';
import 'package:go_biky/feature/profile/data/model/policy_page_model.dart';
import 'package:go_biky/feature/profile/data/model/profile_model.dart';

class ProfileDataSource {
  ProfileDataSource(this._dataSource);

  final GenericDataSource _dataSource;

  Future<Either<Failure, ProfileModel>> getProfile() {
    return _dataSource.fetchResult<ProfileModel>(
      endpoint: Endpoints.profile,
      fromJson: ProfileModel.fromJson,
    );
  }

  Future<Either<Failure, PolicyPageModel>> getPrivacyPolicy() {
    return _dataSource.fetchResult<PolicyPageModel>(
      endpoint: Endpoints.privacyPolicy,
      fromJson: PolicyPageModel.fromJson,
    );
  }

  /// كل الأرقام زي ما الباك بيرجعها، والـ cubit بيفلتر ويرتب
  Future<Either<Failure, List<ContactModel>>> getContacts() {
    return _dataSource.fetchData<ContactModel>(
      endpoint: Endpoints.contacts,
      fromJson: ContactModel.fromJson,
    );
  }
}
