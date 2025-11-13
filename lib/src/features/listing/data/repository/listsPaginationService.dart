import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/core/api/shared/state/app_state.dart';
import 'package:local_guru_all/src/features/listing/data/model/listsModel.dart';

final listServiceProvider = Provider<ListsRepository>((ref) {
  final apiService = ApiService();
  final userId = ref.watch(userIdProvider);
  final landmark = ref.watch(locationLandmark);
  return ListsRepository(
    apiService: apiService,
    userId: userId,
    landmark: landmark,
  );
});

class ListsRepository {
  ListsRepository({
    required ApiService apiService,
    required String userId,
    required String landmark,
  })  : _apiService = apiService,
        _userId = userId,
        _landmark = landmark;

  final ApiService _apiService;
  final String _userId;
  final String _landmark;

  Future<List<ListsPosts>> getPosts({
    int page = 1,
    String topicId = '0',
  }) async {
    final payload = <String, String>{
      'userId': _userId.isNotEmpty ? _userId : '0',
      'page': page <= 0 ? '1' : page.toString(),
      'topicid': topicId.isNotEmpty ? topicId : '0',
    };

    final landmark = _landmark.trim();
    if (landmark.isNotEmpty) {
      payload['landmark'] = landmark;
    }

    try {
      final response = await _apiService.post(
        ApiEndpoints.listPostApi,
        payload,
        forceFormData: true,
        caller: 'ListsRepository.getPosts',
      );

      final decoded = response is String ? json.decode(response) : response;
      final List<Map<String, dynamic>> normalized = _extractResults(decoded);

      return normalized.map(ListsPosts.fromJson).toList(growable: false);
    } catch (error) {
      throw Exception('Failed to fetch listing posts: $error');
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
