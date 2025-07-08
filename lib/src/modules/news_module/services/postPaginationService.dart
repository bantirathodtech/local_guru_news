import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../src.dart';

final postServiceProvider = Provider<PostService>((ref) {
  return PostService(Dio());
});

class PostService {
  final Dio _dio;

  PostService(
    this._dio,
  );

  Box<String> box = Hive.box('user');

  Future<List<PostsModel>> getPosts([
    int page = 1,
    String topicId = '0',
    String topicType = 'landmark',
  ]) async {
    try {
      var data = FormData.fromMap(
        {
          'userId': box.containsKey('id') ? box.get('id') : '0',
          'page': page.toString(),
          'topicid': topicType == 'landmark'
              ? box.containsKey('landmark')
                  ? box.get('landmark')!
                  : 0
              : topicId.split('/').last,
          'topicType': topicType,
        },
      );

      final response = await _dio.post(
        DatabaseService.newsApi + '/posts_api.php',
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<PostsModel> posts =
          results.map((e) => PostsModel.fromJson(e)).toList(growable: false);
      return posts;
    } on DioError catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
