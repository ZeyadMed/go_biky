import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/core/http/either.dart';
import 'package:go_biky/core/http/endpoints.dart';
import 'package:go_biky/core/http/failure.dart';
import 'package:go_biky/feature/balance/data/model/balance_model.dart';
import 'package:go_biky/feature/balance/data/model/statement_model.dart';

class BalanceDataSource {
  BalanceDataSource(this._dataSource);

  final GenericDataSource _dataSource;

  Future<Either<Failure, BalanceModel>> getBalance() {
    return _dataSource.fetchResult<BalanceModel>(
      endpoint: Endpoints.balance,
      fromJson: BalanceModel.fromJson,
    );
  }

  Future<Either<Failure, StatementModel>> getStatement() {
    return _dataSource.fetchResult<StatementModel>(
      endpoint: Endpoints.statement,
      fromJson: StatementModel.fromJson,
    );
  }
}
