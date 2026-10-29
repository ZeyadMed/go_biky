import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/helpers/logger.dart';
import 'package:go_biky/core/helpers/push_token_helper.dart';
import 'package:go_biky/core/http/session.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/feature/notifications/data/datasource/notifications_data_source.dart';
import 'package:go_biky/feature/notifications/data/model/notification_model.dart';
import 'package:go_biky/feature/notifications/presentation/view/widgets/notification_navigation.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/notifications_cubit.dart';
import 'package:go_biky/feature/notifications/presentation/view_model/cubit/unread_notifications_cubit.dart';

/// إشعارات Firebase (مشروع gobiky-2ca80): تسجيل توكن الجهاز عند الباك،
/// وعرض الإشعار والتطبيق مفتوح، وفتح الشاشة اللي تخصه لما السواق يدوس عليه
/// في أي حالة (مفتوح / في الخلفية / مقفول)
abstract final class PushNotificationsHelper {
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  /// نفس القيمة اللي في `default_notification_channel_id` في الـ manifest،
  /// عشان إشعارات الخلفية تتعرض heads-up زي اللي بنعرضها إحنا
  static const _channelId = 'go_biky_notifications';

  /// العنوان والنص بيتحطوا مع `data` في الـ payload بتاع الإشعار المحلي
  static const _titleKey = 'title';
  static const _bodyKey = 'body';

  static bool _initialized = false;

  /// آخر توكن اتسجل عند الباك، عشان الخروج مايستناش توكن جديد
  static String? _registeredToken;

  /// بتتنادى في main قبل runApp. لو ملفات إعداد Firebase مش موجودة
  /// التطبيق بيكمل عادي من غير إشعارات
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      loggerWarn('Firebase init failed, push notifications are off: $e');
      return;
    }
    _initialized = true;

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // الإذن بيتطلب من FirebaseMessaging بعد الدخول، مش أول ما التطبيق يفتح
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _openPayload(response.payload),
    );

    final messaging = FirebaseMessaging.instance;
    // على iOS النظام بيعرض الإشعار والتطبيق مفتوح، وعلى أندرويد بنعرضه إحنا
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_openMessage);
    // زي getToken، البديل بيرجع Installation ID والباك لسه بيبعت بالتوكن
    // ignore: deprecated_member_use
    messaging.onTokenRefresh.listen((token) {
      if (Session.isLoggedIn) _registerDevice(token);
    });

    // الضغطة اللي فتحت التطبيق وهو مقفول: على إشعار من FCM، أو على إشعار
    // محلي اتعرض والتطبيق مفتوح وبعدين اتقفل
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _openMessage(initialMessage);
      return;
    }
    final launch = await _localNotifications.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _openPayload(launch!.notificationResponse?.payload);
    }
  }

  /// بعد الدخول أو فتح التطبيق والجلسة موجودة: بيطلب الإذن (أندرويد ١٣+ و
  /// iOS) ويسجل التوكن عند الباك، لأنه ممكن يكون اتغير أو ماكانش جاهز وقت
  /// اللوجين
  static Future<void> onSessionStarted() async {
    if (!_initialized) return;
    await _createAndroidChannel();
    await FirebaseMessaging.instance.requestPermission();
    final token = await PushTokenHelper.getToken();
    if (token != null) await _registerDevice(token);
  }

  /// قبل مسح الجلسة عند الخروج، عشان إشعارات الحساب ماتوصلش للجهاز بعده
  static Future<void> unregisterDevice() async {
    if (!_initialized) return;
    final token = _registeredToken ?? await PushTokenHelper.getToken();
    if (token == null) return;
    _registeredToken = null;
    final result = await getIt<NotificationsDataSource>().unregisterDevice(
      token,
    );
    result.fold(
      (failure) => loggerWarn('FCM token unregister failed: ${failure.message}'),
      (_) {},
    );
  }

  static Future<void> _registerDevice(String token) async {
    final result = await getIt<NotificationsDataSource>().registerDevice(token);
    result.fold(
      (failure) => loggerWarn('FCM token register failed: ${failure.message}'),
      (_) => _registeredToken = token,
    );
  }

  /// اسم القناة ووصفها بيبانوا في إعدادات الإشعارات بتاعة الجهاز، فبتتعمل
  /// بعد ما الترجمة تتحمل
  static Future<void> _createAndroidChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            _channelId,
            'notifications.title'.tr(),
            description: 'notifications.channelDescription'.tr(),
            importance: Importance.high,
          ),
        );
  }

  static void _onForegroundMessage(RemoteMessage message) {
    // الجرس والصندوق بيتحدثوا عشان الإشعار الجديد يبان فيهم. من غير جلسة
    // الطلب هيرجع 401 ويحوّل للوجين، فبيتعرض الإشعار بس
    if (Session.isLoggedIn) {
      getIt<UnreadNotificationsCubit>().getUnreadCount();
      final inbox = getIt<NotificationsCubit>();
      if (!inbox.state.isInitial) inbox.refresh();
    }

    final notification = message.notification;
    if (!Platform.isAndroid || notification == null) return;
    _localNotifications.show(
      id: (message.messageId ?? message.data.toString()).hashCode & 0x7fffffff,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'notifications.title'.tr(),
          channelDescription: 'notifications.channelDescription'.tr(),
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode({
        ...message.data,
        _titleKey: notification.title,
        _bodyKey: notification.body,
      }),
    );
  }

  static void _openMessage(RemoteMessage message) {
    NotificationNavigation.openFromPush(
      NotificationModel.fromPushData(
        message.data,
        title: message.notification?.title,
        body: message.notification?.body,
      ),
    );
  }

  static void _openPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);
      NotificationNavigation.openFromPush(
        NotificationModel.fromPushData(
          data,
          title: data[_titleKey]?.toString(),
          body: data[_bodyKey]?.toString(),
        ),
      );
    } catch (e) {
      loggerWarn('Bad local notification payload: $e');
    }
  }
}
