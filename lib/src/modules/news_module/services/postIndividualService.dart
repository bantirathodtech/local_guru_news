import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../src.dart';

final postIndividualServiceProvider = Provider<PostIndividualService>((ref) {
  return PostIndividualService(Dio());
});

class PostIndividualService {
  final Dio _dio;

  PostIndividualService(
    this._dio,
  );

  Box<String> box = Hive.box('user');

  Future<List<PostsModelByID>> getPosts([
    int id = 1,
  ]) async {
    try {
      var data = FormData.fromMap(
        {
          'userId': box.containsKey('id') ? box.get('id') : '0',
          'id': id,
        },
      );

      final response = await _dio.post(
        DatabaseService.newsApi + '/postById_api.php',
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<PostsModelByID> posts = results
          .map((e) => PostsModelByID.fromJson(e))
          .toList(growable: false);
      return posts;
    } on DioError catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
