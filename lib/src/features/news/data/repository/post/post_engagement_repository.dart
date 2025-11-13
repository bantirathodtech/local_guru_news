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
    await _apiService.post(
      ApiEndpoints.viewCountUpdateApi,
      {'postId': postId},
      forceFormData: true,
      caller: 'PostEngagementRepository.incrementView',
    );
  }

  Future<void> incrementShare(String postId) async {
    await _apiService.post(
      ApiEndpoints.whatsShareCountApi,
      {'postId': postId},
      forceFormData: true,
      caller: 'PostEngagementRepository.incrementShare',
    );
  }

  Future<void> react({
    required String typeId,
    required String type,
    required int like,
  }) async {
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
  }

  Future<List<CommentsModel>> addComment({
    required String postId,
    required String message,
    int replyId = 0,
    int replyUserId = 0,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.newCommentApi,
      {
        'userid': _userId,
        'postid': postId,
        'replyid': replyId.toString(),
        'userReplyId': replyUserId.toString(),
        'message': message,
      },
      forceFormData: true,
      caller: 'PostEngagementRepository.addComment',
    );

    if (response is String) {
      final decoded = json.decode(response);
      return _mapCommentResponse(decoded);
    }

    return _mapCommentResponse(response);
  }

  Future<void> updatePoliticianStatus(String politicianId) async {
    await _apiService.post(
      ApiEndpoints.updatePoliticianStatusApi,
      {
        'userId': _userId,
        'followerId': politicianId,
      },
      forceFormData: true,
      caller: 'PostEngagementRepository.updatePoliticianStatus',
    );
  }

  Future<void> report({
    required String typeId,
    required String type,
  }) async {
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
  }

  List<CommentsModel> _mapCommentResponse(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(CommentsModel.fromJson)
          .toList();
    }
    if (response is Map<String, dynamic>) {
      final result = response['result'];
      if (result is List) {
        return result
            .whereType<Map<String, dynamic>>()
            .map(CommentsModel.fromJson)
            .toList();
      }
    }
    return const [];
  }
}
