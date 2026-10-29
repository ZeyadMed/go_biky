import 'package:equatable/equatable.dart';
import 'package:go_biky/core/helpers/utc_date_parser.dart';

/// صفحة محتوى من الباك (زي سياسة الخصوصية)، والمحتوى نفسه HTML
class PolicyPageModel extends Equatable {
  final String key;

  /// null لو الإدارة ماكتبتش عنوان، والشاشة بتعرض عنوانها
  final String? title;
  final String html;
  final DateTime? updatedAtUtc;

  const PolicyPageModel({
    required this.key,
    required this.title,
    required this.html,
    required this.updatedAtUtc,
  });

  factory PolicyPageModel.fromJson(Map<String, dynamic> json) {
    final title = json['title']?.toString().trim();

    return PolicyPageModel(
      key: json['key']?.toString() ?? '',
      title: title == null || title.isEmpty ? null : title,
      html: json['html']?.toString() ?? '',
      updatedAtUtc: parseUtcDate(json['updatedAtUtc']),
    );
  }

  /// الصفحة لسه ماتنشرتش لو مفيش فيها نص
  bool get isEmpty =>
      html.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '').trim().isEmpty;

  @override
  List<Object?> get props => [key, title, html, updatedAtUtc];
}
