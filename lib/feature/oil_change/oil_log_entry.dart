enum OilLogStatus { pending, approved, rejected }

/// تغيير زيت في السجل
class OilLogEntry {
  const OilLogEntry({
    required this.proofId,
    required this.status,
    required this.changeDate,
    required this.submittedAt,
    required this.odometerKm,
    this.image,
    this.cycleKm,
    this.rejectionReason,
    this.resubmitted = false,
  });

  final int proofId;
  final OilLogStatus status;
  final DateTime changeDate;
  final DateTime submittedAt;

  /// قراءة العداد الكلي وقت التغيير
  final int odometerKm;

  /// لينك صورة الإثبات
  final String? image;

  /// المسافة اللي اتمشت في الدورة دي لحد التغيير اللي بعده، وnull لو هي
  /// الدورة الحالية
  final int? cycleKm;

  /// سبب الرفض زي ما بيرجع من الـ API
  final String? rejectionReason;

  /// الراكب بعت إثبات جديد بعد الرفض
  final bool resubmitted;
}
