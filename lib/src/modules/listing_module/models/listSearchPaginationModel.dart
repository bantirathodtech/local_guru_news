import 'package:flutter/foundation.dart';

import '../../../src.dart';

class ListsSearchPostPagination {
  final List<ListsSearchPosts>? posts;
  final int? page;
  final String? errorMessage;

  ListsSearchPostPagination({
    this.posts,
    this.page,
    this.errorMessage,
  });

  ListsSearchPostPagination.initial()
      : posts = [],
        page = 1,
        errorMessage = '';

  bool get refreshError => errorMessage != '' && posts!.length <= 10;

  ListsSearchPostPagination copyWith({
    List<ListsSearchPosts>? posts,
    int? page,
    String? errorMessage,
  }) {
    return ListsSearchPostPagination(
      posts: posts ?? this.posts,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ------------------Clear Data
  ListsSearchPostPagination clearPosts({
    List<ListsSearchPosts>? posts,
    int? page,
    String? errorMessage,
  }) {
    return ListsSearchPostPagination(
      posts: [],
      page: 1,
      errorMessage: '',
    );
  }

  // ------------Refresh Data
  ListsSearchPostPagination refreshPost() {
    return ListsSearchPostPagination(
      posts: posts,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  @override
  String toString() =>
      'ListsSearchPostPagination(posts: $posts, page: $page, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ListsSearchPostPagination &&
        listEquals(o.posts, posts) &&
        o.page == page &&
        o.errorMessage == errorMessage;
  }

  @override
  int get hashCode => posts.hashCode ^ page.hashCode ^ errorMessage.hashCode;
}
