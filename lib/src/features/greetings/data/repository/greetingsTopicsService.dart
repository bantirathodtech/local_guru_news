import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/core/api/shared/state/app_state.dart';
import 'package:local_guru_all/src/features/greetings/data/model/greetingsTopicsModel.dart';

final greetingsTopicsServiceProvider =
    Provider<GreetingsTopicsRepository>((ref) {
  final apiService = ApiService();
  final userId = ref.watch(userIdProvider);
  return GreetingsTopicsRepository(apiService: apiService, userId: userId);
});

class GreetingsTopicsRepository {
  GreetingsTopicsRepository({
    required ApiService apiService,
    required String userId,
  })  : _apiService = apiService,
        _userId = userId;

  final ApiService _apiService;
  final String _userId;

  Future<List<GreetingsTopics>> getGreetings() async {
    // New API endpoint doesn't require userId parameter
    final requestBody = <String, String>{};

    try {
      final response = await _apiService.post(
        ApiEndpoints.greetingsCategoriesApi,
        requestBody,
        forceFormData: true,
        caller: 'GreetingsTopicsRepository.getGreetings',
      );

      final decoded = response is String ? json.decode(response) : response;
      if (decoded is Map<String, dynamic>) {
        final status = decoded['status'];
        if (status == 'success') {
          final results = decoded['result'];
          if (results is List) {
            return results
                .whereType<Map<String, dynamic>>()
                .map(GreetingsTopics.fromJson)
                .toList(growable: false);
          }
        }
      } else if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(GreetingsTopics.fromJson)
            .toList(growable: false);
      }

      return const [];
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        Exception('Failed to fetch greeting categories: $error'),
        stackTrace,
      );
    }
  }
}
