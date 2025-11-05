//Database Services
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:local_guru_all/src/core/api/custom/endpoints/api_endpoints.dart';
import 'package:local_guru_all/src/features/requirement/data/model/requirementsModel.dart';

import '../../../src.dart';

class DatabaseService {
  // static String baseUrl = 'https://localguru.in/_api/';
  // static String newsApi = baseUrl + 'news/';
  // static String greetingsApi = baseUrl + 'greetings/';
  // static String jobsApi = baseUrl + 'jobs/';
  // static String listingsApi = baseUrl + 'listings/';

  Box<String> box = Hive.box('user');

  // Location - OLD API (commented out, now using 3 separate APIs)
  // static Future<List<LocationModel>> fetchLoction() async {
  //   // final response = await http.get(Uri.parse(baseUrl + 'location.php'));
  //   final response = await http.get(Uri.parse(ApiEndpoints.locationApi));
  //   List<dynamic> result = jsonDecode(response.body);
  //   return result.map((e) => new LocationModel.fromJson(e)).toList();
  // }
  // ListTopics

  Future<List<ListsTopics>> fetchListTopics() async {
    Map<String, String> body = {
      'userId': (box.containsKey('id') && box.get('id') != null)
          ? box.get('id').toString()
          : '0',
    };
    final response = await http
        // .post(Uri.parse(listingsApi + 'list_topics_api.php'), body: body);
        .post(Uri.parse(ApiEndpoints.listTopicsApi), body: body);
    List<dynamic> result = jsonDecode(response.body);
    return result.map((e) => new ListsTopics.fromJson(e)).toList();
  }

  // New Job Data

  Future<NewJobModel> fetchJobData() async {
    Map<String, String> body = {
      'id': (box.containsKey('id') && box.get('id') != null)
          ? box.get('id').toString()
          : '0',
    };

    final response =
        await http.post(Uri.parse(ApiEndpoints.jobNewDataApi), body: body);
    return newJobModelFromJson(response.body);
  }

  // Requirements Menu
  static Future<List<RequirementsModel>> requirementsMenu() async {
    final response =
        await http.get(Uri.parse(ApiEndpoints.requirementsMenuApi));
    Map<String, dynamic> result = json.decode(response.body);
    List<dynamic> r = result['result'];
    return r.map((e) => new RequirementsModel.fromJson(e)).toList();
  }

  Future<List<RequirementsModel>> fetchrequirements() async {
    Map<String, String> body = {
      'id': box.containsKey('id') ? box.get('id')! : "0",
    };
    final response = await http.post(
      Uri.parse(ApiEndpoints.requirementsApi),
      body: body,
    );
    Map<String, dynamic> result = json.decode(response.body);
    List<dynamic> r = result['result'];
    return r.map((e) => new RequirementsModel.fromJson(e)).toList();
  }

  //Topics
  // Future<List<TopicsModel>> fetchTopics() async {
  //   Map<String, String> body = {
  //     'id': box.get('landmark')!,
  //   };
  //   final response =
  //       await http.post(Uri.parse(newsApi + 'topics_api.php'), body: body);
  //   List<dynamic> result = jsonDecode(response.body);
  //   return result.map((e) => new TopicsModel.fromJson(e)).toList();
  // }

  //Politicians
  // Future<List<PoliticianModel>> fetchPoliticians() async {
  //   final response = await http.post(
  //     Uri.parse(newsApi + 'politicians_api.php'),
  //   );
  //   List<dynamic> result = jsonDecode(response.body);
  //   return result.map((e) => new PoliticianModel.fromJson(e)).toList();
  // }

  //Politician Status Update
  Future<void> updatePoliticianStatus(String id) async {
    Map<String, String> body = {
      'userId': box.get('id')!,
      'followerId': id,
    };
    await http.post(
      Uri.parse(ApiEndpoints.updatePoliticianStatusApi),
      body: body,
    );
  }

  // Posts
  static Future<List<PostsModel>> fetchPosts(String topic) async {
    Map<String, String> body = {
      'topic': topic,
    };
    final response =
        await http.post(Uri.parse(ApiEndpoints.postApi), body: body);
    Map<String, dynamic> result = json.decode(response.body);
    List<dynamic> r = result['result'];
    return r.map((e) => new PostsModel.fromJson(e)).toList();
  }

  // Post by Id
  static Future<List<PostsModel>> fetchPostById(String id) async {
    Map<String, String> body = {
      'id': id,
    };
    final response =
        await http.post(Uri.parse(ApiEndpoints.postByIdApi), body: body);
    Map<String, dynamic> result = json.decode(response.body);
    List<dynamic> r = result['result'];
    return r.map((e) => new PostsModel.fromJson(e)).toList();
  }

  // // Token
  // static Future<void> getToken(String token) async {
  //   Map<String, String> body = {
  //     'token': token,
  //   };
  //   await http.post(Uri.parse(baseUrl + 'token_api.php'), body: body);
  // }

  // Otp Verification
  // static Future<List<MobileAuth>> getOtp(String mobile) async {
  //   Map<String, String> body = {
  //     'mobile': mobile,
  //   };
  //   final response =
  //       await http.post(Uri.parse(ApiEndpoints.phoneAuthApi), body: body);
  //   List<dynamic> result = json.decode(response.body);
  //   return result.map((e) => new MobileAuth.fromJson(e)).toList();
  // }

  // Verify User
  Future<String> verifyUser(
    String id,
    String mobile,
    String otp,
    String token,
  ) async {
    Map<String, String> body = {
      'mobile': mobile,
      'id': id,
      'otp': otp,
      'token': token,
    };
    final response =
        await http.post(Uri.parse(ApiEndpoints.verifyUserApi), body: body);

    var result = json.decode(response.body);

    // Check if response contains user data (success case)
    if (result is List && result.isNotEmpty && result[0]['id'] != null) {
      List<dynamic> r = result;
      box.put('id', r[0]['id'].toString());
      box.put('token', r[0]['token'].toString());
      box.put('name', r[0]['name'].toString());
      box.put('profile', r[0]['profile'].toString());
      box.put('contact', r[0]['contact'].toString());
      return 'success'; // This now matches the check
    } else {
      return 'error'; // Or return the actual error message
    }
  }

  // Expire OTP
  static Future expireOTP(
    String id,
    String mobile,
    String otp,
  ) async {
    Map<String, String> body = {
      'mobile': mobile,
      'id': id,
      'otp': otp,
    };
    await http.post(Uri.parse(ApiEndpoints.expireOtpApi), body: body);
  }

  // Update Profile
  Future<String> updateProfile(
    String name,
    String profileName,
    File image,
  ) async {
    var data = FormData.fromMap({
      'id': box.get('id'),
      'name': name,
      'profileName': profileName,
    });
    // Image
    String fileName = image.path.split('/').last;
    data.files.add(
      MapEntry(
        'image',
        await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
      ),
    );

    final respose = await Dio().post(
      ApiEndpoints.updateProfileApi,
      data: data,
    );
    var result = json.decode(respose.data);

    if (result.toString().contains("error")) {
      return result;
    } else {
      List<dynamic> r = result;
      box.put('name', r[0]['name'].toString());
      box.put('profile', r[0]['profile'].toString());
      return 'success';
    }
  }

  // Update Profile Only Name
  Future<String> updateProfileOnlyName(
    String name,
  ) async {
    var data = FormData.fromMap({
      'id': box.get('id'),
      'name': name,
    });

    final respose = await Dio().post(
      ApiEndpoints.updateProfileApi,
      data: data,
    );
    var result = json.decode(respose.data);

    if (result.toString().contains("error")) {
      return result;
    } else {
      List<dynamic> r = result;
      box.put('name', r[0]['name'].toString());
      return 'success';
    }
  }

  //------------------- social------------
  //ApiEndpoints.reportApi

  // Views Count
  static Future<void> updateViewCount(String id) async {
    Map<String, String> body = {
      'postId': id,
    };
    await http.post(Uri.parse(ApiEndpoints.viewCountUpdateApi), body: body);
  }

  // Likes Count
  Future<void> like(String tyepid, String type, String like) async {
    Map<String, String> body = {
      'user_id': box.containsKey('id') ? box.get('id').toString() : '0',
      'type_id': tyepid,
      'type': type,
      'like': like,
    };
    await http.post(Uri.parse(ApiEndpoints.likeApi), body: body);
  }

  // Share Count
  static Future<void> updateShareCount(String id) async {
    Map<String, String> body = {
      'postId': id,
    };
    await http.post(Uri.parse(ApiEndpoints.whatsShareCountApi), body: body);
  }

  // New Comment
  Future<List<CommentsModel>> newComment(
      String postId, int replyid, int userReplyId, String message) async {
    Map<String, String> body = {
      'userid': box.get('id').toString(),
      'postid': postId,
      'replyid': replyid.toString(),
      'userReplyId': userReplyId.toString(),
      'message': message,
    };
    final respose =
        await http.post(Uri.parse(ApiEndpoints.newCommentApi), body: body);

    List<dynamic> result = json.decode(respose.body);

    return result.map((e) => CommentsModel.fromJson(e)).toList();
  }

  // Report
  Future<void> report(String typeId, String type) async {
    Map<String, String> body = {
      'user_id': (box.containsKey('id') && box.get('id') != null)
          ? box.get('id').toString()
          : '0',
      'type_id': typeId,
      'type': type,
    };
    await http.post(Uri.parse(ApiEndpoints.reportApi), body: body);
  }
}
