import 'package:flutter_test/flutter_test.dart';
import 'package:go_biky/core/cache_manager/cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tokens are written to secure storage, not prefs', () async {
    final secure = await setUpStorage();

    await CacheManager.saveTokens(accessToken: 'a', refreshToken: 'r');

    expect(secure, {'token': 'a', 'refreshToken': 'r'});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), isNull);
    expect(CacheManager.getAccessTokenSync(), 'a');
  });

  test('an update moves old prefs tokens into secure storage', () async {
    final secure = await setUpStorage(
      prefs: {'token': 'legacy-a', 'refreshToken': 'legacy-r'},
    );

    expect(CacheManager.getAccessTokenSync(), 'legacy-a');
    expect(CacheManager.getRefreshTokenSync(), 'legacy-r');
    expect(secure, {'token': 'legacy-a', 'refreshToken': 'legacy-r'});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), isNull);
    expect(prefs.getString('refreshToken'), isNull);
  });

  test('a fresh install ignores tokens left in the iOS keychain', () async {
    await setUpStorage(secure: {'token': 'old-a', 'refreshToken': 'old-r'});

    expect(CacheManager.getAccessTokenSync(), isNull);
    expect(CacheManager.getRefreshTokenSync(), isNull);
  });

  test('a normal launch reads the saved tokens', () async {
    await setUpStorage(
      prefs: {'secureStorageReady': true},
      secure: {'token': 'a', 'refreshToken': 'r'},
    );

    expect(CacheManager.getAccessTokenSync(), 'a');
    expect(CacheManager.getRefreshTokenSync(), 'r');
  });

  test('clearTokens removes them from memory and secure storage', () async {
    final secure = await setUpStorage();
    await CacheManager.saveTokens(accessToken: 'a', refreshToken: 'r');

    await CacheManager.clearTokens();

    expect(secure, isEmpty);
    expect(CacheManager.getAccessTokenSync(), isNull);
  });
}
