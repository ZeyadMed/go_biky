import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/helpers/logger.dart';
import 'package:go_biky/core/http/endpoints.dart';
import 'package:go_biky/core/http/session.dart';
import 'package:go_biky/core/router/app_keys.dart';

import 'either.dart';
import 'failure.dart';

abstract final class ApiConsumer {
  Future<Either<Failure, Map<String, dynamic>>> get(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> postFormData(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> patch(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> put(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool formData = false,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> delete(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, String>> downloadFile({
    required String url,
    required String savePath,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, Map<String, dynamic>>> head(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, Map<String, dynamic>>> uploadFile(
    String url, {
    required Map<String, dynamic> formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  void addInterceptor(Interceptor interceptor);

  void removeAllInterceptors();

  void updateHeader(Map<String, dynamic> headers);

  Future<Either<Failure, Map<String, dynamic>>> retryApiCall(
    Future<Either<Failure, Map<String, dynamic>>> Function() apiCall, {
    int retryCount = 0,
  });
}

final class BaseApiConsumer implements ApiConsumer {
  final Dio _dio;
  final int maxRetries;
  final Duration retryDelay;

  /// قبل كده القيم دي كانت بتتجاهل، والـ retry ماكانش بيشتغل أصلاً
  BaseApiConsumer({
    required this._dio,
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 2),
  });

  /// بيعيد المحاولة للأخطاء المؤقتة بس ([_isTransient]). أي خطأ تاني
  /// (401، validation، 404...) هيرجع نفس النتيجة لو اتعاد
  @override
  Future<Either<Failure, Map<String, dynamic>>> retryApiCall(
    Future<Either<Failure, Map<String, dynamic>>> Function() apiCall, {
    int retryCount = 0,
  }) async {
    final result = await apiCall();
    return result.fold((failure) async {
      final transient =
          failure is NetworkFailure ||
          failure is RequestTimeOutFailure ||
          _retryableStatusCodes.contains(failure.statusCode);
      if (transient && retryCount < maxRetries) {
        log("API failed, retrying attempt #${retryCount + 1}");
        await Future.delayed(retryDelay);
        return retryApiCall(apiCall, retryCount: retryCount + 1); //recursion
      }
      return Left(failure);
    }, (success) => Right(success));
  }

  /// أخطاء السيرفر اللي غالباً مؤقتة (gateway / مش متاح). الـ 500 غالباً
  /// bug فإعادته مش هتفرق
  static const _retryableStatusCodes = {502, 503, 504};

  /// النت وقع أو السيرفر ماردش على الاتصال أو رجّع gateway error. الـ
  /// receiveTimeout مش منهم، لأن السيرفر استلم الطلب وبطيء فالإعادة هتطوّل
  bool _isTransient(DioException e) => switch (e.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout => true,
    DioExceptionType.badResponse => _retryableStatusCodes.contains(
      e.response?.statusCode,
    ),
    _ => false,
  };

  /// الـ GET بس اللي بيتعاد لأنه مابيغيرش حاجة عند الباك. الإعادة قبل ما
  /// الخطأ يتحول لـ Failure، فرسالة الخطأ بتظهر مرة واحدة بعد آخر محاولة
  @override
  Future<Either<Failure, Map<String, dynamic>>> get(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    for (var attempt = 0; ; attempt++) {
      try {
        final response = await _dio.get(
          url,
          queryParameters: queryParameters,
          options: Options(headers: headers),
          cancelToken: cancelToken,
          data: data,
          onReceiveProgress: onReceiveProgress,
        );
        return Right(_asMap(response.data));
      } on DioException catch (e) {
        if (attempt < maxRetries && _isTransient(e)) {
          log('GET $url failed, retrying attempt #${attempt + 1}');
          await Future.delayed(retryDelay);
          if (!(cancelToken?.isCancelled ?? false)) continue;
        }
        loggerError(e.toString());
        return Left(await _handleDioError(e));
      } catch (e) {
        return Left(UnknownFailure(message: _unexpected(e)));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> head(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.head(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return Right(_asMap(response.data));
    } on DioException catch (e) {
      loggerError(e.toString());
      final failure = await _handleDioError(e);
      return Left<Failure, Map<String, dynamic>>(failure);
    } catch (e) {
      return Left<Failure, Map<String, dynamic>>(
        UnknownFailure(message: _unexpected(e)),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> patch(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.patch(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        data: data,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return Right(_asMap(response.data));
    } on DioException catch (e) {
      loggerError(e.toString());
      final failure = await _handleDioError(e);
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(message: _unexpected(e)),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.post(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        data: data,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      log('right');
      return Right(_asMap(response.data));
    } on DioException catch (e) {
      log('left $e');
      loggerError(e.toString());
      final failure = await _handleDioError(e);
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(message: _unexpected(e)),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> put(
    String url, {
    Object? data,
    bool formData = false,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.put(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        data: data,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return Right(_asMap(response.data));
    } on DioException catch (e) {
      loggerError(e.toString());
      final failure = await _handleDioError(e);
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(message: _unexpected(e)),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> delete(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.delete(
        url,
        queryParameters: queryParameters,
        data: data,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return Right(_asMap(response.data));
    } on DioException catch (e) {
      loggerError(e.toString());
      final failure = await _handleDioError(e);
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(message: _unexpected(e)),
      );
    }
  }

  @override
  Future<Either<Failure, String>> downloadFile({
    required String url,
    required String savePath,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return Right(savePath); // Return the saved file path
    } on DioException catch (e) {
      loggerError(e.toString());
      return Left(await _handleDioError(e));
    } catch (e) {
      return Left(
        UnknownFailure(message: _unexpected(e)),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadFile(
    String url, {
    required Map<String, dynamic> formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.post(
        url,
        data: FormData.fromMap(formData),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return Right(_asMap(response.data));
    } on DioException catch (e) {
      loggerError(e.toString());
      return Left(await _handleDioError(e));
    } catch (e) {
      return Left(
        UnknownFailure(message: _unexpected(e)),
      );
    }
  }

  @override
  void removeAllInterceptors() {
    _dio.options.headers.clear();
  }

  @override
  void updateHeader(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  @override
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// الـ 401 بيتفحص قبل ما نفك الـ body، لأن الـ JwtBearer بتاع الباك
  /// بيرجع 401 بـ body فاضي، وقبل كده كان بيعدي من غير ما يحوّل للوجين
  Failure _handleUnauthorized(DioException error) {
    final statusCode = error.response?.statusCode;

    // الـ 401 الجاي من اللوجين أو التحقق معناه إن البيانات نفسها
    // غلط، مش إن الجلسة انتهت. فبنرجع رسالة الباك زي ما هي
    // بدل ما نمسح التوكنز ونرمي المستخدم على اللوجين.
    if (Endpoints.isPublicAuth(error.requestOptions.path)) {
      return UnauthorizedFailure(
        message:
            _backendMessage(error.response?.data) ?? 'errors.unauthorized'.tr(),
        statusCode: statusCode,
      );
    }

    // لو وصلنا هنا يبقى الانترسبتور جرّب يجدد بالـ refresh token وفشل،
    // يعني الجلسة انتهت فعلاً والتوكنز اتمسحت هناك. لو كذا ريكوست وقعوا
    // مع بعض، أول واحد بس هو اللي بيحوّل. ومن غير await عشان الطلب ده
    // يرجع على طول ومايستناش الخروج يخلص
    if (Session.claimExpiryRedirect()) {
      _showError('errors.sessionExpired'.tr());
      unawaited(Session.end(callBackend: false));
    }
    return UnauthorizedFailure(
      message: 'errors.sessionExpired'.tr(),
      statusCode: statusCode,
    );
  }

  /// الباك ممكن يرجّع body فاضي (204) أو List أو نص، والـ cast المباشر
  /// لـ Map كان بيحوّل الطلب الناجح لخطأ
  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List) return {'data': data};
    if (data is String && data.isNotEmpty) {
      try {
        return _asMap(json.decode(data));
      } on FormatException {
        return {'data': data};
      }
    }
    return {};
  }

  /// الـ context ممكن يبقى null لو الريكوست خلص والأبلكيشن مقفول أو بيتبني
  void _showError(String message) {
    navigatorKey.currentContext?.showErrorMessage(message);
  }

  /// الخطأ التقني بيتسجل في اللوج، والمستخدم بيشوف رسالة مفهومة
  String _unexpected(Object error) {
    loggerError(error.toString());
    return 'common.somethingWentWrong'.tr();
  }

  /// بيطلع رسالة الباك من الـ body لو موجودة، ومابيرميش لو الـ body فاضي
  String? _backendMessage(dynamic data) {
    try {
      final decoded = data is String
          ? (data.isEmpty ? null : json.decode(data))
          : data;
      if (decoded is! Map) return null;
      return decoded['details']?.toString() ?? decoded['message']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<Failure> _handleDioError(DioException error) async {
    switch (error.type) {
      // الإلغاء بيبقى مقصود (الشاشة اتقفلت مثلاً)، فمفيش رسالة للمستخدم
      case DioExceptionType.cancel:
        return ServerFailure(message: 'errors.requestCancelled'.tr());
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.sendTimeout:
        final message = 'errors.timeout'.tr();
        _showError(message);
        return RequestTimeOutFailure(message: message);
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return _handleUnauthorized(error);
        }
        if (error.response?.data != null) {
          try {
            final data = error.response!.data;
            final Map<String, dynamic> decoded = data is String
                ? json.decode(data)
                : data;
            if (error.response?.statusCode == 503) {
              return ServerFailure(message: 'common.somethingWentWrong'.tr());
            }
            if (error.response?.statusCode == 413) {
              final message = 'errors.fileTooLarge'.tr();
              _showError(message);
              return ServerFailure(
                message: message,
                statusCode: error.response?.statusCode,
              );
            }
            if (error.response?.statusCode == 404) {
              // رسالة الباك أوضح من "404" لوحدها، زي "الطلب غير موجود"
              final message =
                  _backendMessage(decoded) ?? 'common.somethingWentWrong'.tr();
              _showError(message);
              return ServerFailure(
                message: message,
                statusCode: error.response?.statusCode,
              );
            }
            if (error.response?.statusCode == 407) {
              loggerWarn('APP IS OPENED IN ANOTHER DEVICE');
              return SyncAppFailure(
                message: 'errors.openedOnAnotherDevice'.tr(),
                statusCode: error.response?.statusCode,
              );
            }
            if (error.response?.statusCode == 402) {
              return PaymentFailure(
                message: _backendMessage(decoded) ?? error.message ?? "",
                statusCode: error.response?.statusCode,
              );
            }
            // الـ 409 مش OTP بس، بيرجع كمان في تعارض حالة الطلب
            // (زي الرد على تعديل اترد عليه قبل كده أو كود تسليم غلط)
            // فرسالة الباك الأول، ورسالة الـ OTP لو الباك مابعتش حاجة
            if (error.response?.statusCode == 409) {
              loggerWarn('VERIFYERROR');
              return VerifyOTPFailure(
                message:
                    _backendMessage(decoded) ?? 'errors.verificationFailed'.tr(),
                statusCode: error.response?.statusCode,
                data: decoded['data'] is Map<String, dynamic>
                    ? decoded['data'] as Map<String, dynamic>
                    : null,
              );
            }
            if (decoded.containsKey('message')) {
              String message = decoded['message'];
              // Process validation errors if present
              // 🧠 Handle validation errors
              if (decoded.containsKey('result') && decoded['result'] is Map) {
                final errors = decoded['result'] as Map<String, dynamic>;
                List<String> messages = [];

                // رسالة الباك لوحدها من غير اسم الحقل (زي "PhoneNumber: ...")
                errors.forEach((key, value) {
                  if (value is List) {
                    messages.addAll(value.map((e) => '$e'));
                  } else if (value is String) {
                    messages.add(value);
                  }
                });

                // final message = decoded['message'] ?? 'حدث خطأ ما';

                // Show first message to user
                if (messages.isNotEmpty) {
                  _showError(messages.first);
                }
                return ValidationFailure(
                  message: messages.isNotEmpty ? messages.first : message,
                  errors: messages,
                  statusCode: error.response?.statusCode,
                );
              }

              // navigatorKey.currentContext!.showErrorMessage(message);
              return ServerFailure(
                message: message,
                statusCode: error.response?.statusCode,
              );
            }
          } catch (e) {
            // navigatorKey.currentContext!.showErrorMessage(e.toString());
            return ServerFailure(
              message:
                  'common.somethingWentWrong'.tr(),
              statusCode: error.response?.statusCode,
            );
          }
        }
        // navigatorKey.currentContext!.showErrorMessage(error.message!);
        return ServerFailure(
          message:
              'common.somethingWentWrong'.tr(),
        );
      case DioExceptionType.badCertificate:
        return ServerFailure(message: 'errors.connectionFailed'.tr());
      case DioExceptionType.connectionError:
        final message = 'errors.connectionFailed'.tr();
        _showError(message);
        return NetworkFailure(message: message);
      case DioExceptionType.unknown:
        return UnknownFailure(message: _unexpected(error));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> postFormData(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.post(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      log('right');
      return Right(_asMap(response.data));
    } on DioException catch (e) {
      log('left $e');
      loggerError(e.toString());
      final failure = await _handleDioError(e);
      return Left(failure);
    } catch (e) {
      return Left(
        UnknownFailure(message: _unexpected(e)),
      );
    }
  }
}
