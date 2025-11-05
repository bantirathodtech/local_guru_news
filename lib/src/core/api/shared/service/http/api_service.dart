// //TODO: HTTP
// import 'dart:async';
// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:mime/mime.dart';
// import 'package:universal_io/io.dart' as io;
//
// import '../constants/api_constants.dart';
// import '../exception/api_exceptions.dart';
// import '../logging/api_logging.dart';
// import '../network/network_utils.dart';
// import '../response/api_response.dart';
//
// class ApiService {
//   static const _timeout = Duration(seconds: 20);
//
//   Future<dynamic> get(
//     String endpoint, {
//     Map<String, String>? headers,
//     Map<String, String>? queryParams,
//   }) async {
//     try {
//       if (!await NetworkUtils.isConnected) {
//         throw ApiException(
//           message: 'No internet connection',
//           code: 'NO_CONNECTION',
//           statusCode: 503,
//         );
//       }
//
//       final url = Uri.parse(endpoint).replace(
//         queryParameters: queryParams,
//       );
//
//       ApiLogger.logCall(
//         method: 'GET',
//         url: url.toString(),
//       );
//
//       final response = await http.get(
//         url,
//         headers: {...ApiConstants.jsonHeaders, ...?headers},
//       ).timeout(ApiConstants.timeout);
//
//       return ApiResponse.handleHttpResponse(
//         response,
//         requestDuration: ApiConstants.timeout,
//       );
//     } on TimeoutException {
//       throw ApiException(
//         message: 'Request timed out',
//         code: 'TIMEOUT',
//         statusCode: 408,
//       );
//     } on io.SocketException {
//       throw ApiException(
//         message: 'No internet connection',
//         code: 'NO_CONNECTION',
//         statusCode: 503,
//       );
//     } catch (e) {
//       ApiLogger.logCall(
//         method: 'GET',
//         url: endpoint,
//         error: e,
//       );
//       rethrow;
//     }
//   }
//
//   Future<dynamic> post(
//     String endpoint,
//     Map<String, dynamic> body, {
//     Map<String, String>? headers,
//     bool isMultipart = false,
//   }) async {
//     try {
//       if (!await NetworkUtils.isConnected) {
//         throw ApiException(
//           message: 'No internet connection',
//           code: 'NO_CONNECTION',
//           statusCode: 503,
//         );
//       }
//
//       ApiLogger.logCall(
//         method: 'POST',
//         url: endpoint,
//         requestBody: body,
//       );
//
//       if (isMultipart) {
//         var request = http.MultipartRequest('POST', Uri.parse(endpoint))
//           ..fields.addAll(body.map((k, v) => MapEntry(k, v.toString())))
//           ..headers.addAll({...ApiConstants.multipartHeaders, ...?headers});
//
//         final response =
//             await request.send().timeout(ApiConstants.uploadTimeout);
//         final responseBody = await response.stream.bytesToString();
//
//         return ApiResponse.handleHttpResponse(
//           http.Response(responseBody, response.statusCode),
//           requestDuration: ApiConstants.uploadTimeout,
//         );
//       } else {
//         final response = await http
//             .post(
//               Uri.parse(endpoint),
//               headers: {...ApiConstants.jsonHeaders, ...?headers},
//               body: json.encode(body),
//             )
//             .timeout(ApiConstants.timeout);
//
//         return ApiResponse.handleHttpResponse(
//           response,
//           requestDuration: ApiConstants.timeout,
//         );
//       }
//     } on TimeoutException {
//       throw ApiException(
//         message: 'Request timed out',
//         code: 'TIMEOUT',
//         statusCode: 408,
//       );
//     } on io.SocketException {
//       throw ApiException(
//         message: 'No internet connection',
//         code: 'NO_CONNECTION',
//         statusCode: 503,
//       );
//     } catch (e) {
//       ApiLogger.logCall(
//         method: 'POST',
//         url: endpoint,
//         error: e,
//       );
//       rethrow;
//     }
//   }
//
//   Future<http.MultipartFile> _createMultipartFile(
//     io.File file,
//     String fieldName,
//   ) async {
//     final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
//     return await http.MultipartFile.fromPath(
//       fieldName,
