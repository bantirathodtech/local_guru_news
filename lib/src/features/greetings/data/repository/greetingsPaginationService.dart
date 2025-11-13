import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/core/api/shared/state/app_state.dart';
import 'package:local_guru_all/src/features/greetings/data/model/greetingsModel.dart';

final greetingsServiceProvider = Provider<GreetingsRepository>((ref) {
  final apiService = ApiService();
  final userId = ref.watch(userIdProvider);
  return GreetingsRepository(apiService: apiService, userId: userId);
});

class GreetingsRepository {
  GreetingsRepository({
    required ApiService apiService,
    required String userId,
  })  : _apiService = apiService,
        _userId = userId;

  final ApiService _apiService;
  final String _userId;

  Future<List<GreetingsModel>> getGreetings({
    int page = 1,
    String topicId = '0',
  }) async {
    final requestBody = <String, String>{
      'userId': _userId.isNotEmpty ? _userId : '0',
      'page': page <= 0 ? '1' : page.toString(),
      'topicId': topicId.isNotEmpty ? topicId : '0',
    };

    try {
      final response = await _apiService.post(
        ApiEndpoints.greetingsApi,
        requestBody,
        forceFormData: true,
        caller: 'GreetingsRepository.getGreetings',
      );

      final decoded = response is String ? json.decode(response) : response;
      if (decoded is Map<String, dynamic>) {
        final results = decoded['result'];
        if (results is List) {
          return results
              .whereType<Map<String, dynamic>>()
              .map(GreetingsModel.fromJson)
              .toList(growable: false);
        }
      } else if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(GreetingsModel.fromJson)
            .toList(growable: false);
      }

      return const [];
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        Exception('Failed to fetch greetings: $error'),
        stackTrace,
      );
    }
  }
}
