import 'dart:convert';

import 'package:dio/dio.dart';

import '../tracker/api_call_tracker.dart';
import 'api_logging.dart';

/// ApiLoggingHelper
/// 1. Centralizes request, response, and error logging.
/// 2. Works with ApiLogger for colored & formatted output.
/// 3. Integrates ApiCallTracker to count concurrent calls.
///
/// /// Centralized logging + tracking + raw data returning
class ApiLoggingHelper {
  static Future<dynamic> executeWithLogging({
    required Future<Response> Function() apiCall,
    required String method,
    required String endpoint,
    String? requestId,
    String? caller,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool isMultipart = false,
    bool isRetry = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    ApiCallTracker.increment(endpoint);

    _logRequest(
      method: method,
      endpoint: endpoint,
      requestId: requestId,
      caller: caller,
      data: data,
      queryParams: queryParams,
      headers: headers,
      isMultipart: isMultipart,
      isRetry: isRetry,
    );

    try {
      final response = await apiCall();

      _logResponse(
        method: method,
        endpoint: endpoint,
        requestId: requestId,
        caller: caller,
        response: response,
        duration: stopwatch.elapsed,
      );

      // ✅ Unified auto-parsing & type normalization for all APIs
      dynamic rawData = response.data;

      if (rawData is String) {
        rawData = rawData.trim();

        // Empty string → empty list (default safe type for list-based UIs)
        if (rawData.isEmpty) {
          return [];
        }

        // Try decoding JSON string safely
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {
          // If not JSON (plain text), return as message map
          rawData = {"message": rawData};
        }
      }

      // Null → default empty list (avoids null crashes in lists)
      if (rawData == null) {
        return [];
      }

      // List or Map are fine → just return
      if (rawData is List || rawData is Map) {
        return rawData;
      }

      // Anything else (number, bool, object) → wrap in map
      return {"data": rawData};
    } on DioException catch (e) {
      _logError(
        method: method,
        endpoint: endpoint,
        requestId: requestId,
        caller: caller,
        error: e,
        stackTrace: e.stackTrace,
      );
      rethrow;
    } finally {
      ApiCallTracker.decrement(endpoint);
      stopwatch.stop();
    }
  }

  // 1. Log API request event with optional requestId and caller info
  static void _logRequest({
    required String method,
    required String endpoint,
    String? requestId,
    String? caller,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool isMultipart = false,
    bool isRetry = false,
  }) {
    ApiLogger.logRequest(
      method: method,
      url: endpoint,
      data: data,
      isMultipart: isMultipart,
      isRetry: isRetry,
      queryParams: queryParams,
    );
    ApiLogger.logDebug("RequestID: $requestId, Caller: $caller");
  }

  // 2. Log API response event with requestId and caller info
  static void _logResponse({
    required String method,
    required String endpoint,
    String? requestId,
    String? caller,
    required Response response,
    required Duration duration,
  }) {
    ApiLogger.logResponse(
      method: method,
      url: endpoint,
      statusCode: response.statusCode ?? 200,
      body: response.data,
      duration: duration,
    );
    ApiLogger.logDebug("RequestID: $requestId, Caller: $caller");
  }

  // 3. Log API error event with requestId and caller info
  static void _logError({
    required String method,
    required String endpoint,
    String? requestId,
    String? caller,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    ApiLogger.logError(
      method: method,
      url: endpoint,
      error: error,
      stackTrace: stackTrace,
    );
    ApiLogger.logDebug("RequestID: $requestId, Caller: $caller");
  }
}
