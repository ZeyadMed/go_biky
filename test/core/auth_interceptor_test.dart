import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_biky/core/cache_manager/cache_manager.dart';
import 'package:go_biky/core/http/auth_interceptor.dart';
import 'package:go_biky/core/http/endpoints.dart';
import 'package:go_biky/core/http/token_refresh_service.dart';

import '../helpers/fake_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAdapter refreshAdapter;

  setUp(() async {
    await setUpStorage();
    await CacheManager.saveTokens(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
    );
    refreshAdapter = FakeAdapter(
      (_) async => jsonBody({
        'data': {'accessToken': 'new-access', 'refreshToken': 'new-refresh'},
      }),
    );
  });

  /// نفس تركيبة الـ DI: الطلب الأصلي والإعادة بنفس السيرفر الوهمي
  Dio dioWith(FakeAdapter api) {
    return fakeDio(api)
      ..interceptors.add(
        AuthInterceptor(
          retryDio: fakeDio(api),
          refreshService: TokenRefreshService(dio: fakeDio(refreshAdapter)),
        ),
      );
  }

  test('sends the stored token and the UI language', () async {
    final api = FakeAdapter((_) async => jsonBody({'ok': true}));

    await dioWith(api).get(Endpoints.profile);

    final headers = api.requests.single.headers;
    expect(headers['Authorization'], 'Bearer old-access');
    expect(headers['Accept-Language'], 'ar');
  });

  test('a 401 refreshes once and retries with the new token', () async {
    final api = FakeAdapter(
      (options) async => options.headers['Authorization'] == 'Bearer new-access'
          ? jsonBody({'ok': true})
          : jsonBody({}, status: 401),
    );

    final response = await dioWith(api).get(Endpoints.profile);

    expect(response.data, {'ok': true});
    expect(refreshAdapter.requests, hasLength(1));
    expect(api.requests, hasLength(2));
  });

  test(
    'a 401 from login is wrong credentials, not an expired session',
    () async {
      final api = FakeAdapter((_) async => jsonBody({}, status: 401));

      await expectLater(
        dioWith(api).post(Endpoints.login),
        throwsA(isA<DioException>()),
      );

      expect(refreshAdapter.requests, isEmpty);
      expect(api.requests.single.headers.containsKey('Authorization'), isFalse);
      expect(CacheManager.getAccessTokenSync(), 'old-access');
    },
  );

  test('a rejected refresh clears the session', () async {
    final api = FakeAdapter((_) async => jsonBody({}, status: 401));
    refreshAdapter = FakeAdapter((_) async => jsonBody({}, status: 401));

    await expectLater(
      dioWith(api).get(Endpoints.profile),
      throwsA(isA<DioException>()),
    );

    expect(CacheManager.getAccessTokenSync(), isNull);
    expect(CacheManager.getRefreshTokenSync(), isNull);
  });
}
