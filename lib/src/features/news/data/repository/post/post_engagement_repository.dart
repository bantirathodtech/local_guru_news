import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/features/news/data/model/comments/all/commentsModel.dart';

class PostEngagementRepository {
  PostEngagementRepository({ApiService? apiService, Box<String>? userBox})
      : _apiService = apiService ?? ApiService(),
        _userBox = userBox ?? Hive.box<String>('user');

  final ApiService _apiService;
  final Box<String> _userBox;

  static final PostEngagementRepository instance = PostEngagementRepository();

  String get _userId => _userBox.get('id', defaultValue: '0') ?? '0';

  Future<void> incrementView(String postId) async {
    try {
      await _apiService.post(
        ApiEndpoints.viewCountUpdateApi,
        {'postId': postId},
        forceFormData: true,
        caller: 'PostEngagementRepository.incrementView',
      );
    } catch (e) {
      // Silently handle errors - view count update is not critical
      // Log error but don't crash the app
      // The error is already logged by ApiLoggingHelper
    }
  }

  Future<void> incrementShare(String postId) async {
    try {
      await _apiService.post(
        ApiEndpoints.whatsShareCountApi,
        {'postId': postId},
        forceFormData: true,
        caller: 'PostEngagementRepository.incrementShare',
      );
    } catch (e) {
      // Silently handle errors - share count update is not critical
      // Log error but don't crash the app
    }
  }

  Future<void> react({
    required String typeId,
    required String type,
    required int like,
  }) async {
    try {
      await _apiService.post(
        ApiEndpoints.likeApi,
        {
          'user_id': _userId,
          'type_id': typeId,
          'type': type,
          'like': like.toString(),
        },
        forceFormData: true,
        caller: 'PostEngagementRepository.react',
      );
    } catch (e) {
      // Silently handle errors - like action is optimistic update
      // UI already updated, API failure shouldn't crash the app
    }
  }

  /// Add a new comment to a post
  /// API: add_comments_api.php
  /// Parameters: user_id, post_id, reply_id, reply_userid, message
  /// Response: Array of comment objects [{id, reply_id, user_id, user_name, user_image, comment_date, replied_user, comment_data, likes, dislikes, liked, reply_count}]
  Future<List<CommentsModel>> addComment({
    required String postId,
    required String message,
    int replyId = 0,
    int replyUserId = 0,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.newCommentApi, // Points to add_comments_api.php
      {
        'user_id': _userId,
        'post_id': postId,
        'reply_id': replyId.toString(),
        'reply_userid': replyUserId.toString(),
        'message': message,
      },
      forceFormData: true,
      caller: 'PostEngagementRepository.addComment',
    );

    // Handle string response (if API returns JSON string)
    if (response is String) {
      try {
        final decoded = json.decode(response);
        return _mapCommentResponse(decoded);
      } catch (e) {
        // If decoding fails, return empty list
        return const [];
      }
    }

    // Handle direct object/array response
    return _mapCommentResponse(response);
  }

  Future<void> updatePoliticianStatus(String politicianId) async {
    try {
      await _apiService.post(
        ApiEndpoints.updatePoliticianStatusApi,
        {
          'userId': _userId,
          'followerId': politicianId,
        },
        forceFormData: true,
        caller: 'PostEngagementRepository.updatePoliticianStatus',
      );
    } catch (e) {
      // Silently handle errors - politician status update is not critical
    }
  }

  Future<void> report({
    required String typeId,
    required String type,
  }) async {
    try {
      await _apiService.post(
        ApiEndpoints.reportApi,
        {
          'user_id': _userId,
          'type_id': typeId,
          'type': type,
        },
        forceFormData: true,
        caller: 'PostEngagementRepository.report',
      );
    } catch (e) {
      // Silently handle errors - report action failure shouldn't crash the app
      // Consider showing a user-friendly error message in the UI if needed
      rethrow; // Re-throw for report as it might need user feedback
    }
  }

  /// Map API response to CommentsModel list
  /// Handles array response: [{id, reply_id, user_id, user_name, ...}]
  /// Also handles wrapped responses: {result: [...]}
  List<CommentsModel> _mapCommentResponse(dynamic response) {
    // Direct array response (most common case for add_comments_api.php)
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map((item) {
            try {
              return CommentsModel.fromJson(item);
            } catch (e) {
              // Log error but continue processing other items
              return null;
            }
          })
          .whereType<CommentsModel>()
          .toList();
    }
    
    // Wrapped response: {result: [...]} or {data: [...]}
    if (response is Map<String, dynamic>) {
      final result = response['result'] ?? response['data'] ?? response['comments'];
      if (result is List) {
        return result
            .whereType<Map<String, dynamic>>()
            .map((item) {
              try {
                return CommentsModel.fromJson(item);
              } catch (e) {
                return null;
              }
            })
            .whereType<CommentsModel>()
            .toList();
      }
    }
    
    return const [];
  }
}
