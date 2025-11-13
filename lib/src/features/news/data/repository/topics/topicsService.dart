import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/features/news/data/model/topics/topics_Model.dart';

final topicsServiceProvider = Provider<TopicsService>((ref) {
  return TopicsService();
});

class TopicsService {
  TopicsService({ApiService? apiService, Box<String>? userBox})
      : _apiService = apiService ?? ApiService(),
        _userBox = userBox ?? Hive.box<String>('user');

  final ApiService _apiService;
  final Box<String> _userBox;

  Future<List<TopicsModel>> getTopics(String topicId) async {
    final response = await _apiService.post(
      ApiEndpoints.topicsApi,
      {
        'userId': _userBox.get('id', defaultValue: '0') ?? '0',
        'topicId': topicId,
      },
      forceFormData: true,
      caller: 'TopicsService.getTopics',
    );

    if (response is String) {
      final decoded = jsonDecode(response);
      return _mapTopics(decoded);
    }

    return _mapTopics(response);
  }

  List<TopicsModel> _mapTopics(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(TopicsModel.fromJson)
          .toList();
    }
    if (response is Map<String, dynamic>) {
      final result = response['result'];
      if (result is List) {
        return result
            .whereType<Map<String, dynamic>>()
            .map(TopicsModel.fromJson)
            .toList();
      }
    }
    return const [];
  }
}
