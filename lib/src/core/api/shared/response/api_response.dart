import 'dart:convert';

class ApiResponse {
  /// Processes the API response with comprehensive empty handling
  static dynamic processResponse({
    required dynamic response,
    bool allowEmpty = false,
    dynamic defaultValue,
    String emptyMessage = 'No data available',
  }) {
    // 1. Check if response is completely empty (null, empty string, empty collection)
    if (_isResponseEmpty(response)) {
      if (allowEmpty) {
        return defaultValue ?? _defaultEmptyResponse(emptyMessage);
      }
      throw ApiEmptyResponseException(emptyMessage);
    }

    // 2. Parse the response
    try {
      return _parseResponse(response);
    } catch (e) {
      throw ApiParseException('Failed to parse API response: $e');
    }
  }

  /// Checks all possible empty response scenarios
  static bool _isResponseEmpty(dynamic data) {
    // Null response
    if (data == null) return true;

    // Empty string (including whitespace-only)
    if (data is String && data.trim().isEmpty) return true;

    // Empty collections
    if (data is Map && data.isEmpty) return true;
    if (data is List && data.isEmpty) return true;

    // Special case: empty JSON object/array strings
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed == '{}' || trimmed == '[]') return true;
    }

    return false;
  }

  /// Parses the response data with proper error handling
  static dynamic _parseResponse(dynamic data) {
    // Already parsed JSON
    if (data is Map || data is List) return data;

    // String that needs parsing
    if (data is String) {
      return json.decode(data);
    }

    // Unsupported type
    throw FormatException('Unsupported response type: ${data.runtimeType}');
  }

  /// Creates a default empty response structure
  static Map<String, dynamic> _defaultEmptyResponse(String message) {
    return {
      'status': 'success',
      'message': message,
      'data': null,
      'isEmpty': true,
    };
  }
}

/// Custom exception for empty API responses
class ApiEmptyResponseException implements Exception {
  final String message;
  ApiEmptyResponseException(this.message);

  @override
  String toString() => 'ApiEmptyResponseException: $message';
}

/// Custom exception for API parsing errors
class ApiParseException implements Exception {
  final String message;
  ApiParseException(this.message);

  @override
  String toString() => 'ApiParseException: $message';
}
