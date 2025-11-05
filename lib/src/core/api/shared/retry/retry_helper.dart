// lib/core/api/retry/retry_helper.dart

import '../exception/api_exceptions.dart';

/// RetryHelper
/// 1. Handles automatic retry with content-type switching.
/// 2. Decides if a retry is needed based on ApiException.
/// 3. Works with any Future API call passed in as a closure.
class RetryHelper {
  /// Executes the given [apiCall] and retries with opposite content-type if needed.
  static Future<dynamic> withRetry(
    Future<dynamic> Function(bool isMultipart) apiCall, {
    required String endpoint,
    String? requestId,
    String? caller,
    bool initialMultipart = false, // ✅ NEW PARAM
  }) async {
    bool firstAttemptMultipart =
        initialMultipart; // ✅ START RESPECTING forceFormData

    try {
      // First attempt
      return await apiCall(firstAttemptMultipart);
    } on ApiException catch (e) {
      // Check retry condition
      if (_shouldRetryWithOppositeType(e)) {
        bool retryMultipart = _shouldUseFormData(e);
        return await apiCall(retryMultipart);
      }
      rethrow;
    }
  }

  /// Condition to retry with opposite type
  static bool _shouldRetryWithOppositeType(ApiException e) {
    return e.code == 'HTML_RESPONSE' ||
        e.statusCode == 415 ||
        (e.statusCode == 400 &&
            e.message.toLowerCase().contains('content type'));
  }

  /// When to use multipart after error
  static bool _shouldUseFormData(ApiException e) {
    return e.message.toLowerCase().contains('multipart') ||
        e.message.toLowerCase().contains('form-data');
  }
}
