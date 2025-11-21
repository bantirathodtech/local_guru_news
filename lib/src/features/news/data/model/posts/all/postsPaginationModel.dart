import 'package:flutter/foundation.dart';

import 'package:local_guru_all/src/features/news/data/model/posts/all/posts_Model.dart';
import 'package:local_guru_all/src/features/news/data/repository/post/post_engagement_repository.dart';

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
      posts: posts, // No changes here as posts are being passed as is.
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  //  ----------update views Count
  PostsPagination postViews(String id, String views, int index) {
    if (posts != null && index >= 0 && index < posts!.length) {
      PostEngagementRepository.instance.incrementView(id);
      posts![index].views = (int.parse(views) + 1).toString();
    }
    return PostsPagination(
      posts: posts,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  // -----------Update Likes Count
  // Note: This method updates state optimistically and triggers API call
  // The API endpoint is: add_likes_api.php
  // Parameters: user_id, type_id, type, like
  PostsPagination likes(int id, String type, int like, int index) {
    if (posts != null && index >= 0 && index < posts!.length) {
      // Trigger API call to add_likes_api.php (fire and forget - optimistic update)
      PostEngagementRepository.instance.react(
        typeId: id.toString(),
        type: type,
        like: like,
      );

      // Create a new list to ensure state change detection
      final updatedPosts = List<PostsModel>.from(posts!);
      final post = updatedPosts[index];

      // Update like state based on current state and action
      // User Liked
      if (like == 1 && post.liked == '0') {
        post.liked = '1';
        final currentLikes = int.tryParse(post.likes ?? '0') ?? 0;
        post.likes = (currentLikes + 1).toString();
      }
      // User Already Liked - Toggle off
      else if (like == 1 && post.liked == '1') {
        post.liked = '0';
        final currentLikes = int.tryParse(post.likes ?? '0') ?? 0;
        post.likes = (currentLikes > 0 ? currentLikes - 1 : 0).toString();
      }
      // User Already Disliked Want to Like
      else if (like == 1 && post.liked == '-1') {
        post.liked = '1';
        final currentLikes = int.tryParse(post.likes ?? '0') ?? 0;
        final currentDislikes = int.tryParse(post.dislikes ?? '0') ?? 0;
        post.likes = (currentLikes + 1).toString();
        post.dislikes =
            (currentDislikes > 0 ? currentDislikes - 1 : 0).toString();
      }
      // User Disliked
      else if (like == -1 && post.liked == '0') {
        post.liked = '-1';
        final currentDislikes = int.tryParse(post.dislikes ?? '0') ?? 0;
        post.dislikes = (currentDislikes + 1).toString();
      }
      // User Already Disliked - Toggle off
      else if (like == -1 && post.liked == '-1') {
        post.liked = '0';
        final currentDislikes = int.tryParse(post.dislikes ?? '0') ?? 0;
        post.dislikes =
            (currentDislikes > 0 ? currentDislikes - 1 : 0).toString();
      }
      // User Already Liked Want to DisLike
      else if (like == -1 && post.liked == '1') {
        post.liked = '-1';
        final currentLikes = int.tryParse(post.likes ?? '0') ?? 0;
        final currentDislikes = int.tryParse(post.dislikes ?? '0') ?? 0;
        post.likes = (currentLikes > 0 ? currentLikes - 1 : 0).toString();
        post.dislikes = (currentDislikes + 1).toString();
      }

      return PostsPagination(
        posts: updatedPosts,
        page: this.page,
        errorMessage: this.errorMessage,
      );
    }
    return PostsPagination(
      posts: posts,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  // -------------- update Whats Share count

  PostsPagination whatsShare(String id, String share, int index) {
    if (posts != null &&
        posts!.isNotEmpty &&
        index >= 0 &&
        index < posts!.length) {
      // Ensure the post at index is non-null before accessing it.
      PostEngagementRepository.instance.incrementShare(id);
      posts![index].whatsApp = (int.parse(share) + 1).toString();
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
