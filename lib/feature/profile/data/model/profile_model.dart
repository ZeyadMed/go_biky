import 'package:equatable/equatable.dart';

/// بيانات السواق اللي بتتعرض في الرئيسية وحسابي
class ProfileModel extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;

  /// زي "فرع المعادي"
  final String? officeName;

  /// الاتنين null لو مفيش دراجة متسلّمة للسواق دلوقتي
  final String? currentMotorcyclePlate;
  final String? currentMotorcycleType;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.officeName,
    required this.currentMotorcyclePlate,
    required this.currentMotorcycleType,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    String? text(Object? value) {
      final text = value?.toString().trim();
      return text == null || text.isEmpty ? null : text;
    }

    return ProfileModel(
      id: json['id']?.toString() ?? '',
      fullName: text(json['fullName']) ?? '',
      phoneNumber: text(json['phoneNumber']) ?? '',
      officeName: text(json['officeName']),
      currentMotorcyclePlate: text(json['currentMotorcyclePlate']),
      currentMotorcycleType: text(json['currentMotorcycleType']),
    );
  }

  bool get hasBike =>
      currentMotorcycleType != null || currentMotorcyclePlate != null;

  @override
  List<Object?> get props => [
    id,
    fullName,
    phoneNumber,
    officeName,
    currentMotorcyclePlate,
    currentMotorcycleType,
  ];
}
