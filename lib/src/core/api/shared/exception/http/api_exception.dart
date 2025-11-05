//TODO: HTTP
// /// Unified exception class for all API and application errors
// class ApiException implements Exception {
//   final String message;
//   final String code;
//   final int statusCode;
//   final dynamic data;
//
//   ApiException({
//     required this.message,
//     required this.code,
//     required this.statusCode,
//     this.data,
//   });
//
//   factory ApiException.fromResponse(dynamic response) {
//     try {
//       // Handle both Map<String, dynamic> and Map<dynamic, dynamic>
//       final responseMap = response is Map
//           ? response.cast<String, dynamic>()
//           : <String, dynamic>{};
//
//       return ApiException(
//         message: responseMap['message']?.toString() ?? 'Unknown API error',
//         code: responseMap['code']?.toString() ?? 'UNKNOWN',
//         statusCode: responseMap['statusCode'] as int? ?? 500,
//         data: response,
//       );
//     } catch (e) {
//       return ApiException(
//         message: 'Failed to parse error response',
//         code: 'PARSE_ERROR',
//         statusCode: 500,
//         data: response,
//       );
//     }
//   }
//
//   factory ApiException.fromStatusCode(int statusCode, String statusMessage) {
//     return ApiException(
//       message: statusMessage.contains(':')
//           ? statusMessage.split(':').last.trim()
//           : statusMessage,
//       code: 'HTTP_$statusCode',
//       statusCode: statusCode,
//     );
//   }
//
//   @override
//   String toString() => '$code: $message (Status: $statusCode)';
// }
