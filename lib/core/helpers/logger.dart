import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

void logger(Object? message) {
  if (kDebugMode) {
    Logger().d(message);
  }
}

void loggerError(Object? message) {
  if (kDebugMode) {
    Logger().e(message);
  }
}

void loggerWarn(Object? message) {
  if (kDebugMode) {
    Logger().w(message);
  }
}

void loggerVerbose(Object? message) {
  if (kDebugMode) {
    Logger().t(message);
  }
}

void loggerInfo(Object? message) {
  if (kDebugMode) {
    Logger().i(message);
  }
}

void loggerFatal(Object? message) {
  if (kDebugMode) {
    Logger().f(message);
  }
}