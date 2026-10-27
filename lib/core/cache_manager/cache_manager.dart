import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static const _accessTokenKey = 'token';
  static const _refreshTokenKey = 'refreshToken';
  static const _userIdKey = 'userId';
  static const _userNameKey = 'userName';
  static const _userEmailKey = 'userEmail';
  static const _userRoleKey = 'userRole';
  static SharedPreferences? _sharedPreferences;

  // Singleton instance
  static final CacheManager _instance = CacheManager._internal();

  factory CacheManager() {
    return _instance;
  }

  CacheManager._internal();

  // Initialize SharedPreferences
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
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
    await sharedPreferences.setString(_accessTokenKey, token);
    log('Access token saved');
  }

  static String? getAccessTokenSync() {
    return sharedPreferences.getString(_accessTokenKey);
  }

  static Future<String?> getAccessToken() async {
    return sharedPreferences.getString(_accessTokenKey);
  }

  static Future<void> delAccessToken() async {
    await sharedPreferences.remove(_accessTokenKey);
    log('token deleted');
  }

  static Future<void> saveRefreshToken(String token) async {
    await sharedPreferences.setString(_refreshTokenKey, token);
    log('Refresh token saved');
  }

  static String? getRefreshTokenSync() {
    return sharedPreferences.getString(_refreshTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final token = sharedPreferences.getString(_refreshTokenKey);
    log('Refresh token retrieved: ${token != null}');
    return token;
  }

  static Future<void> delRefreshToken() async {
    await sharedPreferences.remove(_refreshTokenKey);
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
      await sharedPreferences.clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}
