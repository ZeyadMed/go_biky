import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/feature/notifications/app_notification.dart';

// TODO: الإشعارات بتيجي من الـ API، والبيانات دي مؤقتة ومتحسبة من دلوقتي
// عشان التجميع (اليوم / أمس / سابقاً) يبان صح
List<AppNotification> _tempNotifications() {
  final now = DateTime.now();

  return [
    AppNotification(
      id: 5,
      type: NotificationType.oilDue,
      title: 'حان وقت العناية بالزيت',
      body: 'وصلت إلى ٤٥ كم. يتبقى ٥ كم فقط؛ غيّر الزيت وأرسل الإثبات.',
      createdAt: now.subtract(const Duration(minutes: 5)),
    ),
    AppNotification(
      id: 4,
      type: NotificationType.order,
      title: 'طلب #٢٠٣٦ جاهز للاستلام',
      body: 'الإطار الخلفي متاح في مركز الياسمين. ننتظرك خلال ساعات العمل.',
      createdAt: now.subtract(const Duration(hours: 1)),
      orderId: 2036,
    ),
    AppNotification(
      id: 3,
      type: NotificationType.oilProof,
      title: 'إثبات الزيت قيد المراجعة',
      body: 'استلمنا إثباتك #٧٨٢. يبقى العداد دون تصفير حتى الموافقة.',
      createdAt: now.subtract(const Duration(hours: 4)),
    ),
    AppNotification(
      id: 2,
      type: NotificationType.oilProof,
      title: 'تم اعتماد تغيير الزيت',
      body: 'اعتُمد تغيير ٢٤ أكتوبر عند ١٢٬٤٥٠ كم وبدأت دورة زيت جديدة.',
      createdAt: DateTime(now.year, now.month, now.day - 1, 8, 45),
      isRead: true,
    ),
    AppNotification(
      id: 1,
      type: NotificationType.order,
      title: 'تحديث طلبك #٢٠١٩',
      body: 'طقم السلسلة والتروس قيد المراجعة. سنبلغك عند التوفر.',
      createdAt: DateTime(now.year, now.month, now.day - 3, 15, 20),
      isRead: true,
      orderId: 2019,
    ),
  ];
}

/// الإشعارات من الأحدث للأقدم. متسجل singleton في get_it عشان نقطة الجرس في
/// الرئيسية تختفي أول ما الراكب يقرا الإشعارات
class NotificationsCubit extends Cubit<List<AppNotification>> {
  NotificationsCubit() : super(List.unmodifiable(_tempNotifications()));

  int get unreadCount => state.where((item) => !item.isRead).length;

  // TODO: إبلاغ الـ API بالقراءة لما يجهز
  void markAsRead(int id) => emit(
    List.unmodifiable([
      for (final item in state)
        item.id == id && !item.isRead ? item.asRead() : item,
    ]),
  );

  void markAllAsRead() => emit(
    List.unmodifiable([
      for (final item in state) item.isRead ? item : item.asRead(),
    ]),
  );
}
