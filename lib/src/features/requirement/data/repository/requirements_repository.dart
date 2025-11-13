import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/core/api/shared/state/app_state.dart';
import 'package:local_guru_all/src/features/requirement/data/model/requirementsModel.dart';

final requirementsRepositoryProvider =
    Provider<RequirementsRepository>((ref) {
  final apiService = ApiService();
  final userId = ref.watch(userIdProvider);
  return RequirementsRepository(apiService: apiService, userId: userId);
});

class RequirementsRepository {
  RequirementsRepository({
    required ApiService apiService,
    required String userId,
  })  : _apiService = apiService,
        _userId = userId;

  final ApiService _apiService;
  final String _userId;

  Future<List<RequirementsModel>> fetchMenu() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.requirementsMenuApi,
        caller: 'RequirementsRepository.fetchMenu',
      );

      final decoded = response is String ? json.decode(response) : response;
      return _extractResults(decoded)
          .map(RequirementsModel.fromJson)
          .toList(growable: false);
    } catch (error) {
      throw Exception('Failed to fetch requirements menu: $error');
    }
  }

  Future<List<RequirementsModel>> fetchRequirements() async {
    final payload = <String, String>{
      'id': _userId.isNotEmpty ? _userId : '0',
    };

    try {
      final response = await _apiService.post(
        ApiEndpoints.requirementsApi,
        payload,
        forceFormData: true,
        caller: 'RequirementsRepository.fetchRequirements',
      );

      final decoded = response is String ? json.decode(response) : response;
      return _extractResults(decoded)
          .map(RequirementsModel.fromJson)
          .toList(growable: false);
    } catch (error) {
      throw Exception('Failed to fetch requirements: $error');
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

