import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/src.dart';

class PostIndividualService {
  static Future<PostsModelByID?> fetchPostById(String id) async {
    // Fetch post by id from backend API
    Map<String, String> body = {
      'id': id,
    };
    final response =
        await http.post(Uri.parse(ApiEndpoints.postByIdApi), body: body);
    Map<String, dynamic> result = json.decode(response.body);
    List<dynamic> apiList = result['result'] ?? [];
    if (apiList.isNotEmpty) {
      return PostsModelByID.fromJson(apiList.first);
    }

    // Not found in API
    return null;
  }
}
