import 'package:equatable/equatable.dart';
import 'package:go_biky/feature/balance/data/model/balance_model.dart';
import 'package:go_biky/feature/balance/data/model/statement_entry_model.dart';

/// كشف الحساب: الرصيد الحالي والحركات زي ما الباك بيرتبها
class StatementModel extends Equatable {
  final BalanceModel balance;
  final List<StatementEntryModel> entries;

  const StatementModel({required this.balance, required this.entries});

  factory StatementModel.fromJson(Map<String, dynamic> json) {
    final balance = json['balance'];
    final entries = json['entries'];

    return StatementModel(
      balance: BalanceModel.fromJson(
        balance is Map ? Map<String, dynamic>.from(balance) : const {},
      ),
      entries: entries is List
          ? [
              for (final entry in entries)
                if (entry is Map)
                  StatementEntryModel.fromJson(
                    Map<String, dynamic>.from(entry),
                  ),
            ]
          : const [],
    );
  }

  @override
  List<Object?> get props => [balance, entries];
}
