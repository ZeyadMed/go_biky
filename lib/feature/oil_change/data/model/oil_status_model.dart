import 'package:equatable/equatable.dart';
import 'package:go_biky/core/helpers/utc_date_parser.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_change_model.dart';

/// حالة عداد الزيت لدراجة السواق الحالية
class OilStatusModel extends Equatable {
  final String motorcycleId;
  final String plateNumber;

  /// الدراجة عليها عداد بيحسب المسافة ولا لأ
  final bool hasCounter;

  /// المسافة من آخر تغيير زيت معتمد
  final int kmSinceOilChange;
  final DateTime? countingSinceUtc;
  final int firstWarningKm;
  final int secondWarningKm;
  final int criticalKm;

  /// أقصى مسافة، وبعدها كل كيلو عليه غرامة `finePerKm`
  final int maxKm;

  /// المستوى زي ما الباك بيحسبه (زي Overdue)
  final String currentLevel;

  /// بيبقى بالسالب لو المسافة عدّت `maxKm`
  final int remainingToMaxKm;
  final int overdueKm;
  final double finePerKm;
  final double estimatedFine;

  /// آخر طلب تغيير اتبعت، و null لو مفيش
  final OilChangeModel? latestSubmission;
  final DateTime? updatedAtUtc;

  const OilStatusModel({
    required this.motorcycleId,
    required this.plateNumber,
    required this.hasCounter,
    required this.kmSinceOilChange,
    required this.countingSinceUtc,
    required this.firstWarningKm,
    required this.secondWarningKm,
    required this.criticalKm,
    required this.maxKm,
    required this.currentLevel,
    required this.remainingToMaxKm,
    required this.overdueKm,
    required this.finePerKm,
    required this.estimatedFine,
    required this.latestSubmission,
    required this.updatedAtUtc,
  });

  factory OilStatusModel.fromJson(Map<String, dynamic> json) {
    final latestSubmission = json['latestSubmission'];

    return OilStatusModel(
      motorcycleId: json['motorcycleId']?.toString() ?? '',
      plateNumber: json['plateNumber']?.toString() ?? '',
      hasCounter: json['hasCounter'] == true,
      kmSinceOilChange: (json['kmSinceOilChange'] as num?)?.toInt() ?? 0,
      countingSinceUtc: parseUtcDate(json['countingSinceUtc']),
      firstWarningKm: (json['firstWarningKm'] as num?)?.toInt() ?? 0,
      secondWarningKm: (json['secondWarningKm'] as num?)?.toInt() ?? 0,
      criticalKm: (json['criticalKm'] as num?)?.toInt() ?? 0,
      maxKm: (json['maxKm'] as num?)?.toInt() ?? 0,
      currentLevel: json['currentLevel']?.toString() ?? '',
      remainingToMaxKm: (json['remainingToMaxKm'] as num?)?.toInt() ?? 0,
      overdueKm: (json['overdueKm'] as num?)?.toInt() ?? 0,
      finePerKm: (json['finePerKm'] as num?)?.toDouble() ?? 0,
      estimatedFine: (json['estimatedFine'] as num?)?.toDouble() ?? 0,
      latestSubmission: latestSubmission is Map
          ? OilChangeModel.fromJson(Map<String, dynamic>.from(latestSubmission))
          : null,
      updatedAtUtc: parseUtcDate(json['updatedAtUtc']),
    );
  }

  @override
  List<Object?> get props => [
    motorcycleId,
    plateNumber,
    hasCounter,
    kmSinceOilChange,
    countingSinceUtc,
    firstWarningKm,
    secondWarningKm,
    criticalKm,
    maxKm,
    currentLevel,
    remainingToMaxKm,
    overdueKm,
    finePerKm,
    estimatedFine,
    latestSubmission,
    updatedAtUtc,
  ];
}
