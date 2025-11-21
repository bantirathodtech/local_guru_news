import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/features/news/data/model/posts/all/posts_Model.dart';
import '../../../../../../../core/log/logging.dart';

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepository();
});

/// PostsRepository - Handles fetching posts using new APIs
/// API Developed By: SAI SANDEEP A
class PostsRepository {
  PostsRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  /// Fetch all posts without any filter
  /// API: get_all_posts_api.php
  /// Parameters: page, limit
  Future<List<PostsModel>> getAllPosts({
    required int page,
    int limit = 20,
  }) async {
    try {
      AppLogger.logInfo(
        'getAllPosts called: page=$page, limit=$limit',
        tag: 'PostsRepository',
      );

      final response = await _apiService.post(
        ApiEndpoints.getAllPostsApi,
        <String, dynamic>{
          'page': page.toString(),
          'limit': limit.toString(),
        },
        forceFormData: true,
        caller: 'PostsRepository.getAllPosts',
      );

      return _parsePostsResponse(response);
    } catch (e, stackTrace) {
      AppLogger.logError(
        'Error in PostsRepository.getAllPosts: $e',
        tag: 'PostsRepository',
      );
      AppLogger.logError('Stack trace: $stackTrace', tag: 'PostsRepository');
      rethrow;
    }
  }

  /// Fetch posts filtered by topic, politician, location, or editor
  /// API: get_posts_by_topic_api.php
  /// Parameters vary based on topicType:
  /// - topic: page, topicid (optional), topicType
  /// - politician: page, topicid (optional), topicType, politicianId
  /// - location: page, topicType, stateId (required), districtId (optional), landmarkId (optional)
  /// - editor: page, topicid (optional), topicType, userId
  Future<List<PostsModel>> getPostsByTopic({
    required int page,
    required String topicType,
    String? topicId,
    String? politicianId,
    String? stateId,
    String? districtId,
    String? landmarkId,
    String? userId,
    int limit = 20,
  }) async {
    try {
      AppLogger.logInfo(
        'getPostsByTopic called: page=$page, topicType=$topicType, topicId=$topicId, politicianId=$politicianId, stateId=$stateId, districtId=$districtId, landmarkId=$landmarkId, userId=$userId',
        tag: 'PostsRepository',
      );

      final Map<String, dynamic> payload = {
        'page': page.toString(),
        'limit': limit.toString(),
        'topicType': topicType,
      };

      // Add topicType-specific parameters
      switch (topicType.toLowerCase()) {
        case 'politician':
          if (politicianId != null && politicianId.isNotEmpty) {
            payload['politicianId'] = politicianId;
          }
          break;
        case 'location':
          // For location type, send stateId (required), districtId and landmarkId (optional)
          // Don't send topicid for location type
          if (stateId != null && stateId.isNotEmpty) {
            payload['stateId'] = stateId;
          }
          if (districtId != null && districtId.isNotEmpty) {
            payload['districtId'] = districtId;
          }
          if (landmarkId != null && landmarkId.isNotEmpty) {
            payload['landmarkId'] = landmarkId;
          }
          break;
        case 'editor':
          if (userId != null && userId.isNotEmpty) {
            payload['userId'] = userId;
          }
          break;
        case 'topic':
          // For topic type, add topicId if provided
          if (topicId != null && topicId.isNotEmpty && topicId != '0') {
            payload['topicid'] = topicId;
          }
          break;
        default:
          AppLogger.logWarning(
            'Unknown topicType: $topicType',
            tag: 'PostsRepository',
          );
      }

      final response = await _apiService.post(
        ApiEndpoints.getPostsByTopicApi,
        payload,
        forceFormData: true,
        caller: 'PostsRepository.getPostsByTopic',
      );

      return _parsePostsResponse(response);
    } catch (e, stackTrace) {
      AppLogger.logError(
        'Error in PostsRepository.getPostsByTopic: $e',
        tag: 'PostsRepository',
      );
      AppLogger.logError('Stack trace: $stackTrace', tag: 'PostsRepository');
      rethrow;
    }
  }

  /// Fetch posts for specific politician using new API
  /// API: list_politician_news_api.php
  Future<List<PostsModel>> getPoliticianNews({
    required int page,
    required String politicianId,
    int limit = 20,
  }) async {
    try {
      AppLogger.logInfo(
        'getPoliticianNews called: page=$page, politicianId=$politicianId, limit=$limit',
        tag: 'PostsRepository',
      );

      final response = await _apiService.post(
        ApiEndpoints.listPoliticianNewsApi,
        <String, dynamic>{
          'page': page.toString(),
          'limit': limit.toString(),
          'politician_id': politicianId,
        },
        forceFormData: true,
        caller: 'PostsRepository.getPoliticianNews',
      );

      if (response is Map) {
        if (response['status']?.toString().toLowerCase() == 'error') {
          AppLogger.logWarning(
            'getPoliticianNews API returned error: ${response['message']}',
            tag: 'PostsRepository',
          );
          return const [];
        }
        if (response['posts'] is List && response['posts'].isNotEmpty) {
          _logSamplePost(response['posts'][0]);
        } else if (response['result'] is List &&
            response['result'].isNotEmpty) {
          _logSamplePost(response['result'][0]);
        }
      } else if (response is List && response.isNotEmpty) {
        _logSamplePost(response[0]);
      }

      return _parsePostsResponse(response);
    } catch (e, stackTrace) {
      AppLogger.logError(
        'Error in PostsRepository.getPoliticianNews: $e',
        tag: 'PostsRepository',
      );
      AppLogger.logError('Stack trace: $stackTrace', tag: 'PostsRepository');
      rethrow;
    }
  }

  /// Parse posts response from API
  /// Handles the new API response structure:
  /// {
  ///   "status": "success",
  ///   "total_posts": 0,
  ///   "current_page": 1,
  ///   "limit": 20,
  ///   "posts_count": 20,
  ///   "posts": [...]
  /// }
  List<PostsModel> _parsePostsResponse(dynamic response) {
    try {
      // Handle String response (if somehow not decoded)
      if (response is String) {
        final decoded = jsonDecode(response);
        return _parsePostsResponse(decoded);
      }

      // Handle direct List response (fallback)
      if (response is List) {
        if (response.isNotEmpty) {
          _logSamplePost(response.first);
        }
        final List<PostsModel> posts = [];
        for (final item in response) {
          if (item is Map) {
            try {
              posts.add(PostsModel.fromJson(Map<String, dynamic>.from(item)));
            } catch (e) {
              AppLogger.logWarning(
                'Error parsing post item: $e',
                tag: 'PostsRepository',
              );
            }
          }
        }
        return posts;
      }

      // Handle Map response - check for 'posts' key first (new API structure)
      if (response is Map) {
        // New API response structure: { "status": "success", "posts": [...] }
        if (response.containsKey('posts') && response['posts'] is List) {
          final postsList = response['posts'] as List;
          if (postsList.isNotEmpty) {
            _logSamplePost(postsList.first);
          }
          final List<PostsModel> posts = [];
          for (final item in postsList) {
            if (item is Map) {
              try {
                posts.add(PostsModel.fromJson(Map<String, dynamic>.from(item)));
              } catch (e) {
                AppLogger.logWarning(
                  'Error parsing post item: $e',
                  tag: 'PostsRepository',
                );
              }
            }
          }
          AppLogger.logInfo(
            'Parsed ${posts.length} posts from new API response structure',
            tag: 'PostsRepository',
          );
          return posts;
        }

        // Fallback to old structure: 'result' or 'data' key
        final result = response['result'] ?? response['data'];
        if (result is List) {
          return _parsePostsResponse(result);
        }
      }

      AppLogger.logWarning(
        'No posts found in response. Response type: ${response.runtimeType}',
        tag: 'PostsRepository',
      );
      return [];
    } catch (e, stackTrace) {
      AppLogger.logError(
        'Error in _parsePostsResponse: $e',
        tag: 'PostsRepository',
      );
      AppLogger.logError('Stack trace: $stackTrace', tag: 'PostsRepository');
      AppLogger.logError('Response: $response', tag: 'PostsRepository');
      return [];
    }
  }

  void _logSamplePost(dynamic raw) {
    try {
      if (raw is Map) {
        AppLogger.logInfo(
          'PostsRepository sample post: ${jsonEncode(raw)}',
          tag: 'PostsRepository',
        );
      } else {
        AppLogger.logInfo(
          'PostsRepository sample post: $raw',
          tag: 'PostsRepository',
        );
      }
    } catch (e) {
      AppLogger.logWarning(
        'PostsRepository: Failed to log sample post: $e',
        tag: 'PostsRepository',
      );
    }
  }
}
