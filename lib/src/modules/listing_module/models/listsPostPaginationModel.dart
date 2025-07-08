import 'package:flutter/foundation.dart';

import '../../../src.dart';

class ListsPostPagination {
  final List<ListsPosts>? posts;
  final int? page;
  final String? errorMessage;

  ListsPostPagination({
    this.posts,
    this.page,
    this.errorMessage,
  });

  ListsPostPagination.initial()
      : posts = [],
        page = 1,
        errorMessage = '';

  bool get refreshError => errorMessage != '' && posts!.length <= 10;

  ListsPostPagination copyWith({
    List<ListsPosts>? posts,
    int? page,
    String? errorMessage,
  }) {
    return ListsPostPagination(
      posts: posts ?? this.posts,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ------------------Clear Data
  ListsPostPagination clearPosts({
    List<ListsPosts>? posts,
    int? page,
    String? errorMessage,
  }) {
    return ListsPostPagination(
      posts: [],
      page: 1,
      errorMessage: '',
    );
  }

  // ------------Refresh Data
  ListsPostPagination refreshPost(String id, int index) {
    return ListsPostPagination(
      posts: posts,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  @override
  String toString() =>
      'ListsPostPagination(posts: $posts, page: $page, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ListsPostPagination &&
        listEquals(o.posts, posts) &&
        o.page == page &&
        o.errorMessage == errorMessage;
  }

  @override
  int get hashCode => posts.hashCode ^ page.hashCode ^ errorMessage.hashCode;
}
