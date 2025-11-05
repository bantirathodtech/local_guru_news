/// Network configurations
class ApiConstants {
  static const Duration timeout = Duration(seconds: 60);
  static const Duration uploadTimeout = Duration(seconds: 60);

  /// Default headers for JSON requests
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers for multipart requests (file uploads)
  /// Note: Dio will automatically set the boundary parameter
  static const Map<String, String> multipartHeaders = {
    'Content-Type': 'multipart/form-data',
    'Accept': 'application/json',
  };

  /// Get appropriate headers based on request type
  static Map<String, String> getHeaders({bool isMultipart = false}) {
    return isMultipart ? multipartHeaders : jsonHeaders;
  }

  /// Helper to get content type string directly
  static String getContentType(bool isMultipart) =>
      isMultipart ? 'multipart/form-data' : 'application/json';
}
