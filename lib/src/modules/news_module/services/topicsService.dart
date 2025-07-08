import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../src.dart';

final topicsServiceProvider = Provider<TopicsService>((ref) {
  return TopicsService(Dio());
});

class TopicsService {
  final Dio _dio;

  TopicsService(
    this._dio,
  );

  Box<String> box = Hive.box('user');

  Future<List<TopicsModel>> getTopics(String topicId) async {
    try {
      var data = FormData.fromMap(
        {
          'userId': box.containsKey('id') ? box.get('id') : '0',
          'topicId': box.get('landmark')!,
        },
      );

      final response = await _dio.post(
        DatabaseService.newsApi + '/topics_api.php',
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<TopicsModel> topics =
          results.map((e) => TopicsModel.fromJson(e)).toList(growable: false);
      return topics;
    } on DioError catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
