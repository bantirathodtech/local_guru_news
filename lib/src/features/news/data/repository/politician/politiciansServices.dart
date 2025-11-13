import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/features/news/data/model/politician/politicians_Model.dart';

final politicansServiceProvider = Provider<PoliticiansService>((ref) {
  return PoliticiansService();
});

class PoliticiansService {
  PoliticiansService({ApiService? apiService, Box<String>? userBox})
      : _apiService = apiService ?? ApiService(),
        _userBox = userBox ?? Hive.box<String>('user');

  final ApiService _apiService;
  final Box<String> _userBox;

  Future<List<PoliticianModel>> getTopics() async {
    final response = await _apiService.post(
      ApiEndpoints.politicianApi,
      {
        'userId': _userBox.get('id', defaultValue: '0') ?? '0',
      },
      forceFormData: true,
      caller: 'PoliticiansService.getTopics',
    );

    if (response is String) {
      final decoded = jsonDecode(response);
      return _mapPoliticians(decoded);
    }

    return _mapPoliticians(response);
  }

  List<PoliticianModel> _mapPoliticians(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map(PoliticianModel.fromJson)
          .toList();
    }
    if (response is Map<String, dynamic>) {
      final result = response['result'];
      if (result is List) {
        return result
            .whereType<Map<String, dynamic>>()
            .map(PoliticianModel.fromJson)
            .toList();
      }
    }
    return const [];
  }
}
