import 'package:equatable/equatable.dart';
import 'package:go_biky/core/helpers/utc_date_parser.dart';

/// حركة في كشف الحساب: مستحق على السواق (`debit`) أو دفعة منه (`credit`)
class StatementEntryModel extends Equatable {
  final String id;
  final DateTime atUtc;

  /// زي Payment. الشاشة بتعتمد على `debit` و`credit` مش على النوع
  final String type;
  final String description;
  final double debit;
  final double credit;

  /// الرصيد بعد الحركة: الموجب مديونية على السواق والسالب رصيد ليه
  final double runningBalance;

  const StatementEntryModel({
    required this.id,
    required this.atUtc,
    required this.type,
    required this.description,
    required this.debit,
    required this.credit,
    required this.runningBalance,
  });

  factory StatementEntryModel.fromJson(Map<String, dynamic> json) {
    return StatementEntryModel(
      id: json['id']?.toString() ?? '',
      atUtc: parseUtcDate(json['atUtc']) ?? DateTime.now().toUtc(),
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      debit: (json['debit'] as num?)?.toDouble() ?? 0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0,
      runningBalance: (json['runningBalance'] as num?)?.toDouble() ?? 0,
    );
  }

  /// دفعة من السواق، وغير كده مستحق عليه
  bool get isPayment => credit > 0;

  double get amount => isPayment ? credit : debit;

  @override
  List<Object?> get props => [
    id,
    atUtc,
    type,
    description,
    debit,
    credit,
    runningBalance,
  ];
}
