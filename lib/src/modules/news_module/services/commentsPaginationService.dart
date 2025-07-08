import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../src.dart';

final commentsServiceProvider = Provider<CommentsService>((ref) {
  return CommentsService(Dio());
});

class CommentsService {
  final Dio _dio;

  CommentsService(
    this._dio,
  );

  Box<String> box = Hive.box('user');

  Future<List<CommentsModel>> getComments([
    int page = 1,
    String postId = '0',
  ]) async {
    try {
      var data = FormData.fromMap(
        {
          'userId': box.containsKey('id') ? box.get('id') : '0',
          'postId': postId,
          'page': page.toString(),
        },
      );

      final response = await _dio.post(
        DatabaseService.newsApi + '/comments_api.php',
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<CommentsModel> posts =
          results.map((e) => CommentsModel.fromJson(e)).toList(growable: false);
      return posts;
    } on DioError catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
