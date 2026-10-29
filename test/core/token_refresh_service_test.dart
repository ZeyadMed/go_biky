import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_biky/core/cache_manager/cache_manager.dart';
import 'package:go_biky/core/http/token_refresh_service.dart';

import '../helpers/fake_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setUpStorage();
    await CacheManager.saveTokens(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
    );
  });

  TokenRefreshService serviceWith(FakeAdapter adapter) =>
      TokenRefreshService(dio: fakeDio(adapter));

  ResponseBody rotatedTokens() => jsonBody({
    'data': {'accessToken': 'new-access', 'refreshToken': 'new-refresh'},
  });

  test('saves the rotated tokens on success', () async {
    final adapter = FakeAdapter((_) async => rotatedTokens());

    final result = await serviceWith(adapter).refresh();

    expect(result, isA<RefreshSuccess>());
    expect(CacheManager.getAccessTokenSync(), 'new-access');
    expect(CacheManager.getRefreshTokenSync(), 'new-refresh');
    expect(adapter.requests.single.data, {'refreshToken': 'old-refresh'});
  });

  test('a rejected refresh token means the session expired', () async {
    final adapter = FakeAdapter((_) async => jsonBody({}, status: 401));

    final result = await serviceWith(adapter).refresh();

    expect(result, isA<RefreshSessionExpired>());
  });

  test('a network failure keeps the session', () async {
    final adapter = FakeAdapter((options) async => connectionError(options));

    final result = await serviceWith(adapter).refresh();

    expect(result, isA<RefreshTransientFailure>());
    expect(CacheManager.getRefreshTokenSync(), 'old-refresh');
  });

  test('parallel calls share one refresh request', () async {
    final response = Completer<ResponseBody>();
    final adapter = FakeAdapter((_) => response.future);
    final service = serviceWith(adapter);

    final calls = [service.refresh(), service.refresh(), service.refresh()];
    response.complete(rotatedTokens());
    final results = await Future.wait(calls);

    expect(adapter.requests, hasLength(1));
    expect(results, everyElement(isA<RefreshSuccess>()));
  });

  test('a refresh that finishes after logout is discarded', () async {
    final response = Completer<ResponseBody>();
    final adapter = FakeAdapter((_) => response.future);

    final pending = serviceWith(adapter).refresh();
    await CacheManager.clearTokens();
    response.complete(rotatedTokens());

    expect(await pending, isA<RefreshSessionExpired>());
    expect(CacheManager.getAccessTokenSync(), isNull);
  });
}
