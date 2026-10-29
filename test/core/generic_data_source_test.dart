import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_biky/core/cache_manager/cache_manager.dart';
import 'package:go_biky/core/helpers/generic_data_source.dart';
import 'package:go_biky/core/http/api_consumer.dart';
import 'package:go_biky/core/http/either.dart';
import 'package:go_biky/core/http/failure.dart';

import '../helpers/fake_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => setUpStorage());

  GenericDataSource sourceWith(FakeAdapter adapter) => GenericDataSource(
    BaseApiConsumer(dio: fakeDio(adapter), retryDelay: Duration.zero),
  );

  group('authenticate', () {
    test('saves the tokens and the user after parsing', () async {
      final adapter = FakeAdapter(
        (_) async => jsonBody({
          'data': {
            'accessToken': 'a',
            'refreshToken': 'r',
            'userId': '7',
            'userName': 'Ali',
            'role': 'Driver',
          },
        }),
      );

      final result = await sourceWith(adapter).authenticate<String>(
        endpoint: '/login',
        fromJson: (json) => json['data']['userName'] as String,
      );

      expect(result.getOrThrow(), 'Ali');
      expect(CacheManager.getAccessTokenSync(), 'a');
      expect(CacheManager.getRefreshTokenSync(), 'r');
      expect(CacheManager.getUserName(), 'Ali');
    });

    test('saves nothing when the response cannot be parsed', () async {
      final adapter = FakeAdapter(
        (_) async => jsonBody({
          'data': {'accessToken': 'a', 'refreshToken': 'r'},
        }),
      );

      final result = await sourceWith(adapter).authenticate<String>(
        endpoint: '/login',
        fromJson: (json) => throw const FormatException('bad shape'),
      );

      expect(result.throwError(), isA<ParsingFailure>());
      expect(CacheManager.getAccessTokenSync(), isNull);
    });
  });

  test('a parsing error in a list is a failure, not an empty list', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody({
        'data': [
          {'id': 1},
        ],
      }),
    );

    final result = await sourceWith(adapter).fetchData<int>(
      endpoint: '/items',
      fromJson: (json) => throw const FormatException('bad item'),
    );

    expect(result.throwError(), isA<ParsingFailure>());
    // نص الـ exception مايوصلش للمستخدم
    expect(result.throwError().message, isNot(contains('bad item')));
  });

  test('an empty 204 response is a success', () async {
    final adapter = FakeAdapter((_) async => ResponseBody.fromString('', 204));

    final result = await sourceWith(adapter)
        .deleteData<Null>(endpoint: '/items/1');

    expect(result.isSuccess, isTrue);
  });

  test('a list response is wrapped instead of failing the cast', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody([
        {'id': 1},
        {'id': 2},
      ]),
    );

    final result = await sourceWith(
      adapter,
    ).fetchData<int>(endpoint: '/items', fromJson: (json) => json['id'] as int);

    expect(result.getOrThrow(), [1, 2]);
  });

  group('GET retry', () {
    test('retries a connection error and then succeeds', () async {
      var attempts = 0;
      final adapter = FakeAdapter((options) async {
        attempts++;
        if (attempts < 3) connectionError(options);
        return jsonBody({
          'data': {'value': 1},
        });
      });

      final result = await sourceWith(adapter).fetchResult<int>(
        endpoint: '/value',
        fromJson: (json) => json['value'] as int,
      );

      expect(result.getOrThrow(), 1);
      expect(adapter.requests, hasLength(3));
    });

    test('does not retry a 404', () async {
      final adapter = FakeAdapter(
        (_) async => jsonBody({'message': 'missing'}, status: 404),
      );

      final result = await sourceWith(adapter)
          .fetchResult<int>(endpoint: '/value', fromJson: (json) => 0);

      expect(result.isError, isTrue);
      expect(adapter.requests, hasLength(1));
    });

    test('gives up after the max retries', () async {
      final adapter = FakeAdapter((options) async => connectionError(options));

      final result = await sourceWith(adapter)
          .fetchResult<int>(endpoint: '/value', fromJson: (json) => 0);

      expect(result.throwError(), isA<NetworkFailure>());
      expect(adapter.requests, hasLength(3));
    });
  });

  test('a missing upload file fails without sending the request', () async {
    final adapter = FakeAdapter((_) async => jsonBody({}));
    final missing = File('${Directory.systemTemp.path}/missing-video.mp4');

    final result = await sourceWith(adapter)
        .postFormData<Null>(endpoint: '/oil-changes', data: {'Video': missing});

    expect(result.throwError(), isA<CacheFailure>());
    expect(adapter.requests, isEmpty);
  });
}
