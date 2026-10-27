abstract interface class Endpoints {
  // TODO: لينك الباك بتاع Go Biky (اللي كان هنا بتاع المشروع القديم)
  static const String baseUrl = '';

  // ****************************** Auth ********************************
  // TODO: اتأكد من المسارات وشكل الـ body من الـ Swagger بتاع Go Biky

  /// لوجين باسم المستخدم والباسورد، وبترجع التوكنز
  static const String login = 'api/auth/login';

  /// بناخد منها accessToken جديد لما القديم يقع بـ 401.
  /// بتستقبل { refreshToken, deviceInfo, deviceId } وبترجع الاتنين جداد جوه data.
  static const String refreshToken = 'api/auth/refresh-token';

  /// بتاخد { refreshToken } وبتلغي الجلسة من عند الباك
  static const String logout = 'api/auth/logout';

  /// اند بوينتس مفتوحة بتتنادى قبل ما يبقى فيه جلسة، فمابنحطش عليها توكن
  /// والـ 401 منها معناه بيانات غلط مش جلسة منتهية
  static bool isPublicAuth(String path) {
    return path.contains(login);
  }
}
