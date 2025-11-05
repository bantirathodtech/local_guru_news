// lib/core/api/service/api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:universal_io/io.dart';

import '../../custom/endpoints/api_endpoints.dart';
import '../config/api_service_config.dart';
import '../constants/api_constants.dart';
import '../exception/api_exceptions.dart';
import '../logging/api_logging_helper.dart';
import '../logging/request_id_generator.dart';
import '../network/network_utils.dart';
import '../retry/retry_helper.dart';

class ApiService {
  final Dio _dio;
  final ApiServiceConfig _config;

  ApiService({ApiServiceConfig config = const ApiServiceConfig()})
      : _config = config,
        _dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: ApiConstants.timeout,
            receiveTimeout: ApiConstants.timeout,
            // headers: ApiConstants.jsonHeaders,
            headers: {}, // ✅ Start with empty headers
          ),
        ) {
    if (kIsWeb) {
      // ignore: avoid_print
      print('[ApiService] CORS_PROXY_BASE = ' + (_config.corsProxyBase ?? '(null)'));
    }
  }

// ---------------------- PUBLIC METHODS ----------------------

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool? enableLogging,
    bool? enableRetry,
    bool? enableRequestId,
    bool? enableTracking,
    bool? forceFormData,
    String? caller,
  }) {
    return _execute(
      method: 'GET',
      endpoint: endpoint,
      queryParams: queryParams,
      headers: headers,
      enableLogging: enableLogging,
      enableRetry: enableRetry,
      enableRequestId: enableRequestId,
      enableTracking: enableTracking,
      forceFormData: forceFormData,
      caller: caller,
    );
  }

  Future<dynamic> post(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
    bool? enableLogging,
    bool? enableRetry,
    bool? enableRequestId,
    bool? enableTracking,
    bool? forceFormData,
    String? caller,
  }) {
    return _execute(
      method: 'POST',
      endpoint: endpoint,
      data: body,
      headers: headers,
      enableLogging: enableLogging,
      enableRetry: enableRetry,
      enableRequestId: enableRequestId,
      enableTracking: enableTracking,
      forceFormData: forceFormData,
      caller: caller,
    );
  }

  Future<dynamic> put(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
    bool? enableLogging,
    bool? enableRetry,
    bool? enableRequestId,
    bool? enableTracking,
    bool? forceFormData,
    String? caller,
  }) {
    return _execute(
      method: 'PUT',
      endpoint: endpoint,
      data: body,
      headers: headers,
      enableLogging: enableLogging,
      enableRetry: enableRetry,
      enableRequestId: enableRequestId,
      enableTracking: enableTracking,
      forceFormData: forceFormData,
      caller: caller,
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    bool? enableLogging,
    bool? enableRetry,
    bool? enableRequestId,
    bool? enableTracking,
    bool? forceFormData,
    String? caller,
  }) {
    return _execute(
      method: 'DELETE',
      endpoint: endpoint,
      data: body,
      headers: headers,
      enableLogging: enableLogging,
      enableRetry: enableRetry,
      enableRequestId: enableRequestId,
      enableTracking: enableTracking,
      forceFormData: forceFormData,
      caller: caller,
    );
  }

  Future<dynamic> postWithFile(
    String endpoint,
    Map<String, dynamic> fields,
    File file,
    String fileFieldName, {
    Map<String, String>? headers,
    bool? enableLogging,
    bool? enableRetry,
    bool? enableRequestId,
    bool? enableTracking,
    String? caller,
  }) async {
    final formData = FormData.fromMap({
      ...fields,
      fileFieldName: await MultipartFile.fromFile(
        file.path,
        contentType: MediaType.parse(
          lookupMimeType(file.path) ?? 'application/octet-stream',
        ),
      ),
    });

    return post(
      endpoint,
      formData,
      headers: {
        ...ApiConstants.multipartHeaders,
        ...?headers,
      },
      enableLogging: enableLogging,
      enableRetry: enableRetry,
      enableRequestId: enableRequestId,
      enableTracking: enableTracking,
      forceFormData: true,
      caller: caller,
    );
  }

// ---------------------- INTERNAL EXECUTION ----------------------

  // Future<dynamic> _execute({
  //   required String method,
  //   required String endpoint,
  //   dynamic data,
  //   Map<String, dynamic>? queryParams,
  //   Map<String, String>? headers,
  //   bool? enableLogging,
  //   bool? enableRetry,
  //   bool? enableRequestId,
  //   bool? enableTracking,
  //   bool? forceFormData, // ✅ from API call
  //   String? caller,
  // }) async {
  //   print('forceFormData value: $forceFormData');
  //
  //   final useLogging = enableLogging ?? _config.enableLogging;
  //   final useRetry = enableRetry ?? _config.enableRetry;
  //   final useRequestId = enableRequestId ?? _config.enableRequestId;
  //   final useTracking = enableTracking ?? _config.enableTracking;
  //
  //   String? requestId;
  //   if (useRequestId) {
  //     requestId = RequestIdGenerator.generate(endpoint);
  //   }
  //
  //   // Core function to make the request
  //   Future<dynamic> coreCall(bool multipart) async {
  //     if (!await NetworkUtils.isConnected) {
  //       throw ApiException.noConnection();
  //     }
  //
  //     final requestData = multipart ? _createFormData(data) : data;
  //
  //     final requestHeaders = {
  //       ...ApiConstants.getHeaders(isMultipart: multipart),
  //       ...?headers,
  //     };
  //
  //     print('Request Headers: $requestHeaders'); // ✅ Debug to confirm
  //
  //     return _dio.request(
  //       endpoint,
  //       data: requestData,
  //       queryParameters: queryParams,
  //       options: Options(
  //         method: method,
  //         headers: requestHeaders,
  //       ),
  //     );
  //   }
  //
  //   // ✅ FIX: Respect forceFormData even with retry enabled
  //   return useRetry
  //       ? RetryHelper.withRetry(
  //           (multipart) => coreCall(forceFormData ?? multipart),
  //           endpoint: endpoint,
  //           requestId: requestId,
  //           caller: caller,
  //           initialMultipart: forceFormData ?? false, // ✅ NEW PARAM
  //         )
  //       : coreCall(forceFormData ?? false);
  // }
  Future<dynamic> _execute({
    required String method,
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool? enableLogging,
    bool? enableRetry,
    bool? enableRequestId,
    bool? enableTracking,
    bool? forceFormData,
    String? caller,
  }) async {
    final useRetry = enableRetry ?? _config.enableRetry;
    final useRequestId = enableRequestId ?? _config.enableRequestId;

    String? requestId;
    if (useRequestId) {
      requestId = RequestIdGenerator.generate(endpoint);
    }

    Future<Response> coreCall(bool multipart) async {
      if (!await NetworkUtils.isConnected) {
        throw ApiException.noConnection();
      }

      final requestData = multipart ? _createFormData(data) : data;
      final requestHeaders = {
        ...ApiConstants.getHeaders(isMultipart: multipart),
        ...?headers,
      };

      final targetUrl = _maybeProxyUrlForWeb(endpoint);
      return _dio.request(
        targetUrl,
        data: requestData,
        queryParameters: queryParams,
        options: Options(method: method, headers: requestHeaders),
      );
    }

    // Wrap the retry helper with explicit cast to Response
    Future<Response> retryableCall(bool multipart) async {
      final result = await RetryHelper.withRetry(
        (m) => coreCall(forceFormData ?? m),
        endpoint: endpoint,
        requestId: requestId,
        caller: caller,
        initialMultipart: forceFormData ?? false,
      );
      return result as Response;
    }

    return ApiLoggingHelper.executeWithLogging(
      apiCall: () => useRetry
          ? retryableCall(forceFormData ?? false)
          : coreCall(forceFormData ?? false),
      method: method,
      endpoint: endpoint,
      requestId: requestId,
      caller: caller,
      data: data,
      queryParams: queryParams,
      headers: headers,
      isMultipart: forceFormData ?? false,
    );
  }

  // On Flutter Web, if a CORS proxy base is configured, rewrite the URL
  // to go through the proxy. Mobile/desktop are unaffected.
  String _maybeProxyUrlForWeb(String endpoint) {
    if (!kIsWeb) return endpoint;
    final proxy = _config.corsProxyBase;
    if (proxy == null || proxy.isEmpty) return endpoint;

    final isAbsolute = endpoint.startsWith('http://') || endpoint.startsWith('https://');
    final absolute = isAbsolute ? endpoint : (ApiEndpoints.baseUrl + endpoint);

    String proxied;
    final hasQueryStyle = proxy.contains('?');
    if (hasQueryStyle) {
      // Query-style proxy like http://localhost:8081/proxy?url=
      // Do not add '/'; pass encoded absolute URL
      final needsEquals = proxy.endsWith('=');
      final base = proxy;
      proxied = base + (needsEquals ? '' : '') + Uri.encodeFull(absolute);
    } else if (proxy.endsWith('/')) {
      proxied = proxy + absolute;
    } else {
      proxied = proxy + '/' + absolute;
    }
    // Debug log to help verify CORS proxy is active during web runs
    // ignore: avoid_print
    print('[ApiService] Web proxy active → $proxied');
    return proxied;
  }

  FormData _createFormData(Map<String, dynamic>? data) {
    if (data == null) return FormData();
    return FormData.fromMap(data.map((key, value) {
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
      return MapEntry(key, value);
    }));
  }
}
