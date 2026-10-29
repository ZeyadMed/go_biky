import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:go_biky/core/helpers/utc_date_parser.dart';

/// الأنواع اللي بتوصل للسواق، والنوع بيحدد الشاشة اللي بتتفتح لما يدوس
enum NotificationType {
  /// وصل ٤٠٠ / ٤٥٠ كم
  maintenanceWarning,

  /// وصل ٥٠٠ كم (آخر تنبيه)، وبيتكرر كل يوم
  maintenanceCritical,

  /// عدّى ٦٠٠ كم والغرامة بتتحسب بالكيلو، وبيتكرر كل يوم
  oilChangeOverdue,

  /// الفيديو اتقبل أو اترفض أو انتهى، والنتيجة في `data['status']`
  oilChangeReview,

  /// الدراجة خرجت من المنطقة المسموحة
  zoneExit,

  /// مديونية جديدة (فاتورة تصليح أو غرامة زيت)
  driverCharge,

  /// اتسجلت دفعة
  driverPayment,

  /// الرخصة قربت تنتهي أو انتهت
  documentExpiring,

  /// أي نوع تاني الباك بيبعته (زي General) بيتفتح في التفاصيل
  other;

  /// الباك بيبعتها PascalCase زي `MaintenanceWarning`
  static NotificationType fromJson(Object? value) {
    final name = value?.toString().toLowerCase();
    return values.firstWhere(
      (type) => type.name.toLowerCase() == name,
      orElse: () => other,
    );
  }
}

/// الـ Critical بيوصل بأولوية عالية، وأغلبه محتاج تأكيد من السواق
enum NotificationSeverity {
  info,
  warning,
  critical;

  static NotificationSeverity fromJson(Object? value) =>
      switch (value?.toString().toLowerCase()) {
        'critical' => critical,
        'warning' => warning,
        _ => info,
      };
}

/// إشعار من الصندوق، أو من الـ push بنفس الحقول (`fromPushData`)
class NotificationModel extends Equatable {
  final String id;
  final NotificationType type;
  final NotificationSeverity severity;

  /// النصوص بتيجي جاهزة بالعربي من الباك
  final String title;
  final String body;
  final String? relatedEntityType;
  final String? relatedEntityId;

  /// الحقول الزيادة زي `motorcycleId` و `level` و `distanceKm` و `status`،
  /// ونفسها اللي في `data` بتاعة الـ push
  final Map<String, String> data;
  final bool requiresAcknowledgement;
  final DateTime createdAtUtc;
  final DateTime? readAtUtc;
  final DateTime? acknowledgedAtUtc;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.body,
    required this.relatedEntityType,
    required this.relatedEntityId,
    required this.data,
    required this.requiresAcknowledgement,
    required this.createdAtUtc,
    required this.readAtUtc,
    required this.acknowledgedAtUtc,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: NotificationType.fromJson(json['type']),
      severity: NotificationSeverity.fromJson(json['severity']),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      relatedEntityType: json['relatedEntityType']?.toString(),
      relatedEntityId: json['relatedEntityId']?.toString(),
      data: _decodeData(json['dataJson']),
      requiresAcknowledgement: json['requiresAcknowledgement'] == true,
      createdAtUtc:
          parseUtcDate(json['createdAtUtc']) ?? DateTime.now().toUtc(),
      readAtUtc: parseUtcDate(json['readAtUtc']),
      acknowledgedAtUtc: parseUtcDate(json['acknowledgedAtUtc']),
    );
  }

  /// من `data` بتاعة الـ push (كل قيمها strings)، والعنوان والنص من
  /// `notification`. الـ push مافيهوش وقت ولا `requiresAcknowledgement`،
  /// فالشاشات بتقرا نسخة الصندوق أول ما توصل
  factory NotificationModel.fromPushData(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    return NotificationModel(
      id: data['notificationId']?.toString() ?? '',
      type: NotificationType.fromJson(data['type']),
      severity: NotificationSeverity.fromJson(data['severity']),
      title: title ?? '',
      body: body ?? '',
      relatedEntityType: data['entityType']?.toString(),
      relatedEntityId: data['entityId']?.toString(),
      data: _stringMap(data),
      requiresAcknowledgement: false,
      createdAtUtc: DateTime.now().toUtc(),
      readAtUtc: null,
      acknowledgedAtUtc: null,
    );
  }

  /// `dataJson` بيرجع JSON جوه string، ولو باظ بنكمل من غيره
  static Map<String, String> _decodeData(Object? dataJson) {
    try {
      final decoded = dataJson is String && dataJson.isNotEmpty
          ? jsonDecode(dataJson)
          : dataJson;
      return decoded is Map ? _stringMap(decoded) : const {};
    } on FormatException {
      return const {};
    }
  }

  static Map<String, String> _stringMap(Map<dynamic, dynamic> map) => {
    for (final MapEntry(:key, :value) in map.entries)
      if (value != null) key.toString(): value.toString(),
  };

  bool get isRead => readAtUtc != null;

  /// إشعار مهم لسه مستني السواق يدوس "تم"
  bool get needsAcknowledgement =>
      requiresAcknowledgement && acknowledgedAtUtc == null;

  NotificationModel copyWith({
    DateTime? readAtUtc,
    DateTime? acknowledgedAtUtc,
  }) {
    return NotificationModel(
      id: id,
      type: type,
      severity: severity,
      title: title,
      body: body,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
      data: data,
      requiresAcknowledgement: requiresAcknowledgement,
      createdAtUtc: createdAtUtc,
      readAtUtc: readAtUtc ?? this.readAtUtc,
      acknowledgedAtUtc: acknowledgedAtUtc ?? this.acknowledgedAtUtc,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    severity,
    title,
    body,
    relatedEntityType,
    relatedEntityId,
    data,
    requiresAcknowledgement,
    createdAtUtc,
    readAtUtc,
    acknowledgedAtUtc,
  ];
}
