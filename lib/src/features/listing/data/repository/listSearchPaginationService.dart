import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:local_guru_all/src/core/api/custom/endpoints/api_endpoints.dart';

import '../../../../src.dart';

final listSearchServiceProvider = Provider<ListSearchService>((ref) {
  return ListSearchService(Dio());
});

class ListSearchService {
  final Dio _dio;

  ListSearchService(
    this._dio,
  );

  Box<String> box = Hive.box('user');

  Future<List<ListsSearchPosts>> getPosts(
    int page,
    String search,
  ) async {
    try {
      var data = FormData.fromMap(
        {
          'page': page.toString(),
          'search': search,
        },
      );

      final response = await _dio.post(
        // DatabaseService.listingsApi + '/lists_search_api.php',
        ApiEndpoints.listSearchApi,
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<ListsSearchPosts> posts = results
          .map((e) => ListsSearchPosts.fromJson(e))
          .toList(growable: false);
      return posts;
    } on DioException catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
