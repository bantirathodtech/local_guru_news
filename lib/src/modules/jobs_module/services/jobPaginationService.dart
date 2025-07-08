import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_guru_all/src/src.dart';

final jobsServiceProvider = Provider<JobsService>((ref) => JobsService(Dio()));

class JobsService {
  final Dio _dio;

  JobsService(
    this._dio,
  );

  Box<String> box = Hive.box('user');

  Future<List<JobsModel>> getJobs([
    int page = 1,
    String district = '',
  ]) async {
    try {
      var data = FormData.fromMap(
        {
          'page': page.toString(),
          'district': district,
        },
      );

      final response = await _dio.post(
        DatabaseService.jobsApi + '/jobs_posts_api.php',
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<JobsModel> jobs =
          results.map((e) => JobsModel.fromJson(e)).toList(growable: false);
      return jobs;
    } on DioError catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }

  Future<List<JobsModel>> addJob(
    String state,
    String district,
    String landmark,
    String category,
    String tags,
    String salary,
    String jobType,
    String title,
    String hires,
    String qualification,
    String location,
    String contact,
    String shortDescription,
    String description,
  ) async {
    try {
      var data = FormData.fromMap(
        {
          'id': box.get('id'),
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
        },
      );

      final response = await _dio.post(
        DatabaseService.jobsApi + '/add_new_job.php',
        data: data,
      );
      print(response.data);
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<JobsModel> jobs =
          results.map((e) => JobsModel.fromJson(e)).toList(growable: false);
      return jobs;
    } on DioError catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
