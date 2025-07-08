import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../src.dart';

final listServiceProvider = Provider<ListService>((ref) {
  return ListService(Dio());
});

class ListService {
  final Dio _dio;

  ListService(
    this._dio,
  );

  Box<String> box = Hive.box('user');

  Future<List<ListsPosts>> getPosts([
    int page = 1,
    String topicId = '0',
  ]) async {
    try {
      var data = FormData.fromMap(
        {
          // 'userId': box.containsKey('id') ? box.get('id') : '0',
          'page': page.toString(),
          'topicid': topicId,
          'landmark': box.get('landmark')!,
        },
      );
      final response = await _dio.post(
        DatabaseService.listingsApi + '/lists_posts_api.php',
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<ListsPosts> posts =
          results.map((e) => ListsPosts.fromJson(e)).toList(growable: false);
      return posts;
    } on DioError catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
