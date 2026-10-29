import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_biky/core/cache_manager/cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// بيرد على طلبات Dio من غير نت، وبيسجل كل طلب وصله
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object? data, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Never connectionError(RequestOptions options) {
  throw DioException(
    requestOptions: options,
    type: DioExceptionType.connectionError,
  );
}

Dio fakeDio(FakeAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://test.local'))
      ..httpClientAdapter = adapter;

/// prefs و secure storage في الذاكرة، وبيرجّع الـ secure storage عشان
/// التست يتأكد إن التوكنز اتحفظت فيه
Future<Map<String, String>> setUpStorage({
  Map<String, Object> prefs = const {},
  Map<String, String>? secure,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final secureData = secure ?? <String, String>{};
  FlutterSecureStorage.setMockInitialValues(secureData);
  await CacheManager.init();
  return secureData;
}
