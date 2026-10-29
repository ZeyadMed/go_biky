/// الباك بيرجع أوقات UTC أحياناً من غير `Z`، و`DateTime.parse` بيعتبرها
/// وقت محلي، فبنجبرها UTC. بترجع null لو القيمة فاضية أو مش تاريخ
DateTime? parseUtcDate(Object? value) {
  final parsed = DateTime.tryParse(value?.toString() ?? '');
  if (parsed == null || parsed.isUtc) return parsed;
  return DateTime.utc(
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
