import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../cache_manager/cache_manager.dart';
import '../http/api_consumer.dart';
import '../http/either.dart';
import '../http/failure.dart';
import '../http/params.dart';
import '../http/session.dart';
import 'crash_reporter.dart';
import 'logger.dart';

class GenericDataSource {
  final ApiConsumer _apiConsumer;

  GenericDataSource(this._apiConsumer);

  /// بتبعت طلب مصادقة (لوجين / تسجيل / تحقق OTP) وبتحفظ التوكنين
  /// اللي راجعين في الريسبونس قبل ما ترجع الداتا.
  ///
  /// الريسبونس المتوقع:
  /// { "accessToken": "...", "refreshToken": "...", "message": {...} }
  Future<Either<Failure, T>> authenticate<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final result = await _apiConsumer.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    );

    // بنستخدم isError بدل fold عشان fold متزامنة والحفظ محتاج await
    if (result.isError) {
      return Left(result.throwError());
    }

    final right = result.getOrThrow();

    // بعض الاند بوينتس بترجع التوكنز في الروت وبعضها جوه data
    // فبندور في الاتنين بدل ما نفترض شكل واحد
    final payload = right['data'] is Map<String, dynamic>
        ? right['data'] as Map<String, dynamic>
        : right;

    final accessToken =
        (payload['accessToken'] ?? right['accessToken'])?.toString();
    final refreshToken =
        (payload['refreshToken'] ?? right['refreshToken'])?.toString();

    if (accessToken == null || accessToken.isEmpty) {
      loggerWarn('Auth response had no accessToken');
      return Left(ParsingFailure(message: 'errors.invalidAuthResponse'.tr()));
    }

    // الـ refreshToken هو اللي بيخلي الجلسة مستمرة، فلو مش موجود
    // المستخدم هيتطرد أول ما الـ access يقع.
    if (refreshToken == null || refreshToken.isEmpty) {
      loggerWarn('Auth response had no refreshToken');
    }

    // بنفك الريسبونس الأول، ولو فشل مانحفظش حاجة. قبل كده التوكنز كانت
    // بتتحفظ والمستخدم يشوف خطأ مع إنه فعلياً بقى داخل
    T? parsed;
    if (fromJson != null) {
      try {
        parsed = fromJson(right);
      } catch (e, stackTrace) {
        return Left(_parsingFailure(e, stackTrace));
      }
    }

    await CacheManager.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
    );

    // بنمسح بيانات أي حساب قديم الأول، عشان لو الريسبونس ناقص حاجة
    // (زي userId) مايفضلش مكانها قيمة الحساب اللي قبله
    await CacheManager.clearUserData();

    // بيانات المستخدم بترجع مع التوكنز في اللوجين وتفعيل الرقم،
    // فبنحفظها هنا عشان الشاشات تقراها من غير ريكوست زيادة
    final userName = payload['userName']?.toString();
    if (userName != null) {
      await CacheManager.saveUserData(
        userId: payload['userId']?.toString() ?? '',
        userName: userName,
        role: payload['role']?.toString() ?? '',
        email: payload['email']?.toString(),
      );
    }
    await CrashReporter.setUser(payload['userId']?.toString());

    Session.started();

    return Right(parsed as T);
  }

  Future<Either<Failure, List<T>>> fetchData<T>({
    required String endpoint,
    PaginationParams? paginationParams,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final result = await _apiConsumer.get(
      endpoint,
      queryParameters: {
        ...?paginationParams?.toJson(),
        ...?queryParameters,
      }..removeWhere((key, value) => value == null || value == ''),
      headers: headers,
      data: data,
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          // If result is a map that contains a 'data' list
          if (right['data'] is Map && right['data']['data'] is List) {
            final items = (right['data']['data'] as List)
                .map((e) => fromJson(e))
                .toList();
            return Right(items);
          }

          // If result is a list directly
          if (right['data'] is List) {
            final items =
                (right['data'] as List).map((e) => fromJson(e)).toList();
            return Right(items);
          }

          // no matching collection found
          return const Right([]);
        } catch (e, stackTrace) {
          // كانت بترجع لستة فاضية، فالشاشة تقول "مفيش بيانات" والحقيقة
          // إن الموديل مش بيفك الريسبونس
          return Left(_parsingFailure(e, stackTrace));
        }
      },
    );
  }

  Future<Either<Failure, T>> fetchResult<T>({
    required String endpoint,
    PaginationParams? params,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final result = await _apiConsumer.get(endpoint,
        data: data,
        queryParameters: {
          ...?params?.toJson(),
          ...?queryParameters,
        },
        headers: headers);
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          if (T == Null) {
            return Right(null as T);
          }
          if (T == String) {
            logger('right: ${right["data"]}');
            return Right(right["data"] as T);
          }

          // If no `fromJson` parser was provided, assume caller expects no payload
          // (e.g. `Either<Failure, void>`). Return a successful empty value.
          if (fromJson == null) {
            return Right(null as T);
          }

          // If a `fromJson` is provided, try to pass the nested payload where possible.
          // Many APIs wrap the payload inside a top-level `data` object.
          final dynamic payload = right.containsKey('data')
              ? right['data']
              : right;

          if (payload is Map<String, dynamic>) {
            return Right(fromJson(payload));
          }

          return Right(fromJson(right));
        } catch (e, stackTrace) {
          return Left(_parsingFailure(e, stackTrace));
        }
      },
    );
  }

  Future<Either<Failure, T>> postData<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final result = await _apiConsumer.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        logger('GenericDataSource.postData raw right: $right');
        try {
          // بنبعت الريسبونس كامل عشان الموديل يوصل للرسالة اللي في الروت
          // وللداتا اللي جوه data، وهو اللي بيفك الشكل حسب الاند بوينت
          if (fromJson != null) {
            return Right(fromJson(right));
          }
          if (T == Null) {
            return Right(right as T);
          } else if (T == String) {
            logger('right: $right');
            return Right(right['result'] ?? "" as T);
          } else if (T == int) {
            return Right(right['result'] ?? 0 as T);
          } else {
            return Right(right as T);
          }
        } catch (e, stackTrace) {
          return Left(_parsingFailure(e, stackTrace));
        }
      },
    );
  }

  Future<Either<Failure, T>> postFormData<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    // Process the data to handle lists properly
    final Map<String, dynamic> processedData;
    try {
      processedData = await _processFormData(data ?? {});
    } on FileSystemException catch (e) {
      return Left(_missingFile(e));
    }

    final result = await _apiConsumer.uploadFile(
      endpoint,
      formData: processedData,
      queryParameters: queryParameters,
      // الفيديو على نت الموبايل بياخد وقت أطول من مهلة الطلبات العادية،
      // والسيرفر بيحفظه قبل ما يرد
      options: Options(
        headers: headers,
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          // زي postData، الموديل بياخد الريسبونس كامل ويفكه بنفسه
          if (fromJson != null) {
            return Right(fromJson(right));
          }
          if (T == Null) {
            return Right(null as T);
          } else if (T == int) {
            return Right((right['id'] ?? 0) as T);
          } else if (T == String) {
            logger('right: $right');
            return Right((right['redirect_url'] ?? "") as T);
          } else {
            return Right(null as T);
          }
        } catch (e, stackTrace) {
          return Left(_parsingFailure(e, stackTrace));
        }
      },
    );
  }

  /// زي [postFormData] بس PUT، للتعديلات اللي بتبعت ملف زي صورة البروفايل
  Future<Either<Failure, T>> putFormData<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final Map<String, dynamic> processedData;
    try {
      processedData = await _processFormData(data ?? {});
    } on FileSystemException catch (e) {
      return Left(_missingFile(e));
    }

    final result = await _apiConsumer.put(
      endpoint,
      data: FormData.fromMap(processedData),
      queryParameters: queryParameters,
      headers: headers,
    );

    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          // الموديل بياخد الريسبونس كامل ويفكه بنفسه
          if (fromJson != null) {
            return Right(fromJson(right));
          }
          return Right(null as T);
        } catch (e, stackTrace) {
          return Left(_parsingFailure(e, stackTrace));
        }
      },
    );
  }

  /// الموديل ماعرفش يفك الريسبونس: التفاصيل للّوج و Crashlytics، والمستخدم
  /// بيشوف رسالة مفهومة بدل نص الـ exception
  Failure _parsingFailure(Object error, StackTrace stackTrace) {
    loggerError(stackTrace);
    loggerWarn(error.toString());
    CrashReporter.recordError(error, stackTrace, reason: 'response parsing');
    return ParsingFailure(message: 'common.somethingWentWrong'.tr());
  }

  /// ملف اتختار واتمسح قبل الرفع (زي فيديو اتشال من المعرض)
  Failure _missingFile(FileSystemException error) {
    loggerWarn('Attachment missing: ${error.path}');
    return CacheFailure(message: 'errors.fileNotFound'.tr());
  }

  Future<Map<String, dynamic>> _processFormData(
      Map<String, dynamic> data) async {
    final processed = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is File) {
        // Handle File objects by converting to MultipartFile
        final file = value;
        final fileName = file.path.split('/').last;
        // الملف الناقص كان بيتشال والطلب يكمل من غيره (زي فيديو الزيت)
        if (!await file.exists()) {
          throw PathNotFoundException(file.path, const OSError());
        }
        processed[key] = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        );
      } else if (value is List) {
        // Handle lists
        processed.remove(key);
        for (int i = 0; i < value.length; i++) {
          if (value[i] is File) {
            // Handle File in list
            final file = value[i] as File;
            final fileName = file.path.split('/').last;
            if (!await file.exists()) {
              throw PathNotFoundException(file.path, const OSError());
            }
            processed['$key[$i]'] = await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            );
          } else {
            processed['$key[$i]'] = value[i];
          }
        }
      } else if (value is Map) {
        // Recursively process maps
        try {
          final stringMap = Map<String, dynamic>.from(value);
          processed[key] = await _processFormData(stringMap);
        } catch (e) {
          final convertedMap = <String, dynamic>{};
          value.forEach((k, v) => convertedMap[k.toString()] = v);
          processed[key] = await _processFormData(convertedMap);
        }
      } else {
        processed[key] = value;
      }
    }

    return processed;
  }

  Future<Either<Failure, T>> deleteData<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final result = await _apiConsumer.delete(
      endpoint,
      queryParameters: queryParameters,
      headers: headers,
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          if (T == Null) {
            return Right(null as T);
          } else if (T == int) {
            return Right(right['id'] ?? 0 as T);
          } else if (T == String) {
            logger('right: $right');
            return Right(right['redirect_url'] ?? "" as T);
          } else {
            return Right(null as T);
          }
        } catch (e, stackTrace) {
          return Left(_parsingFailure(e, stackTrace));
        }
      },
    );
  }

  Future<Either<Failure, T>> patchData<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final result = await _apiConsumer.patch(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          if (T == Null) {
            return Right(null as T);
          } else if (T == int) {
            return Right(right['id'] ?? 0 as T);
          } else if (T == String) {
            logger('right: $right');
            return Right(right['redirect_url'] ?? "" as T);
          } else {
            return Right(null as T);
          }
        } catch (e, stackTrace) {
          return Left(_parsingFailure(e, stackTrace));
        }
      },
    );
  }

  Future<Either<Failure, T>> updateData<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final result = await _apiConsumer.put(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          if (T == Null) {
            return Right(null as T);
          } else if (T == int) {
            return Right(right['id'] ?? 0 as T);
          } else if (T == String) {
            logger('right: $right');
            return Right(right['redirect_url'] ?? "" as T);
          } else {
            return Right(null as T);
          }
        } catch (e, stackTrace) {
          return Left(_parsingFailure(e, stackTrace));
        }
      },
    );
  }

  Future<Either<Failure, T>> head<T>(
      {required String endpoint,
      required int id,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? queryParameters}) async {
    final result = await _apiConsumer.head(
      endpoint,
      queryParameters: queryParameters,
      headers: headers,
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          if (T == Null) {
            return Right(null as T);
          } else if (T == String) {
            logger('right: $right');
            return Right(right['redirect_url'] ?? "" as T);
          } else {
            return Right(null as T);
          }
        } catch (e, stackTrace) {
          return Left(_parsingFailure(e, stackTrace));
        }
      },
    );
  }
}
