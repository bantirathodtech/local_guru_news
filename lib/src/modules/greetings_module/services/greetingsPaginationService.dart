import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/src.dart';

final greetingsServiceProvider =
    Provider<GreetingsService>((ref) => GreetingsService(Dio()));

class GreetingsService {
  final Dio _dio;

  GreetingsService(
    this._dio,
  );

  Future<List<GreetingsModel>> getGreetings([
    int page = 1,
    String topic = '0',
  ]) async {
    try {
      var data = FormData.fromMap(
        {
          'userId': box.containsKey('id') ? box.get('id') : '0',
          'page': page.toString(),
          'topicId': topic,
        },
      );

      final response = await _dio.post(
        DatabaseService.greetingsApi + '/greetings_api.php',
        data: data,
      );
      Map<String, dynamic> result = json.decode(response.data);
      List<dynamic> results = result['result'];
      List<GreetingsModel> greetings = results
          .map((e) => GreetingsModel.fromJson(e))
          .toList(growable: false);
      return greetings;
    } on DioError catch (error) {
      throw ErrorExceptionHandler.fromError(error);
    }
  }
}
