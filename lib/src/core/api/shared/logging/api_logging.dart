import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class ApiLogger {
  // 1. ANSI color codes for console output
  static const _blue = '\x1B[34m'; // GET requests
  static const _green = '\x1B[32m'; // POST requests and success
  static const _red = '\x1B[31m'; // Errors
  static const _yellow = '\x1B[33m'; // Warnings/retries
  static const _purple = '\x1B[35m'; // PUT requests
  static const _reset = '\x1B[0m'; // Reset color

  // 2. Core logging method that prints message with optional color
  static void _log(String message, {String color = ''}) {
    if (kDebugMode) {
      debugPrint('$color$message$_reset');
    }
  }

  // 3. Public method to print debug messages
  static void logDebug(String message, {String color = ''}) {
    _log('[DEBUG] $message', color: color);
  }

  // 4. Log HTTP request info: method, URL, data, queryParams, content type
  static void logRequest({
    required String method,
    required String url,
    dynamic data,
    bool isMultipart = false,
    bool isRetry = false,
    Map<String, dynamic>? queryParams,
  }) {
    // 4.1 Format current time for log
    final time = DateFormat('HH:mm:ss.SSS').format(DateTime.now());

    // 4.2 Choose prefix and color based on retry and HTTP method
    final prefix = isRetry ? 'RETRY ' : '';
    final color = _getMethodColor(method, isRetry: isRetry);

    // 4.3 Log request line with method, URL and timestamp
    _log('--> ${prefix}$method $url ($time)', color: color);

    // 4.4 Log content-type header
    _log(
        'Content-Type: ${isMultipart ? 'multipart/form-data' : 'application/json'}');

    // 4.5 Log query parameters if they exist
    if (queryParams != null) _log('Query: $queryParams');

    // 4.6 Log request body data if it exists
    if (data != null) _log('Body: $data');
  }

  // 5. Log HTTP response info: status code, method, URL, duration, body, size
  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    dynamic body,
    required Duration duration,
  }) {
    // 5.1 Choose color red for errors, green otherwise
    final color = statusCode >= 400 ? _red : _green;

    // 5.2 Convert duration to ms
    final time = duration.inMilliseconds;

    // 5.3 Log status line with duration
    _log('<-- $statusCode $method $url (${time}ms)', color: color);

    // 5.4 Log response body if present
    if (body != null) {
      _log('Response: $body');

      // 5.5 Log size in B or KB
      final size = body.toString().length;
      _log(
          'Size: ${size > 1024 ? '${(size / 1024).toStringAsFixed(2)}KB' : '${size}B'}');
    }
  }

  // 6. Log errors and optional stack trace
  static void logError({
    required String method,
    required String url,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    // 6.1 Log error header
    _log('<-- ERROR $method $url', color: _red);

    // 6.2 Log error message
    _log('Error: $error');

    // 6.3 Log stack trace if available
    if (stackTrace != null) {
      _log('Stack: $stackTrace');
    }
  }

  // 7. Helper to return ANSI color code based on HTTP method and retry flag
  static String _getMethodColor(String method, {bool isRetry = false}) {
    if (isRetry) return _yellow;
    switch (method) {
      case 'GET':
        return _blue;
      case 'POST':
        return _green;
      case 'PUT':
        return _purple;
      case 'DELETE':
        return _red;
      default:
        return _reset;
    }
  }
}
