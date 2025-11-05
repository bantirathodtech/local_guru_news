//TODO: DIO
// import 'package:dio/dio.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:mime/mime.dart';
// import 'package:universal_io/io.dart';
//
// import '../constants/api_constants.dart';
// import '../endpoints/api_endpoints.dart';
// import '../exception/api_exceptions.dart';
// import '../logging/api_logging.dart';
// import '../network/network_utils.dart';
// import '../response/api_response.dart';
//
// class ApiService {
//   final Dio _dio;
//
//   ApiService()
//       : _dio = Dio(
//           BaseOptions(
//             baseUrl: ApiEndpoints.baseUrl,
//             connectTimeout: ApiConstants.timeout,
//             receiveTimeout: ApiConstants.timeout,
//             headers: ApiConstants.jsonHeaders,
//           ),
//         )..interceptors.add(
//             LogInterceptor(
//               requestBody: true,
//               responseBody: false, // Disabled as we handle logging ourselves
//             ),
//           );
//
//   // 1. GET Request
//   Future<dynamic> get(
//     String endpoint, {
//     Map<String, dynamic>? queryParams,
//     Map<String, String>? headers,
//   }) async {
//     // 1. Start timer and log request
//     final stopwatch = Stopwatch()..start();
//     ApiLogger.logRequest(
//       method: 'GET',
//       url: endpoint,
//       queryParams: queryParams,
//     );
//
//     try {
//       // 2. Check connectivity
//       if (!await NetworkUtils.isConnected) {
//         throw ApiException(
//           message: 'No internet connection',
//           code: 'NO_CONNECTION',
//           statusCode: 503,
//         );
//       }
//
//       // 3. Make API call
//       final response = await _dio.get(
//         endpoint,
//         queryParameters: queryParams,
//         options: Options(headers: headers),
//       );
//
//       // 4. Log successful response
//       ApiLogger.logResponse(
//         method: 'GET',
//         url: endpoint,
//         statusCode: response.statusCode ?? 200,
//         body: response.data,
//         duration: stopwatch.elapsed,
//       );
//
//       // 5. Process and return response
//       return ApiResponse.processBody(response.data);
//     } catch (e) {
//       // 6. Log error
//       ApiLogger.logError(
//         method: 'GET',
//         url: endpoint,
//         error: e,
//         stackTrace: e is DioException ? e.stackTrace : null,
//       );
//       throw _handleError(e);
//     } finally {
//       stopwatch.stop();
//     }
//   }
//
//   // 2. POST Request
//   Future<dynamic> post(
//     String endpoint,
//     dynamic body, {
//     Map<String, String>? headers,
//     bool isMultipart = false,
//   }) async {
//     final stopwatch = Stopwatch()..start();
//     ApiLogger.logRequest(
//       method: 'POST',
//       url: endpoint,
//       data: body,
//     );
//
//     try {
//       if (!await NetworkUtils.isConnected) {
//         throw ApiException(
//           message: 'No internet connection',
//           code: 'NO_CONNECTION',
//           statusCode: 503,
//         );
//       }
//
//       final response = await _dio.post(
//         endpoint,
//         data: isMultipart ? _createFormData(body) : body,
//         options: Options(
//           headers: {
//             ...(isMultipart
//                 ? ApiConstants.multipartHeaders
//                 : ApiConstants.jsonHeaders),
//             ...?headers,
//           },
//         ),
//       );
//
//       ApiLogger.logResponse(
//         method: 'POST',
//         url: endpoint,
//         statusCode: response.statusCode ?? 200,
//         body: response.data,
//         duration: stopwatch.elapsed,
//       );
//
//       return ApiResponse.processBody(response.data);
//     } catch (e) {
//       ApiLogger.logError(
//         method: 'POST',
//         url: endpoint,
//         error: e,
//         stackTrace: e is DioException ? e.stackTrace : null,
//       );
//       throw _handleError(e);
//     } finally {
//       stopwatch.stop();
//     }
//   }
//
//   // 3. PUT Request
//   Future<dynamic> put(
//     String endpoint,
//     dynamic body, {
//     Map<String, String>? headers,
//   }) async {
//     final stopwatch = Stopwatch()..start();
//     ApiLogger.logRequest(
//       method: 'PUT',
//       url: endpoint,
//       data: body,
//     );
//
//     try {
//       if (!await NetworkUtils.isConnected) {
//         throw ApiException(
//           message: 'No internet connection',
//           code: 'NO_CONNECTION',
//           statusCode: 503,
//         );
//       }
//
//       final response = await _dio.put(
//         endpoint,
//         data: body,
//         options: Options(headers: headers),
//       );
//
//       ApiLogger.logResponse(
//         method: 'PUT',
//         url: endpoint,
//         statusCode: response.statusCode ?? 200,
//         body: response.data,
//         duration: stopwatch.elapsed,
//       );
//
//       return ApiResponse.processBody(response.data);
//     } catch (e) {
//       ApiLogger.logError(
//         method: 'PUT',
//         url: endpoint,
//         error: e,
//         stackTrace: e is DioException ? e.stackTrace : null,
//       );
//       throw _handleError(e);
//     } finally {
//       stopwatch.stop();
//     }
//   }
//
//   // 4. DELETE Request
//   Future<dynamic> delete(
//     String endpoint, {
//     dynamic body,
//     Map<String, String>? headers,
//   }) async {
//     final stopwatch = Stopwatch()..start();
//     ApiLogger.logRequest(
//       method: 'DELETE',
//       url: endpoint,
//       data: body,
//     );
//
//     try {
//       if (!await NetworkUtils.isConnected) {
//         throw ApiException(
//           message: 'No internet connection',
//           code: 'NO_CONNECTION',
//           statusCode: 503,
//         );
//       }
//
//       final response = await _dio.delete(
//         endpoint,
//         data: body,
//         options: Options(headers: headers),
//       );
//
//       ApiLogger.logResponse(
//         method: 'DELETE',
//         url: endpoint,
//         statusCode: response.statusCode ?? 200,
//         body: response.data,
//         duration: stopwatch.elapsed,
//       );
//
//       return ApiResponse.processBody(response.data);
//     } catch (e) {
//       ApiLogger.logError(
//         method: 'DELETE',
//         url: endpoint,
//         error: e,
//         stackTrace: e is DioException ? e.stackTrace : null,
//       );
//       throw _handleError(e);
//     } finally {
//       stopwatch.stop();
//     }
//   }
//
//   // 5. File Upload
//   Future<dynamic> postWithFile(
//     String endpoint,
//     Map<String, dynamic> fields,
//     File file,
//     String fileFieldName, {
//     Map<String, String>? headers,
//   }) async {
//     final stopwatch = Stopwatch()..start();
//     ApiLogger.logRequest(
//       method: 'POST',
//       url: endpoint,
//       data: fields,
//     );
//
//     try {
//       if (!await NetworkUtils.isConnected) {
//         throw ApiException(
//           message: 'No internet connection',
//           code: 'NO_CONNECTION',
//           statusCode: 503,
//         );
//       }
//
//       final formData = FormData.fromMap({
//         ...fields,
//         fileFieldName: await MultipartFile.fromFile(
//           file.path,
//           contentType: MediaType.parse(
//             lookupMimeType(file.path) ?? 'application/octet-stream',
//           ),
//         ),
//       });
//
//       final response = await _dio.post(
//         endpoint,
//         data: formData,
//         options: Options(
//           headers: {
//             ...ApiConstants.multipartHeaders,
//             ...?headers,
//           },
//         ),
//       );
//
//       ApiLogger.logResponse(
//         method: 'POST',
//         url: endpoint,
//         statusCode: response.statusCode ?? 200,
//         body: response.data,
//         duration: stopwatch.elapsed,
//       );
//
//       return ApiResponse.processBody(response.data);
//     } catch (e) {
//       ApiLogger.logError(
//         method: 'POST',
//         url: endpoint,
//         error: e,
//         stackTrace: e is DioException ? e.stackTrace : null,
//       );
//       throw _handleError(e);
//     } finally {
//       stopwatch.stop();
//     }
//   }
//
//   // Helper Methods
//   FormData _createFormData(Map<String, dynamic> data) {
//     return FormData.fromMap(
//       data.map((key, value) {
//         if (value is File) {
//           return MapEntry(
//             key,
//             MultipartFile.fromFileSync(
//               value.path,
//               contentType: MediaType.parse(
//                 lookupMimeType(value.path) ?? 'application/octet-stream',
//               ),
//             ),
//           );
//         }
//         return MapEntry(key, value);
//       }),
//     );
//   }
//
//   dynamic _handleError(dynamic error) {
//     if (error is DioException) {
//       return ApiException.fromDioError(error);
//     }
//     return error;
//   }
// }
