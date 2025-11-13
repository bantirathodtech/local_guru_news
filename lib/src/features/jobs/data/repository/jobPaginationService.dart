import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';
import 'package:local_guru_all/src/core/api/shared/state/app_state.dart';
import 'package:local_guru_all/src/features/jobs/data/model/jobsModel.dart';

final jobsServiceProvider = Provider<JobsRepository>((ref) {
  final apiService = ApiService();
  final userId = ref.watch(userIdProvider);
  return JobsRepository(apiService: apiService, userId: userId);
});

class JobsRepository {
  JobsRepository({
    required ApiService apiService,
    required String userId,
  })  : _apiService = apiService,
        _userId = userId;

  final ApiService _apiService;
  final String _userId;

  Future<List<JobsModel>> getJobs({
    int page = 1,
    String district = '',
  }) async {
    final payload = <String, String>{
      'page': page <= 0 ? '1' : page.toString(),
    };

    if (district.isNotEmpty) {
      payload['district'] = district;
    }

    try {
      final response = await _apiService.post(
        ApiEndpoints.jobsApi,
        payload,
        forceFormData: true,
        caller: 'JobsRepository.getJobs',
      );

      final decoded = response is String ? json.decode(response) : response;
      final List<Map<String, dynamic>> normalized = _extractResults(decoded);

      return normalized.map(JobsModel.fromJson).toList(growable: false);
    } catch (error) {
      throw Exception('Failed to fetch jobs: $error');
    }
  }

  Future<List<JobsModel>> addJob({
    required String state,
    required String district,
    required String landmark,
    required String category,
    required String tags,
    required String salary,
    required String jobType,
    required String title,
    required String hires,
    required String qualification,
    required String location,
    required String contact,
    required String shortDescription,
    required String description,
  }) async {
    final payload = <String, String>{
      'id': _userId.isNotEmpty ? _userId : '0',
      'state': state,
      'district': district,
      'landmark': landmark,
      'cat_id': category,
      'tags': tags,
      'title': title,
      'salary': salary,
      'job_type': jobType,
      'hires': hires,
      'qualification': qualification,
      'location': location,
      'contact_details': contact,
      'shortDescription': shortDescription,
      'description': description,
    };

    try {
      final response = await _apiService.post(
        ApiEndpoints.addNewJobApi,
        payload,
        forceFormData: true,
        caller: 'JobsRepository.addJob',
      );

      final decoded = response is String ? json.decode(response) : response;
      final List<Map<String, dynamic>> normalized = _extractResults(decoded);

      return normalized.map(JobsModel.fromJson).toList(growable: false);
    } catch (error) {
      throw Exception('Failed to create job: $error');
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
