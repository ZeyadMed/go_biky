enum OilProofStatus { pending, approved }

/// إثبات تغيير زيت اتبعت للمشرف
class OilChangeProof {
  const OilChangeProof({
    required this.id,
    required this.status,
    required this.image,
    required this.submittedAt,
    required this.changeDate,
    required this.odometerKm,
    required this.kmUsed,
    required this.kmInterval,
    this.approvedAt,
  });

  final int id;
  final OilProofStatus status;

  /// مسار الصورة على الجهاز أو لينكها
  final String image;
  final DateTime submittedAt;
  final DateTime changeDate;

  /// بيبقى موجود لما `status` تبقى approved
  final DateTime? approvedAt;

  /// قراءة العداد الكلي وقت التغيير
  final int odometerKm;

  /// المسافة من آخر تغيير وقت رفع الإثبات
  final int kmUsed;

  /// المسافة المفروض يتغير بعدها
  final int kmInterval;
}
