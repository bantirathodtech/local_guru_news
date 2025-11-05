//TODO: DIO
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final String code;
  final int statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    required this.code,
    required this.statusCode,
    this.data,
  });

  /// Factory constructor for no internet connection errors
  factory ApiException.noConnection() {
    return ApiException(
      message: 'No internet connection',
      code: 'NO_CONNECTION',
      statusCode: 503,
    );
  }

  factory ApiException.fromResponse(dynamic response) {
    try {
      final responseMap = response is Map
          ? response.cast<String, dynamic>()
          : <String, dynamic>{};

      return ApiException(
        message: responseMap['message']?.toString() ?? 'Unknown API error',
        code: responseMap['code']?.toString() ?? 'UNKNOWN',
        statusCode: responseMap['statusCode'] as int? ?? 500,
        data: response,
      );
    } catch (e) {
      return ApiException(
        message: 'Failed to parse error response',
        code: 'PARSE_ERROR',
        statusCode: 500,
        data: response,
      );
    }
  }

  factory ApiException.fromDioError(DioException error) {
    final statusCode = error.response?.statusCode ?? 500;
    final responseData = error.response?.data;

    if (responseData is Map) {
      return ApiException.fromResponse(responseData);
    }

    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'Request timed out';
        break;
      case DioExceptionType.badResponse:
        message = 'Server responded with error';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      default:
        message = 'Network error occurred';
    }

    return ApiException(
      message: message,
      code: 'DIO_${error.type.name.toUpperCase()}',
      statusCode: statusCode,
      data: responseData,
    );
  }

  factory ApiException.fromStatusCode(int statusCode, String statusMessage) {
    return ApiException(
      message: statusMessage.contains(':')
          ? statusMessage.split(':').last.trim()
          : statusMessage,
      code: 'HTTP_$statusCode',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => '$code: $message (Status: $statusCode)';
}
