import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/core/api/shared/state/app_state.dart';
import 'package:local_guru_all/src/features/news/data/model/comments/all/commentsModel.dart';

final commentsServiceProvider = Provider<CommentsRepository>((ref) {
  final apiService = ApiService();
  final userId = ref.watch(userIdProvider);
  return CommentsRepository(apiService: apiService, userId: userId);
});

class CommentsRepository {
  CommentsRepository({
    required ApiService apiService,
    required String userId,
  })  : _apiService = apiService,
        _userId = userId;

  final ApiService _apiService;
  final String _userId;

  Future<List<CommentsModel>> getComments({
    int page = 1,
    required String postId,
  }) async {
    final payload = <String, String>{
      'userId': _userId.isNotEmpty ? _userId : '0',
      'postId': postId,
      'page': page <= 0 ? '1' : page.toString(),
    };

    try {
      final response = await _apiService.post(
        ApiEndpoints.commentsApi,
        payload,
        forceFormData: true,
        caller: 'CommentsRepository.getComments',
      );

      final decoded = response is String ? json.decode(response) : response;
      return _extractResults(decoded)
          .map(CommentsModel.fromJson)
          .toList(growable: false);
    } catch (error) {
      // Handle 404 and other errors gracefully - return empty list instead of crashing
      // The error is already logged by ApiLoggingHelper
      // This prevents app crashes when the comments API is not available
      return const [];
    }
  }

  List<Map<String, dynamic>> _extractResults(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final result = decoded['result'];
      if (result is List) {
        return result.whereType<Map<String, dynamic>>().toList(growable: false);
      }
    }

    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
    }

    return const [];
  }
}
