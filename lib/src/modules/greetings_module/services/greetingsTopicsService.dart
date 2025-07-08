import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/src.dart';

final greetingsTopicsServiceProvider =
    Provider<GreetingsTopicsService>((ref) => GreetingsTopicsService(Dio()));

class GreetingsTopicsService {
  final Dio _dio;

  GreetingsTopicsService(
    this._dio,
  );

  Future<List<GreetingsTopics>> getGreetings() async {
    try {
      var data = FormData.fromMap(
        {
          'userId': box.containsKey('id') ? box.get('id') : '0',
        },
      );

      final response = await _dio.post(
        DatabaseService.greetingsApi + '/greetings_topics_api.php',
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<GreetingsTopics> greetingsTopics = results
          .map((e) => GreetingsTopics.fromJson(e))
          .toList(growable: false);
      return greetingsTopics;
    } on DioError catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
