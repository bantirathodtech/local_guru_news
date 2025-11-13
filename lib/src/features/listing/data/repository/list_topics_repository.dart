import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/features/listing/data/model/listTopics.dart';

class ListTopicsRepository {
  ListTopicsRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<ListsTopics>> fetchTopics({required String userId}) async {
    final response = await _apiService.post(
      ApiEndpoints.listTopicsApi,
      {
        'userId': userId,
      },
      forceFormData: true,
      caller: 'ListTopicsRepository.fetchTopics',
    );

    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(ListsTopics.fromJson)
          .toList();
    }

    if (response is Map<String, dynamic>) {
      final result = response['result'];
      if (result is List) {
        return result
            .whereType<Map<String, dynamic>>()
            .map(ListsTopics.fromJson)
            .toList();
      }
    }

    return const [];
  }
}

