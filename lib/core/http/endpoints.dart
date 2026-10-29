abstract interface class Endpoints {
  // TODO: لينك الباك بتاع Go Biky (اللي كان هنا بتاع المشروع القديم)
  static const String baseUrl = 'https://gobike.runasp.net';

  // ****************************** Auth ********************************
  // المسارات لازم تبدأ بـ `/` لأن Dio بيلزق الـ baseUrl في المسار على طول

  /// لوجين السواق. بتستقبل { phoneNumber, password, rememberMe, fcmToken }
  /// وبترجع التوكنز وبيانات السواق جوه data
  static const String login = '/api/v1/driver/auth/login';

  /// بناخد منها accessToken جديد لما القديم يقع بـ 401.
  /// بتستقبل { refreshToken } وبترجع الاتنين جداد جوه data.
  static const String refreshToken = '/api/v1/auth/refresh-token';

  /// بتاخد { refreshToken } وبتلغي الجلسة من عند الباك
  static const String logout = '/api/v1/auth/logout';

  // ****************************** Oil Change ****************************

  /// حالة عداد الزيت لدراجة السواق
  static const String oilStatus = '/api/v1/me/oil-status';

  /// GET: السجل بالصفحات بـ PageIndex و PageSize.
  /// POST: رفع طلب تغيير multipart بـ { Video, Notes }
  static const String oilChanges = '/api/v1/me/oil-changes';

  // ****************************** Balance *******************************

  /// رصيد السواق: المستحقات والمدفوع والمديونية والرصيد اللي ليه
  static const String balance = '/api/v1/me/balance';

  /// كشف الحساب: نفس الرصيد ومعاه الحركات (مستحقات ودفعات)
  static const String statement = '/api/v1/me/statement';

  // ****************************** Profile *******************************

  /// بيانات السواق ودراجته الحالية
  static const String profile = '/api/v1/me/profile';

  /// سياسة الخصوصية كـ HTML في data
  static const String privacyPolicy = '/api/v1/driver/auth/privacy-policy';

  /// أرقام التواصل (اتصال وواتساب) كـ list في data
  static const String contacts = '/api/v1/driver/auth/contacts';

  // ****************************** Notifications *************************

  /// صندوق الإشعارات بالصفحات بـ PageIndex و PageSize و UnreadOnly
  static const String notifications = '/api/v1/notifications';

  /// { unread, unreadCritical, pendingAcknowledgement } لنقطة الجرس
  static const String notificationsUnreadCount =
      '/api/v1/notifications/unread-count';

  static const String notificationsReadAll = '/api/v1/notifications/read-all';

  /// POST بـ { fcmToken } لتسجيل الجهاز، و DELETE بـ ?fcmToken= عند الخروج
  static const String notificationDevices = '/api/v1/notifications/devices';

  /// بيتنادى لما الإشعار يتفتح
  static String notificationRead(String id) => '/api/v1/notifications/$id/read';

  /// للإشعارات اللي `requiresAcknowledgement` بتاعها true
  static String notificationAcknowledge(String id) =>
      '/api/v1/notifications/$id/acknowledge';

  /// اند بوينتس مفتوحة بتتنادى قبل ما يبقى فيه جلسة، فمابنحطش عليها توكن
  /// والـ 401 منها معناه بيانات غلط مش جلسة منتهية
  static bool isPublicAuth(String path) {
    return path.contains(login);
  }
}
