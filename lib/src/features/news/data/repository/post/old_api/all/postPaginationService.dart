import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/src.dart';

import '../../../../../../../core/log/logging.dart';

/// Legacy pagination service that speaks to the existing PHP endpoint
/// (get_all_posts_api.php). Kept alongside the new API flow so editors/managers
/// can fall back to the stable implementation when needed.
class LegacyPostPaginationService {
  /// PHP endpoint always paginates in slices of 10 records.
  static const int pageSize = 10;

  static Future<List<PostsModel>> fetchPosts({
    required String topicId,
    required String topicType,
    required int page,
    String userId = '0',
  }) async {
    final normalizedTopicId = _resolveTopicId(topicId);
    final normalizedTopicType =
        topicType.trim().isNotEmpty ? topicType.trim() : 'topic';
    final effectiveTopicType = normalizedTopicType.toLowerCase();
    final effectiveUserId = userId.isNotEmpty ? userId : '0';

    if (effectiveTopicType == 'topic') {
      return _fetchFromEditorPostsApi(
        page: page,
        topicId: normalizedTopicId,
        userId: effectiveUserId,
      );
    }

    final requestBody = <String, String>{
      'page': page <= 0 ? '1' : page.toString(),
      'topicid': normalizedTopicId,
      'topicType': normalizedTopicType,
      'userId': effectiveUserId,
    };

    AppLogger.logInfo(
      'Legacy fetchPosts(page=$page, topicId=$normalizedTopicId, topicType=$effectiveTopicType, userId=$effectiveUserId)',
      tag: 'legacyPostPagination',
    );

    try {
      final response = await http.post(Uri.parse(ApiEndpoints.getAllPostsApi),
          body: requestBody);

      AppLogger.logInfo(
        'Legacy posts_api status=${response.statusCode}, len=${response.body.length}',
        tag: 'legacyPostPagination',
      );

      if (response.statusCode != 200) {
        AppLogger.logWarning(
          'Legacy API responded with non-200 status ${response.statusCode}',
          tag: 'legacyPostPagination',
        );
        return const [];
      }

      final body = response.body.trim();
      if (body.isEmpty) {
        AppLogger.logWarning('Legacy API returned empty body',
            tag: 'legacyPostPagination');
        return const [];
      }

      final dynamic decoded = json.decode(body);
      final List<dynamic> apiList = _extractResults(decoded);
      final posts = apiList.map((e) => PostsModel.fromJson(e)).toList();

      // PHP selects ASC by pub_time; keep descending for UI parity.
      posts.sort((a, b) {
        final bTime = DateTime.tryParse(b.time ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final aTime = DateTime.tryParse(a.time ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      if (apiList.isNotEmpty) {
        final firstRaw = apiList.first;
        if (firstRaw is Map<String, dynamic>) {
          final previewKeys = firstRaw.keys.join(', ');
          final entryPreview = firstRaw.entries.take(15).map((entry) {
            final value = entry.value;
            if (value is Map) {
              return '${entry.key}={${value.keys.join(', ')}}';
            }
            if (value is List) {
              final slice = value.take(3).join(' | ');
              final suffix = value.length > 3 ? ' …(+${value.length - 3})' : '';
              return '${entry.key}=[$slice$suffix]';
            }
            final stringValue = value.toString();
            return '${entry.key}=${stringValue.length > 120 ? '${stringValue.substring(0, 120)}…' : stringValue}';
          }).join(' || ');

          final sampleJson = jsonEncode(firstRaw);
          final truncatedSample = sampleJson.length > 1200
              ? '${sampleJson.substring(0, 1200)}…'
              : sampleJson;

          AppLogger.logInfo(
            'Legacy raw first post keyset=[$previewKeys]',
            tag: 'legacyPostPagination',
          );
          AppLogger.logInfo(
            'Legacy raw first post entries: $entryPreview',
            tag: 'legacyPostPagination',
          );
          AppLogger.logInfo(
            'Legacy raw first post sample=$truncatedSample',
            tag: 'legacyPostPaginationVerbose',
          );
        }
      }

      if (posts.isNotEmpty) {
        final first = posts.first;
        AppLogger.logInfo(
          'Legacy first post channel=${first.channel} image=${first.channelImage} time=${first.time}',
          tag: 'legacyPostPagination',
        );
      }

      AppLogger.logInfo(
        'Legacy posts parsed count=${posts.length}',
        tag: 'legacyPostPagination',
      );
      return posts;
    } catch (error, stackTrace) {
      AppLogger.logError('Legacy posts_api failure: $error',
          tag: 'legacyPostPagination', stackTrace: stackTrace);
      return const [];
    }
  }

  static Future<List<PostsModel>> _fetchFromEditorPostsApi({
    required int page,
    required String topicId,
    required String userId,
  }) async {
    final requestBody = <String, String>{
      'page': page <= 0 ? '1' : page.toString(),
      'limit': pageSize.toString(),
      'topicType': 'topic',
      'topicid': topicId,
    };

    if (userId.isNotEmpty && userId != '0') {
      requestBody['userId'] = userId;
    }

    AppLogger.logInfo(
      'Legacy editor posts fetch(page=${requestBody['page']}, topicId=$topicId, userId=${requestBody['userId'] ?? '0'})',
      tag: 'legacyPostPagination',
    );

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.fetchEditorPostsApi),
        body: requestBody,
      );

      AppLogger.logInfo(
        'Legacy editor posts status=${response.statusCode}, len=${response.body.length}',
        tag: 'legacyPostPagination',
      );

      if (response.statusCode != 200) {
        AppLogger.logWarning(
          'Legacy editor posts responded with non-200 status ${response.statusCode}',
          tag: 'legacyPostPagination',
        );
        return const [];
      }

      final body = response.body.trim();
      if (body.isEmpty) {
        AppLogger.logWarning(
          'Legacy editor posts API returned empty body',
          tag: 'legacyPostPagination',
        );
        return const [];
      }

      final dynamic decoded = json.decode(body);
      final List<dynamic> apiList = _extractResults(decoded);
      final posts = apiList.map((e) => PostsModel.fromJson(e)).toList();

      posts.sort((a, b) {
        final bTime = DateTime.tryParse(b.time ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final aTime = DateTime.tryParse(a.time ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      AppLogger.logInfo(
        'Legacy editor posts parsed count=${posts.length}',
        tag: 'legacyPostPagination',
      );
      return posts;
    } catch (error, stackTrace) {
      AppLogger.logError('Legacy editor posts failure: $error',
          tag: 'legacyPostPagination', stackTrace: stackTrace);
      return const [];
    }
  }

  static List<dynamic> _extractResults(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final result = decoded['result'] ?? decoded['data'] ?? decoded['posts'];
      if (result is List<dynamic>) {
        return result;
      }
    }
    if (decoded is List<dynamic>) {
      return decoded;
    }
    return const [];
  }

  static String _resolveTopicId(String topicId) {
    if (topicId.isEmpty) {
      return '0';
    }
    if (topicId.contains('/')) {
      return topicId.split('/').last;
    }
    return topicId;
  }
}
