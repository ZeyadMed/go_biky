import 'package:equatable/equatable.dart';

/// رصيد السواق زي ما الباك بيحسبه
class BalanceModel extends Equatable {
  final String driverId;
  final String driverName;

  /// كل المستحقات اللي اتسجلت على السواق
  final double totalCharged;
  final double totalPaid;

  /// المديونية: المتبقي عليه من المستحقات
  final double outstanding;

  /// الرصيد اللي ليه لما يدفع أكتر من المستحق
  final double credit;

  /// مش معروضة في الشاشات لحد ما يتأكد هي عدد المستحقات المفتوحة ولا مبلغها
  final double openCharges;

  const BalanceModel({
    required this.driverId,
    required this.driverName,
    required this.totalCharged,
    required this.totalPaid,
    required this.outstanding,
    required this.credit,
    required this.openCharges,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      driverId: json['driverId']?.toString() ?? '',
      driverName: json['driverName']?.toString() ?? '',
      totalCharged: (json['totalCharged'] as num?)?.toDouble() ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
      outstanding: (json['outstanding'] as num?)?.toDouble() ?? 0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0,
      openCharges: (json['openCharges'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    driverId,
    driverName,
    totalCharged,
    totalPaid,
    outstanding,
    credit,
    openCharges,
  ];
}
