import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:local_guru_all/src/core/api/custom/endpoints/api_endpoints.dart';
import 'package:local_guru_all/src/src.dart';

import '../../../../rss/feed_parser.dart';
import '../../../../rss/rss_utils.dart';

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

    // If not found, search in frontend RSS feeds
    for (var feed in rssFeeds) {
      // Parse RSS posts (as PostsModel)
      List<PostsModel> parsedPosts =
          await FeedParser.parseRssFromUrl(feed['url']!);

      // Convert to PostsModelByID list
      List<PostsModelByID> convertedPosts = parsedPosts
          .map((post) => PostsModelByID(
                id: post.id,
                title: post.title,
                description: post.description,
                time: post.time,
                // map all required fields accordingly
              ))
          .toList();

      try {
        return convertedPosts.firstWhere((post) => post.id == id);
      } catch (e) {
        // continue to next feed if not found
      }
    }

    // Not found anywhere
    return null;
  }
}

// import 'dart:convert';
//
// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive/hive.dart';
// import 'package:local_guru_all/src/core/services/api/endpoints/api_endpoints.dart';
//
// import '../../../../../../src.dart';
//
// final postIndividualServiceProvider = Provider<PostIndividualService>((ref) {
//   return PostIndividualService(Dio());
// });
//
// class PostIndividualService {
//   final Dio _dio;
//
//   PostIndividualService(
//     this._dio,
//   );
//
//   Box<String> box = Hive.box('user');
//
//   Future<List<PostsModelByID>> getPosts([
//     int id = 1,
//   ]) async {
//     try {
//       var data = FormData.fromMap(
//         {
//           'userId': box.containsKey('id') ? box.get('id') : '0',
//           'id': id,
//         },
//       );
//
//       final response = await _dio.post(
//         // DatabaseService.newsApi + '/postById_api.php',
//         ApiEndpoints.postByIdApi,
//         data: data,
//       );
//       Map<String, dynamic> result = json.decode(response.data);
//       List<dynamic> results = result['result'];
//       List<PostsModelByID> posts = results
//           .map((e) => PostsModelByID.fromJson(e))
//           .toList(growable: false);
//       return posts;
//     } on DioError catch (error) {
//       throw ErrorExceptionHandler.fromError(error);
//     }
//   }
// }
