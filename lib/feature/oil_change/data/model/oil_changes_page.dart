import 'package:go_biky/core/bloc/genaric_pagination.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_change_model.dart';

/// صفحة من سجل تغييرات الزيت
class OilChangesPage implements PaginatedPage<OilChangeModel> {
  const OilChangesPage({
    required this.pageIndex,
    required this.pageSize,
    required this.count,
    required this.totalPages,
    required this.items,
  });

  final int pageIndex;
  final int pageSize;
  final int count;
  final int totalPages;

  /// الـ `data` اللي جوه الصفحة
  @override
  final List<OilChangeModel> items;

  factory OilChangesPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return OilChangesPage(
      pageIndex: (json['pageIndex'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      items: data is List
          ? data
                .map(
                  (item) => OilChangeModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
    );
  }

  @override
  PageInfo get pagination => (
    currentPage: pageIndex,
    pagesCount: totalPages,
    perPage: pageSize,
    total: count,
  );
}
