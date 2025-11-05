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

/*
 * PURE FORM-DATA API SERVICE IMPLEMENTATION
 *
 * Use this when working with APIs that exclusively require form-data
 * All requests will be sent as multipart/form-data
 *
 * To use:
 * 1. Uncomment this entire class
 * 2. Remove/comment out any other ApiService implementations
 * 3. Use forceFormData: true for all requests
 */

/*
class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: ApiConstants.timeout,
            receiveTimeout: ApiConstants.timeout,
            headers: ApiConstants.multipartHeaders, // Force form-data headers
          ),
        )..interceptors.add(
            LogInterceptor(
              requestBody: true,
              responseBody: false,
            ),
          );

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    final stopwatch = Stopwatch()..start();
    ApiLogger.logRequest(
      method: 'GET',
      url: endpoint,
      queryParams: queryParams,
      isMultipart: true,
    );

    try {
      if (!await NetworkUtils.isConnected) {
        throw ApiException(
          message: 'No internet connection',
          code: 'NO_CONNECTION',
          statusCode: 503,
        );
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      ApiLogger.logResponse(
        method: 'GET',
        url: endpoint,
        statusCode: response.statusCode ?? 200,
        body: response.data,
        duration: stopwatch.elapsed,
      );

      return ApiResponse.processBody(response.data);
    } catch (e) {
      ApiLogger.logError(
        method: 'GET',
        url: endpoint,
        error: e,
        stackTrace: e is DioException ? e.stackTrace : null,
      );
      throw _handleError(e);
    } finally {
      stopwatch.stop();
    }
  }

  Future<dynamic> post(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    final stopwatch = Stopwatch()..start();
    ApiLogger.logRequest(
      method: 'POST',
      url: endpoint,
      data: body,
      isMultipart: true,
    );

    try {
      if (!await NetworkUtils.isConnected) {
        throw ApiException(
          message: 'No internet connection',
          code: 'NO_CONNECTION',
          statusCode: 503,
        );
      }

      final formData = _createFormData(body);
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: headers),
      );

      ApiLogger.logResponse(
        method: 'POST',
        url: endpoint,
        statusCode: response.statusCode ?? 200,
        body: response.data,
        duration: stopwatch.elapsed,
      );

      return ApiResponse.processBody(response.data);
    } catch (e) {
      ApiLogger.logError(
        method: 'POST',
        url: endpoint,
        error: e,
        stackTrace: e is DioException ? e.stackTrace : null,
      );
      throw _handleError(e);
    } finally {
      stopwatch.stop();
    }
  }

  Future<dynamic> put(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    final stopwatch = Stopwatch()..start();
    ApiLogger.logRequest(
      method: 'PUT',
      url: endpoint,
      data: body,
      isMultipart: true,
    );

    try {
      if (!await NetworkUtils.isConnected) {
        throw ApiException(
          message: 'No internet connection',
          code: 'NO_CONNECTION',
          statusCode: 503,
        );
      }

      final formData = _createFormData(body);
      final response = await _dio.put(
        endpoint,
        data: formData,
        options: Options(headers: headers),
      );

      ApiLogger.logResponse(
        method: 'PUT',
        url: endpoint,
        statusCode: response.statusCode ?? 200,
        body: response.data,
        duration: stopwatch.elapsed,
      );

      return ApiResponse.processBody(response.data);
    } catch (e) {
      ApiLogger.logError(
        method: 'PUT',
        url: endpoint,
        error: e,
        stackTrace: e is DioException ? e.stackTrace : null,
      );
      throw _handleError(e);
    } finally {
      stopwatch.stop();
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final stopwatch = Stopwatch()..start();
    ApiLogger.logRequest(
      method: 'DELETE',
      url: endpoint,
      data: body,
      isMultipart: true,
    );

    try {
      if (!await NetworkUtils.isConnected) {
        throw ApiException(
          message: 'No internet connection',
          code: 'NO_CONNECTION',
          statusCode: 503,
        );
      }

      final formData = body != null ? _createFormData(body) : null;
      final response = await _dio.delete(
        endpoint,
        data: formData,
        options: Options(headers: headers),
      );

      ApiLogger.logResponse(
        method: 'DELETE',
        url: endpoint,
        statusCode: response.statusCode ?? 200,
        body: response.data,
        duration: stopwatch.elapsed,
      );

      return ApiResponse.processBody(response.data);
    } catch (e) {
      ApiLogger.logError(
        method: 'DELETE',
        url: endpoint,
        error: e,
        stackTrace: e is DioException ? e.stackTrace : null,
      );
      throw _handleError(e);
    } finally {
      stopwatch.stop();
    }
  }

  Future<dynamic> postWithFile(
    String endpoint,
    Map<String, dynamic> fields,
    File file,
    String fileFieldName, {
    Map<String, String>? headers,
  }) async {
    final stopwatch = Stopwatch()..start();
    ApiLogger.logRequest(
      method: 'POST',
      url: endpoint,
      data: fields,
      isMultipart: true,
    );

    try {
      if (!await NetworkUtils.isConnected) {
        throw ApiException(
          message: 'No internet connection',
          code: 'NO_CONNECTION',
          statusCode: 503,
        );
      }

      final formData = FormData.fromMap({
        ...fields,
        fileFieldName: await MultipartFile.fromFile(
          file.path,
          contentType: MediaType.parse(
            lookupMimeType(file.path) ?? 'application/octet-stream',
          ),
        ),
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: headers),
      );

      ApiLogger.logResponse(
        method: 'POST',
        url: endpoint,
        statusCode: response.statusCode ?? 200,
        body: response.data,
        duration: stopwatch.elapsed,
      );

      return ApiResponse.processBody(response.data);
    } catch (e) {
      ApiLogger.logError(
        method: 'POST',
        url: endpoint,
        error: e,
        stackTrace: e is DioException ? e.stackTrace : null,
      );
      throw _handleError(e);
    } finally {
      stopwatch.stop();
    }
  }

  FormData _createFormData(Map<String, dynamic> data) {
    return FormData.fromMap(
      data.map((key, value) {
        if (value is File) {
          return MapEntry(
            key,
            MultipartFile.fromFileSync(
              value.path,
              contentType: MediaType.parse(
                lookupMimeType(value.path) ?? 'application/octet-stream',
              ),
            ),
          );
        }
        return MapEntry(key, value.toString());
      }),
    );
  }

  dynamic _handleError(dynamic error) {
    if (error is DioException) {
      return ApiException.fromDioError(error);
    }
    return error;
  }
}
*/
