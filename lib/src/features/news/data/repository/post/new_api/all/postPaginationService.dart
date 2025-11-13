import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/features/news/data/model/posts/all/posts_Model.dart';

import '../../../../../../../core/log/logging.dart';

class PostPaginationService {
  // Page size for pagination (number of posts per page)
  static const int pageSize = 20;

  static Future<List<PostsModel>> fetchPosts({
    required String topicId,
    required String topicType,
    required int page,
    required String userId,
    required String landmarkId,
    String stateId = '',
    String districtId = '',
    String politicianId = '',
    String editorId = '',
    String channelId = '',
    String sourceType = '',
    String managerId = '',
    int limit = pageSize,
  }) async {
    AppLogger.logInfo(
      'fetchPosts called with topicId=$topicId, topicType=$topicType, page=$page, userId=$userId, landmarkId=$landmarkId, stateId=$stateId, districtId=$districtId, politicianId=$politicianId, editorId=$editorId, channelId=$channelId, sourceType=$sourceType, managerId=$managerId, limit=$limit',
    );

    final normalizedTopicId = _resolveTopicId(topicId);
    final normalizedStateId = _normalizeId(stateId);
    final normalizedDistrictId = _normalizeId(districtId);
    final normalizedLandmarkId = _normalizeId(landmarkId);
    final normalizedPoliticianId = _normalizeId(politicianId);
    final effectiveEditorId = editorId.isNotEmpty ? editorId : userId;
    final normalizedChannelId = channelId.trim().isEmpty ? '0' : channelId;
    final normalizedManagerId = managerId.trim().isEmpty ? '0' : managerId;
    final normalizedSourceType = sourceType.isNotEmpty
        ? sourceType
        : (topicType != 'general' ? topicType : '');

    final requestBody = <String, String>{
      'userId': userId,
      'page': page.toString(),
      'limit': limit.toString(),
      'state_id': normalizedStateId,
      'district_id': normalizedDistrictId,
      'landmark_id': normalizedLandmarkId,
      'politician_id': normalizedPoliticianId,
      'editor_id': effectiveEditorId,
      'topic_id': normalizedTopicId,
      'channel_id': normalizedChannelId,
      'source_type': normalizedSourceType,
      'manager_id': normalizedManagerId,
    };

    List<PostsModel> apiPosts = [];
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.fetchEditorPostsApi),
        body: requestBody,
      );

      AppLogger.logInfo('API response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          // Trim whitespace and check if it's valid JSON
          final trimmedBody = response.body.trim();
          if (trimmedBody.isEmpty) {
            AppLogger.logInfo('API response body is empty after trimming');
          } else {
            Map<String, dynamic> result = json.decode(trimmedBody);
            final List<dynamic> apiList = _extractResults(result);
            apiPosts = apiList.map((e) => PostsModel.fromJson(e)).toList();
            AppLogger.logInfo('Parsed API posts count: ${apiPosts.length}');
          }
        } catch (e) {
          AppLogger.logError('Error parsing API response: $e');
        }
      } else {
        AppLogger.logInfo(
            'API Response error or empty: status=${response.statusCode}, bodyLength=${response.body.length}');
      }
    } catch (e) {
      AppLogger.logError('Error fetching from API: $e');
    }

    // Sort posts by post time descending
    apiPosts.sort((a, b) {
      DateTime bTime = DateTime.tryParse(b.time ?? '') ?? DateTime.now();
      DateTime aTime = DateTime.tryParse(a.time ?? '') ?? DateTime.now();
      return bTime.compareTo(aTime);
    });

    AppLogger.logInfo('Total API posts count: ${apiPosts.length}');

    return apiPosts;
  }

  static String _resolveTopicId(String topicId) {
    if (topicId.isEmpty) return '0';
    if (topicId.contains('/')) {
      return topicId.split('/').last;
    }
    return topicId;
  }

  static String _normalizeId(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty || trimmedValue.toLowerCase() == 'null') {
      return '0';
    }
    return trimmedValue;
  }

  static List<dynamic> _extractResults(Map<String, dynamic> response) {
    if (response.containsKey('result')) {
      return response['result'] ?? [];
    }

    if (response.containsKey('data')) {
      return response['data'] ?? [];
    }

    if (response.containsKey('posts')) {
      return response['posts'] ?? [];
    }

    return [];
  }
}
