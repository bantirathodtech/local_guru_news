import 'package:flutter/foundation.dart';

import '../../../src.dart';

class PostIndividualModel {
  final List<PostsModelByID>? posts;
  final int? id;
  final String? errorMessage;

  PostIndividualModel({
    this.posts,
    this.errorMessage,
    this.id,
  });

  PostIndividualModel.initial()
      : posts = [],
        id = 0,
        errorMessage = '';

  bool get refreshError => errorMessage != '' && posts!.length != 1;

  PostIndividualModel copyWith({
    List<PostsModelByID>? posts,
    String? errorMessage,
  }) {
    return PostIndividualModel(
      posts: posts,
      errorMessage: errorMessage,
    );
  }

  // ------------------Clear Data
  PostIndividualModel clearPosts({
    List<PostsModelByID>? posts,
    String? errorMessage,
  }) {
    return PostIndividualModel(
      posts: [],
      errorMessage: '',
    );
  }

  //  ----------update views Count
  PostIndividualModel postViews(String id, String views, int index) {
    DatabaseService.updateViewCount(id);
    posts![0].views = (int.parse(views) + 1).toString();
    return PostIndividualModel(
      posts: posts,
      errorMessage: this.errorMessage,
    );
  }

  // -----------Update Likes Count
  PostIndividualModel likes(int id, String type, int like, int index) {
    // User Liked
    if (like == 1 && posts![0].liked == '0') {
      DatabaseService().like(id.toString(), type, '1');
      posts![0].liked = '1';
      posts![0].likes = (int.parse(posts![0].likes!) + 1).toString();
    }
    // User Already Liked
    else if (like == 1 && posts![0].liked == '1') {
      DatabaseService().like(id.toString(), type, '0');
      posts![0].liked = '0';
      posts![0].likes = (int.parse(posts![0].likes!) - 1).toString();
    }
    // User Already Disliked Want to Like
    else if (like == 1 && posts![0].liked == '-1') {
      DatabaseService().like(id.toString(), type, '1');
      posts![0].liked = '1';
      posts![0].likes = (int.parse(posts![0].likes!) + 1).toString();
      posts![0].dislikes = (int.parse(posts![0].dislikes!) - 1).toString();
    }

    // User Disliked
    else if (like == -1 && posts![0].liked == '0') {
      DatabaseService().like(id.toString(), type, '-1');
      posts![0].liked = '-1';
      posts![0].dislikes = (int.parse(posts![0].dislikes!) + 1).toString();
    }
    // User Already Disliked
    else if (like == -1 && posts![0].liked == '-1') {
      DatabaseService().like(id.toString(), type, '0');
      posts![0].liked = '0';
      posts![0].dislikes = (int.parse(posts![0].dislikes!) - 1).toString();
    }
    // User Already Liked Want to DisLike
    else if (like == -1 && posts![0].liked == '1') {
      DatabaseService().like(id.toString(), type, '-1');
      posts![0].liked = '-1';
      posts![0].dislikes = (int.parse(posts![0].dislikes!) + 1).toString();
      posts![0].likes = (int.parse(posts![0].likes!) - 1).toString();
    }
    return PostIndividualModel(
      posts: posts,
      errorMessage: this.errorMessage,
    );
  }

  // -------------- update Whats Share count
  PostIndividualModel whatsShare(String id, String share, int index) {
    DatabaseService.updateShareCount(id);
    posts![0].whatsApp = (int.parse(share) + 1).toString();
    return PostIndividualModel(
      posts: posts,
      errorMessage: this.errorMessage,
    );
  }

  // -------------------Update Comment Count
  PostIndividualModel commentCount(int index) {
    posts![index].comments =
        (int.parse(posts![index].comments!) + 1).toString();
    return PostIndividualModel(
      posts: posts,
      errorMessage: this.errorMessage,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is PostIndividualModel &&
        listEquals(o.posts, posts) &&
        o.id == id &&
        o.errorMessage == errorMessage;
  }

  @override
  int get hashCode => posts.hashCode ^ id.hashCode ^ errorMessage.hashCode;
}
