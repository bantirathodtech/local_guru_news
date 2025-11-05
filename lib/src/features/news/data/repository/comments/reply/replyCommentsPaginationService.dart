import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/api_endpoints.dart';

import '../../../../../../src.dart';

final replyCommentsServiceProvider = Provider<ReplyCommentsService>((ref) {
  return ReplyCommentsService(Dio());
});

class ReplyCommentsService {
  final Dio _dio;

  ReplyCommentsService(
    this._dio,
  );

  Box<String> box = Hive.box('user');

  Future<List<ReplyComments>> getComments([
    int page = 1,
    String replyId = '0',
    String postId = '0',
  ]) async {
    try {
      var data = FormData.fromMap(
        {
          'userId': box.containsKey('id') ? box.get('id') : '0',
          'postId': postId,
          'replyId': replyId,
          'page': page.toString(),
        },
      );

      final response = await _dio.post(
        // DatabaseService.newsApi + '/replyComments.php',
        ApiEndpoints.replyCommentsApi,
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<ReplyComments> posts =
          results.map((e) => ReplyComments.fromJson(e)).toList(growable: false);
      return posts;
    } on DioException catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
