//TODO: HTTP
//   import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// import 'package:medycart/core/api/response/status_code/api_status_codes.dart';
//
// import '../exception/api_exceptions.dart';
// rt '../logging/api_logging.dart';
//
//   class ApiResponse {
//     /// Handles http package responses
//     static dynamic handleHttpResponse(
//       http.Response response, {
//       Duration? requestDuration,
//     }) {
//       final statusCode = response.statusCode;
//       final statusMessage = ApiStatusCodes.getMessage(statusCode);
//       final duration = requestDuration ?? Duration.zero;
//
//       ApiLogger.logCall(
//         method: 'HTTP',
//         url: response.request?.url.toString() ?? '',
//         statusCode: statusCode,
//         responseBody: response.body,
//         duration: duration,
//       );
//
//       switch (statusCode) {
//         case 200:
//         case 201:
//         case 202:
//         case 206:
//           return response.body.isNotEmpty ? json.decode(response.body) : null;
//         case 204:
//         case 205:
//           return null;
//         default:
//           if (response.body.isNotEmpty) {
//             try {
//               final data = json.decode(response.body);
//               if (data is Map) {
//                 // Convert to Map<String, dynamic> if needed
//                 final responseData = data is Map<String, dynamic>
//                     ? data
//                     : Map<String, dynamic>.from(data);
//
