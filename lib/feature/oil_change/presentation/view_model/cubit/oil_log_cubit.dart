import 'package:go_biky/core/bloc/genaric_pagination.dart';
import 'package:go_biky/core/http/either.dart';
import 'package:go_biky/core/http/failure.dart';
import 'package:go_biky/feature/oil_change/data/datasource/oil_change_data_source.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_change_model.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_changes_page.dart';

/// سجل تغييرات الزيت بالصفحات، والصفحة اللي بعدها بتيجي لما السكرول يوصل
/// للآخر على `scrollController`
class OilLogCubit extends GenericPaginationCubit<OilChangeModel> {
  OilLogCubit(this._dataSource) {
    initPagination();
  }

  final OilChangeDataSource _dataSource;

  @override
  Future<Either<Failure, OilChangesPage>> loadPage(int page) =>
      _dataSource.getOilChanges(page: page);
}
