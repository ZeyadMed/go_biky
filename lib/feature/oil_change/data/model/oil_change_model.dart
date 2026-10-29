import 'package:equatable/equatable.dart';
import 'package:go_biky/core/helpers/utc_date_parser.dart';

/// حالة طلب تغيير الزيت عند المشرف
enum OilChangeStatus {
  pending,
  approved,
  rejected;

  /// أي قيمة مش معروفة بتتعامل كـ pending لحد ما المشرف يرد
  static OilChangeStatus fromJson(Object? value) =>
      switch (value?.toString().toLowerCase()) {
        'approved' => approved,
        'rejected' => rejected,
        _ => pending,
      };
}

/// طلب تغيير زيت بفيديو الإثبات، زي ما بيرجع في السجل أو بعد الرفع
class OilChangeModel extends Equatable {
  final String id;
  final String motorcycleId;
  final String plateNumber;
  final String driverId;
  final String driverName;
  final String officeId;
  final DateTime submittedAtUtc;

  /// عداد دورة الزيت وقت الرفع
  final int kmAtSubmit;

  /// العداد الكلي للدراجة وقت الرفع، لو اتسجل
  final int? odometerKmAtSubmit;
  final String? driverNotes;
  final bool videoAvailable;
  final String? videoFileName;
  final int? videoSizeBytes;
  final DateTime? videoDeletedAtUtc;
  final OilChangeStatus status;
  final DateTime? reviewedAtUtc;
  final String? reviewedById;
  final String? rejectReason;
  final String? maintenanceRecordId;
  final int finedKm;
  final double fineRatePerKm;
  final double fineAmount;
  final String? driverChargeId;

  const OilChangeModel({
    required this.id,
    required this.motorcycleId,
    required this.plateNumber,
    required this.driverId,
    required this.driverName,
    required this.officeId,
    required this.submittedAtUtc,
    required this.kmAtSubmit,
    required this.odometerKmAtSubmit,
    required this.driverNotes,
    required this.videoAvailable,
    required this.videoFileName,
    required this.videoSizeBytes,
    required this.videoDeletedAtUtc,
    required this.status,
    required this.reviewedAtUtc,
    required this.reviewedById,
    required this.rejectReason,
    required this.maintenanceRecordId,
    required this.finedKm,
    required this.fineRatePerKm,
    required this.fineAmount,
    required this.driverChargeId,
  });

  factory OilChangeModel.fromJson(Map<String, dynamic> json) {
    return OilChangeModel(
      id: json['id']?.toString() ?? '',
      motorcycleId: json['motorcycleId']?.toString() ?? '',
      plateNumber: json['plateNumber']?.toString() ?? '',
      driverId: json['driverId']?.toString() ?? '',
      driverName: json['driverName']?.toString() ?? '',
      officeId: json['officeId']?.toString() ?? '',
      submittedAtUtc:
          parseUtcDate(json['submittedAtUtc']) ?? DateTime.now().toUtc(),
      kmAtSubmit: (json['kmAtSubmit'] as num?)?.toInt() ?? 0,
      odometerKmAtSubmit: (json['odometerKmAtSubmit'] as num?)?.toInt(),
      driverNotes: json['driverNotes']?.toString(),
      videoAvailable: json['videoAvailable'] == true,
      videoFileName: json['videoFileName']?.toString(),
      videoSizeBytes: (json['videoSizeBytes'] as num?)?.toInt(),
      videoDeletedAtUtc: parseUtcDate(json['videoDeletedAtUtc']),
      status: OilChangeStatus.fromJson(json['status']),
      reviewedAtUtc: parseUtcDate(json['reviewedAtUtc']),
      reviewedById: json['reviewedById']?.toString(),
      rejectReason: json['rejectReason']?.toString(),
      maintenanceRecordId: json['maintenanceRecordId']?.toString(),
      finedKm: (json['finedKm'] as num?)?.toInt() ?? 0,
      fineRatePerKm: (json['fineRatePerKm'] as num?)?.toDouble() ?? 0,
      fineAmount: (json['fineAmount'] as num?)?.toDouble() ?? 0,
      driverChargeId: json['driverChargeId']?.toString(),
    );
  }

  /// أول جزء من الـ id، بيتعرض كرقم الإثبات بدل الـ GUID كله
  String get shortId => id.split('-').first;

  @override
  List<Object?> get props => [
    id,
    motorcycleId,
    plateNumber,
    driverId,
    driverName,
    officeId,
    submittedAtUtc,
    kmAtSubmit,
    odometerKmAtSubmit,
    driverNotes,
    videoAvailable,
    videoFileName,
    videoSizeBytes,
    videoDeletedAtUtc,
    status,
    reviewedAtUtc,
    reviewedById,
    rejectReason,
    maintenanceRecordId,
    finedKm,
    fineRatePerKm,
    fineAmount,
    driverChargeId,
  ];
}
