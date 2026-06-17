import 'package:flutter/foundation.dart';

/// Logger simple pour remplacer les print() en production
class Logger {
  static const bool _isDebugMode = kDebugMode;

  static void debug(String message) {
    if (_isDebugMode) {
      debugPrint('🐛 DEBUG: $message');
    }
  }

  static void info(String message) {
    if (_isDebugMode) {
      debugPrint('ℹ️ INFO: $message');
    }
  }

  static void warning(String message) {
    if (_isDebugMode) {
      debugPrint('⚠️ WARNING: $message');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_isDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  static void api(String method, String url, {Map<String, String>? headers}) {
    if (_isDebugMode) {
      debugPrint('🌐 API $method $url');
      if (headers != null) debugPrint('   Headers: $headers');
    }
  }

  static void apiResponse(int statusCode, String body) {
    if (_isDebugMode) {
      debugPrint('🌐 RESP $statusCode ${body.length} bytes');
    }
  }
}
