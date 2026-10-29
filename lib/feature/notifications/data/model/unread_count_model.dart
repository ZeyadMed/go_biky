import 'package:equatable/equatable.dart';

/// عدادات الجرس من الباك، لأن الصندوق بالصفحات فمانقدرش نعدّها منه
class UnreadCountModel extends Equatable {
  final int unread;
  final int unreadCritical;

  /// إشعارات مهمة لسه مستنية "تم"
  final int pendingAcknowledgement;

  const UnreadCountModel({
    required this.unread,
    required this.unreadCritical,
    required this.pendingAcknowledgement,
  });

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) {
    return UnreadCountModel(
      unread: (json['unread'] as num?)?.toInt() ?? 0,
      unreadCritical: (json['unreadCritical'] as num?)?.toInt() ?? 0,
      pendingAcknowledgement:
          (json['pendingAcknowledgement'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [unread, unreadCritical, pendingAcknowledgement];
}
