import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static const _accessTokenKey = 'token';
  static const _refreshTokenKey = 'refreshToken';
  static const _userIdKey = 'userId';
  static const _userNameKey = 'userName';
  static const _userEmailKey = 'userEmail';
  static const _userRoleKey = 'userRole';
  static const _secureStorageReadyKey = 'secureStorageReady';
  static SharedPreferences? _sharedPreferences;

  /// التوكنز في الـ Keychain / Keystore مش في prefs. على iOS بتتقري بعد أول
  /// فتح للجهاز حتى لو مقفول، لأن الإشعار ممكن يشغّل التطبيق في الخلفية،
  /// و `this_device` بيمنعها تتنقل مع الـ backup لجهاز تاني
  static const _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// نسخة في الذاكرة من التوكنز، عشان القراية تفضل sync زي ما الـ Session
  /// والانترسبتور محتاجين، والكتابة بتحدّثها الأول
  static String? _accessToken;
  static String? _refreshToken;

  // Singleton instance
  static final CacheManager _instance = CacheManager._internal();

  factory CacheManager() {
    return _instance;
  }

  CacheManager._internal();

  // Initialize SharedPreferences
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _loadTokens();
  }

  static Future<void> _loadTokens() async {
    try {
      // الـ Keychain على iOS بيفضل بعد مسح التطبيق، والـ prefs لأ. فلو
      // العلامة دي مش موجودة يبقى تثبيت جديد، ومايصحش يلاقي نفسه داخل
      if (sharedPreferences.getBool(_secureStorageReadyKey) != true) {
        await _secureStorage.deleteAll();
        await sharedPreferences.setBool(_secureStorageReadyKey, true);
      }
      _accessToken = await _secureStorage.read(key: _accessTokenKey);
      _refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      log('Secure storage read failed: $e');
    }

    // النسخ القديمة كانت بتحفظ التوكنز في prefs، فبننقلهم مرة واحدة
    // ومابنمسحهمش من هناك إلا لو الكتابة الجديدة نجحت، عشان المستخدم
    // مايتطردش بعد الـ update
    final legacyAccess = sharedPreferences.getString(_accessTokenKey);
    final legacyRefresh = sharedPreferences.getString(_refreshTokenKey);
    if (legacyAccess == null && legacyRefresh == null) return;

    if (_accessToken == null && _refreshToken == null) {
      final migrated =
          await _writeSecure(_accessTokenKey, legacyAccess) &&
          await _writeSecure(_refreshTokenKey, legacyRefresh);
      if (!migrated) return;
      _accessToken = legacyAccess;
      _refreshToken = legacyRefresh;
    }
    await sharedPreferences.remove(_accessTokenKey);
    await sharedPreferences.remove(_refreshTokenKey);
    log('Tokens migrated to secure storage');
  }

  /// `null` بيمسح. بترجع false لو الـ Keystore رفض، والتوكن بيفضل في
  /// الذاكرة للجلسة الحالية بس
  static Future<bool> _writeSecure(String key, String? value) async {
    try {
      if (value == null) {
        await _secureStorage.delete(key: key);
      } else {
        await _secureStorage.write(key: key, value: value);
      }
      return true;
    } catch (e) {
      log('Secure storage write failed for $key: $e');
      return false;
    }
  }

  // Getter for sharedPreferences with null check
  static SharedPreferences get sharedPreferences {
    if (_sharedPreferences == null) {
      throw Exception(
        'SharedPreferences not initialized. Call CacheManager.init() first.',
      );
    }
    return _sharedPreferences!;
  }

  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    } else if (value is String) {
      return await sharedPreferences.setString(key, value);
    } else if (value is int) {
      return await sharedPreferences.setInt(key, value);
    } else {
      return await sharedPreferences.setDouble(key, value);
    }
  }

  dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  static Future<void> saveAccessToken(String token) async {
    _accessToken = token;
    await _writeSecure(_accessTokenKey, token);
    log('Access token saved');
  }

  static String? getAccessTokenSync() => _accessToken;

  static Future<String?> getAccessToken() async => _accessToken;

  static Future<void> delAccessToken() async {
    _accessToken = null;
    await _writeSecure(_accessTokenKey, null);
    log('token deleted');
  }

  static Future<void> saveRefreshToken(String token) async {
    _refreshToken = token;
    await _writeSecure(_refreshTokenKey, token);
    log('Refresh token saved');
  }

  static String? getRefreshTokenSync() => _refreshToken;

  static Future<String?> getRefreshToken() async {
    log('Refresh token retrieved: ${_refreshToken != null}');
    return _refreshToken;
  }

  static Future<void> delRefreshToken() async {
    _refreshToken = null;
    await _writeSecure(_refreshTokenKey, null);
    log('refresh token deleted');
  }

  /// بنحفظ التوكنين مع بعض بعد اللوجين أو بعد التجديد.
  /// الباك اند بيدوّر الـ refresh token كل مرة فلازم نحفظ الجديد.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  /// بنمسح التوكنين مع بعض عند الخروج أو لما التجديد يفشل
  static Future<void> clearTokens() async {
    await delAccessToken();
    await delRefreshToken();
  }

  /// بنحفظ بيانات المستخدم بعد اللوجين، عشان الشاشات
  /// تعرض الاسم من غير ما تبعت ريكوست زيادة
  static Future<void> saveUserData({
    required String userId,
    required String userName,
    required String role,
    String? email,
  }) async {
    if (userId.isNotEmpty) {
      await sharedPreferences.setString(_userIdKey, userId);
    }
    await sharedPreferences.setString(_userNameKey, userName);
    await sharedPreferences.setString(_userRoleKey, role);
    if (email != null && email.isNotEmpty) {
      await sharedPreferences.setString(_userEmailKey, email);
    } else {
      await sharedPreferences.remove(_userEmailKey);
    }
    log('User data saved: $userName ($role)');
  }

  static String? getUserName() => sharedPreferences.getString(_userNameKey);

  static String? getUserEmail() => sharedPreferences.getString(_userEmailKey);

  static String? getUserRole() => sharedPreferences.getString(_userRoleKey);

  /// الباك بيرجع الـ id كـ string فبنحفظه string
  static Future<String?> getUserId() async {
    return sharedPreferences.getString(_userIdKey);
  }

  /// بنمسح بيانات المستخدم مع التوكنز عند تسجيل الخروج
  static Future<void> clearUserData() async {
    await sharedPreferences.remove(_userIdKey);
    await sharedPreferences.remove(_userNameKey);
    await sharedPreferences.remove(_userEmailKey);
    await sharedPreferences.remove(_userRoleKey);
    log('User data cleared');
  }

  static Future<bool> clear() async {
    try {
      await clearTokens();
      await sharedPreferences.clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}
