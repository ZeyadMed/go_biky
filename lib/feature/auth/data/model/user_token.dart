import 'package:equatable/equatable.dart';

/// ريسبونس لوجين السواق: التوكنز وبيانات السواق الأساسية
class UserToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String message;
  final String driverId;
  final String fullName;
  final String phoneNumber;
  final String officeId;
  final DateTime expiresAtUtc;

  const UserToken({
    required this.accessToken,
    required this.refreshToken,
    required this.message,
    required this.driverId,
    required this.fullName,
    required this.phoneNumber,
    required this.officeId,
    required this.expiresAtUtc,
  });

  factory UserToken.fromJson(Map<String, dynamic> json) {
    // لو `accessToken` في الجذر يبقى إحنا واصلنا الـ `data` نفسها،
    // غير كده بندوّر على مفتاح `data`.
    final raw = json.containsKey('accessToken') ? json : json['data'];
    final data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : const <String, dynamic>{};

    return UserToken(
      accessToken: data['accessToken']?.toString() ?? "",
      refreshToken: data['refreshToken']?.toString() ?? "",
      message: (json['message'] ?? data['message'])?.toString() ?? "",
      driverId: data['driverId']?.toString() ?? "",
      fullName: data['fullName']?.toString() ?? "",
      phoneNumber: data['phoneNumber']?.toString() ?? "",
      officeId: data['officeId']?.toString() ?? "",
      // السيرفر بيرجع الوقت UTC بدون `Z` أحيانًا — بنجبره UTC عشان
      // المقارنة مع `DateTime.now().toUtc()` تبقى صح.
      expiresAtUtc: _parseUtc(data['expiresAtUtc']),
    );
  }

  static DateTime _parseUtc(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return DateTime.now().toUtc();
    return parsed.isUtc
        ? parsed
        : DateTime.utc(
            parsed.year,
            parsed.month,
            parsed.day,
            parsed.hour,
            parsed.minute,
            parsed.second,
            parsed.millisecond,
            parsed.microsecond,
          );
  }

  /// فيه توكن فعلي محفوظ؟
  bool get isValid => accessToken.isNotEmpty;

  bool get hasRefreshToken => refreshToken.isNotEmpty;

  /// انتهت صلاحية الـ access token؟ بنسيب هامش دقيقة عشان ما نبعتش
  /// ريكوست بتوكن هيقع على السيرفر وهو في السكة.
  bool get isExpired => DateTime.now().toUtc().isAfter(
    expiresAtUtc.subtract(const Duration(minutes: 1)),
  );

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "message": message,
      "driverId": driverId,
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "officeId": officeId,
      "expiresAtUtc": expiresAtUtc.toIso8601String(),
    };
  }

  UserToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? message,
    String? driverId,
    String? fullName,
    String? phoneNumber,
    String? officeId,
    DateTime? expiresAtUtc,
  }) {
    return UserToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      message: message ?? this.message,
      driverId: driverId ?? this.driverId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      officeId: officeId ?? this.officeId,
      expiresAtUtc: expiresAtUtc ?? this.expiresAtUtc,
    );
  }

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    message,
    driverId,
    fullName,
    phoneNumber,
    officeId,
    expiresAtUtc,
  ];
}
