import 'package:flutter/foundation.dart';

import '../../../src.dart';

class PostsPagination {
  final List<PostsModel>? posts;
  final int? page;
  final String? errorMessage;

  PostsPagination({
    this.posts,
    this.page,
    this.errorMessage,
  });

  PostsPagination.initial()
      : posts = [],
        page = 1,
        errorMessage = '';

  bool get refreshError => errorMessage != '' && (posts?.length ?? 0) <= 10;

  PostsPagination copyWith({
    List<PostsModel>? posts,
    int? page,
    String? errorMessage,
  }) {
    return PostsPagination(
      posts: posts ?? this.posts,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ------------------Clear Data
  PostsPagination clearPosts({
    List<PostsModel>? posts,
    int? page,
    String? errorMessage,
  }) {
    return PostsPagination(
      posts: [],
      page: 1,
      errorMessage: '',
    );
  }

  // ------------Refresh Data
  PostsPagination refreshPost(String id, int index) {
    return PostsPagination(
      posts: posts,  // No changes here as posts are being passed as is.
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  //  ----------update views Count
  PostsPagination postViews(String id, String views, int index) {
    if (posts != null && index >= 0 && index < posts!.length) {
      DatabaseService.updateViewCount(id);
      posts![index].views = (int.parse(views) + 1).toString();
    }
    return PostsPagination(
      posts: posts,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  // -----------Update Likes Count
  PostsPagination likes(int id, String type, int like, int index) {
    if (posts != null && index >= 0 && index < posts!.length) {
      // User Liked
      if (like == 1 && posts![index].liked == '0') {
        DatabaseService().like(id.toString(), type, '1');
        posts![index].liked = '1';
        posts![index].likes = (int.parse(posts![index].likes!) + 1).toString();
      }
      // User Already Liked
      else if (like == 1 && posts![index].liked == '1') {
        DatabaseService().like(id.toString(), type, '0');
        posts![index].liked = '0';
        posts![index].likes = (int.parse(posts![index].likes!) - 1).toString();
      }
      // User Already Disliked Want to Like
      else if (like == 1 && posts![index].liked == '-1') {
        DatabaseService().like(id.toString(), type, '1');
        posts![index].liked = '1';
        posts![index].likes = (int.parse(posts![index].likes!) + 1).toString();
        posts![index].dislikes =
            (int.parse(posts![index].dislikes!) - 1).toString();
      }

      // User Disliked
      else if (like == -1 && posts![index].liked == '0') {
        DatabaseService().like(id.toString(), type, '-1');
        posts![index].liked = '-1';
        posts![index].dislikes =
            (int.parse(posts![index].dislikes!) + 1).toString();
      }
      // User Already Disliked
      else if (like == -1 && posts![index].liked == '-1') {
        DatabaseService().like(id.toString(), type, '0');
        posts![index].liked = '0';
        posts![index].dislikes =
            (int.parse(posts![index].dislikes!) - 1).toString();
      }
      // User Already Liked Want to DisLike
      else if (like == -1 && posts![index].liked == '1') {
        DatabaseService().like(id.toString(), type, '-1');
        posts![index].liked = '-1';
        posts![index].dislikes =
            (int.parse(posts![index].dislikes!) + 1).toString();
        posts![index].likes = (int.parse(posts![index].likes!) - 1).toString();
      }
    }
    return PostsPagination(
      posts: posts,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  // -------------- update Whats Share count

  PostsPagination whatsShare(String id, String share, int index) {
    if (posts != null && posts!.isNotEmpty && index >= 0 && index < posts!.length) {
      // Ensure the post at index is non-null before accessing it.
      if (posts![index] != null) {
        DatabaseService.updateShareCount(id);
        posts![index].whatsApp = (int.parse(share) + 1).toString();
      } else {
        // Handle the case where the post at the given index is null, if necessary.
        print('Post at index $index is null');
      }
    } else {
      // Handle the case where posts is null or the index is out of bounds.
      print('Posts list is null or index is out of bounds');
    }

    return PostsPagination(
      posts: posts,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }


  // -------------------Update Comment Count
  PostsPagination commentCount(int index) {
    if (posts != null && index >= 0 && index < posts!.length) {
      posts![index].comments =
          (int.parse(posts![index].comments!) + 1).toString();
    }
    return PostsPagination(
      posts: posts,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  @override
  String toString() =>
      'PostsPagination(posts: $posts, page: $page, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is PostsPagination &&
        listEquals(o.posts, posts) &&
        o.page == page &&
        o.errorMessage == errorMessage;
  }

  @override
  int get hashCode => posts.hashCode ^ page.hashCode ^ errorMessage.hashCode;
}
