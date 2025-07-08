import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_guru_all/src/src.dart';

final jobsSearchServiceProvider = Provider<JobsSearchService>((ref) {
  return JobsSearchService(Dio());
});

class JobsSearchService {
  final Dio _dio;

  JobsSearchService(
    this._dio,
  );

  Box<String> box = Hive.box('user');

  Future<List<JobsSearchModel>> getJobs(int page, String search,) async {
    try {
      var data = FormData.fromMap(
        {
          'page': page.toString(),
          'search': search,
        },
      );

      final response = await _dio.post(
        DatabaseService.jobsApi + '/job_search_api.php',
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<JobsSearchModel> jobs = results
          .map((e) => JobsSearchModel.fromJson(e))
          .toList(growable: false);
      return jobs;
    } on DioError catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
