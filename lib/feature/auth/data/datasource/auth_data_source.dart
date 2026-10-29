import 'package:go_biky/core/cache_manager/cache_manager.dart';
import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/core/helpers/push_token_helper.dart';
import 'package:go_biky/core/http/either.dart';
import 'package:go_biky/core/http/endpoints.dart';
import 'package:go_biky/core/http/failure.dart';
import 'package:go_biky/feature/auth/data/model/user_token.dart';

class AuthDataSource {
  AuthDataSource(this._dataSource);

  final GenericDataSource _dataSource;

  /// `authenticate` بتحفظ التوكنز لو اللوجين نجح، وبيانات السواق بترجع
  /// في `UserToken`
  Future<Either<Failure, UserToken>> login({
    required String phoneNumber,
    required String password,
    bool rememberMe = true,
  }) async {
    final pushToken = await PushTokenHelper.getToken();
    return _dataSource.authenticate<UserToken>(
      endpoint: Endpoints.login,
      data: {
        'phoneNumber': phoneNumber,
        'password': password,
        'rememberMe': rememberMe,
        'fcmToken': ?pushToken,
      },
      fromJson: UserToken.fromJson,
    );
  }

  /// بتلغي الـ refresh token من عند الباك وبترجع رسالته. مسح الجلسة من
  /// الجهاز على اللي بينادي، عشان الخروج مايتعطلش لو الطلب فشل
  Future<Either<Failure, String>> logout() {
    return _dataSource.postData<String>(
      endpoint: Endpoints.logout,
      data: {'refreshToken': CacheManager.getRefreshTokenSync() ?? ''},
      fromJson: (json) => json['message']?.toString() ?? '',
    );
  }
}
