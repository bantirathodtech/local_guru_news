import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/features/listing/data/model/listSearchModel.dart';

final listSearchServiceProvider = Provider<ListSearchRepository>((ref) {
  final apiService = ApiService();
  return ListSearchRepository(apiService: apiService);
});

class ListSearchRepository {
  ListSearchRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<ListsSearchPosts>> getPosts({
    required int page,
    required String search,
  }) async {
    final payload = <String, String>{
      'page': page <= 0 ? '1' : page.toString(),
      'search': search,
    };

    try {
      final response = await _apiService.post(
        ApiEndpoints.listSearchApi,
        payload,
        forceFormData: true,
        caller: 'ListSearchRepository.getPosts',
      );

      final decoded = response is String ? json.decode(response) : response;
      final List<Map<String, dynamic>> normalized = _extractResults(decoded);

      return normalized.map(ListsSearchPosts.fromJson).toList(growable: false);
    } catch (error) {
      throw Exception('Failed to search listings: $error');
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
