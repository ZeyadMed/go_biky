import 'dart:io';

import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/core/http/either.dart';
import 'package:go_biky/core/http/endpoints.dart';
import 'package:go_biky/core/http/failure.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_change_model.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_changes_page.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_status_model.dart';

class OilChangeDataSource {
  OilChangeDataSource(this._dataSource);

  final GenericDataSource _dataSource;

  static const _pageSize = 10;

  Future<Either<Failure, OilStatusModel>> getOilStatus() {
    return _dataSource.fetchResult<OilStatusModel>(
      endpoint: Endpoints.oilStatus,
      fromJson: OilStatusModel.fromJson,
    );
  }

  /// `page` بيبدأ من 1
  Future<Either<Failure, OilChangesPage>> getOilChanges({required int page}) {
    return _dataSource.fetchResult<OilChangesPage>(
      endpoint: Endpoints.oilChanges,
      queryParameters: {'PageIndex': page, 'PageSize': _pageSize},
      fromJson: OilChangesPage.fromJson,
    );
  }

  /// `video` لازم يكون فيديو، والشاشة بتتأكد من ده قبل ما تبعته
  Future<Either<Failure, OilChangeModel>> submitOilChange({
    required File video,
    String? notes,
  }) {
    return _dataSource.postFormData<OilChangeModel>(
      endpoint: Endpoints.oilChanges,
      data: {
        'Video': video,
        if (notes != null && notes.isNotEmpty) 'Notes': notes,
      },
      // postFormData بتبعت الريسبونس كامل، والطلب نفسه جوه data
      fromJson: (json) =>
          OilChangeModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
