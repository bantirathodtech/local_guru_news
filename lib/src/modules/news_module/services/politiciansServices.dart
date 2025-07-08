import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../src.dart';

final politicansServiceProvider = Provider<PoliticiansService>((ref) {
  return PoliticiansService(Dio());
});

class PoliticiansService {
  final Dio _dio;

  PoliticiansService(
    this._dio,
  );

  Box<String> box = Hive.box('user');

  Future<List<PoliticianModel>> getTopics() async {
    try {
      var data = FormData.fromMap(
        {
          'userId': box.containsKey('id') ? box.get('id') : '0',
        },
      );

      final response = await _dio.post(
        DatabaseService.newsApi + '/politicians_api.php',
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<PoliticianModel> politicians = results
          .map((e) => PoliticianModel.fromJson(e))
          .toList(growable: false);
      return politicians;
    } on DioError catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
