import 'package:flutter/material.dart';

/// الصفحات القانونية اللي محتواها لسه مؤقت. سياسة الخصوصية بقت من الـ API
/// في `PrivacyPolicyScreen`
enum PolicyType {
  terms('profile.terms', Icons.description_outlined, darkHighlight: false);

  const PolicyType(
    this.titleKey,
    this.highlightIcon, {
    required this.darkHighlight,
  });

  final String titleKey;
  final IconData highlightIcon;

  /// كارت الملخص غامق (الخصوصية) ولا بلون البراند الفاتح (الشروط)
  final bool darkHighlight;
}

typedef PolicySection = ({String title, String body});

/// محتوى سياسة الخصوصية أو الشروط زي ما بيرجع من الـ API
class PolicyDocument {
  const PolicyDocument({
    required this.updatedAt,
    required this.sections,
    this.highlight,
  });

  final DateTime updatedAt;
  final List<PolicySection> sections;

  /// الكارت الغامق اللي فوق، لو موجود
  final PolicySection? highlight;

  /// بالدقايق على أساس ١٨٠ كلمة في الدقيقة، وأقل حاجة دقيقة
  int get readMinutes {
    final text = [
      ?highlight?.body,
      for (final section in sections) section.body,
    ].join(' ');
    final words = text.split(RegExp(r'\s+')).length;
    return (words / 180).ceil().clamp(1, 999);
  }
}
