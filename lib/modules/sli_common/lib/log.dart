import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Log {
  static void t(
      {dynamic message = '',
      int methodCount = 2,
      int errorMethodCount = 12,
      int lineLength = 120,
      dynamic error}) {
    bool isShow = kDebugMode;
    if (isShow) {
      Logger logger = Logger(
        printer: PrettyPrinter(
          methodCount: methodCount,
          // number of method calls to be displayed
          errorMethodCount: errorMethodCount,
          // number of method calls if stacktrace is provided
          lineLength: lineLength,
          // width of the output
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );
      logger.t(message, error: error);
    }
  }

  static void d(
      {dynamic message = '',
      int methodCount = 2,
      int errorMethodCount = 12,
      int lineLength = 120,
      dynamic error}) {
    bool isShow = kDebugMode;
    if (isShow) {
      Logger logger = Logger(
        printer: PrettyPrinter(
          methodCount: methodCount,
          // number of method calls to be displayed
          errorMethodCount: errorMethodCount,
          // number of method calls if stacktrace is provided
          lineLength: lineLength,
          // width of the output
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );
      logger.d(message, error: error);
    }
  }

  static void i(
      {dynamic message = '',
      int methodCount = 2,
      int errorMethodCount = 12,
      int lineLength = 120,
      dynamic error}) {
    bool isShow = kDebugMode;
    if (isShow) {
      Logger logger = Logger(
        printer: PrettyPrinter(
          methodCount: methodCount,
          // number of method calls to be displayed
          errorMethodCount: errorMethodCount,
          // number of method calls if stacktrace is provided
          lineLength: lineLength,
          // width of the output
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );
      logger.i(message,error: error);
    }
  }

  static void w(
      {dynamic message = '',
      int methodCount = 2,
      int errorMethodCount = 12,
      int lineLength = 120,
      dynamic error}) {
    bool isShow = kDebugMode;
    if (isShow) {
      Logger logger = Logger(
        printer: PrettyPrinter(
          methodCount: methodCount,
          // number of method calls to be displayed
          errorMethodCount: errorMethodCount,
          // number of method calls if stacktrace is provided
          lineLength: lineLength,
          // width of the output
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );
      logger.w(message, error: error);
    }
  }

  static void e(
      {dynamic message = '',
      int methodCount = 2,
      int errorMethodCount = 12,
      int lineLength = 120,
      dynamic error}) {
    bool isShow = kDebugMode;
    if (isShow) {
      Logger logger = Logger(
        printer: PrettyPrinter(
          methodCount: methodCount,
          // number of method calls to be displayed
          errorMethodCount: errorMethodCount,
          // number of method calls if stacktrace is provided
          lineLength: lineLength,
          // width of the output
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );
      logger.e(message, error: error);
    }
  }

  static void f(
      {dynamic message = '',
      int methodCount = 2,
      int errorMethodCount = 12,
      int lineLength = 120,
      dynamic error}) {
    bool isShow = kDebugMode;
    if (isShow) {
      Logger logger = Logger(
        printer: PrettyPrinter(
          methodCount: methodCount,
          // number of method calls to be displayed
          errorMethodCount: errorMethodCount,
          // number of method calls if stacktrace is provided
          lineLength: lineLength,
          // width of the output
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );
      logger.f(message, error: error);
    }
  }
}
