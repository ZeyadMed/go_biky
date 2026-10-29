import 'package:equatable/equatable.dart';

/// رقم تواصل من الإدارة، والأرقام محلية زي ما الباك بيرجعها (01xxxxxxxxx)
class ContactModel extends Equatable {
  final String id;
  final String name;

  /// فاضي لو الرقم ده واتساب بس
  final String phoneNumber;

  /// فاضي لو الرقم ده اتصال بس
  final String whatsAppNumber;
  final bool isActive;
  final int sortOrder;

  const ContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.whatsAppNumber,
    required this.isActive,
    required this.sortOrder,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString().trim() ?? '',
      phoneNumber: json['phoneNumber']?.toString().trim() ?? '',
      whatsAppNumber: json['whatsAppNumber']?.toString().trim() ?? '',
      // الباك ممكن مايبعتهاش، فالرقم بيتعرض إلا لو اتقفل صراحةً
      isActive: json['isActive'] != false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    whatsAppNumber,
    isActive,
    sortOrder,
  ];
}
