import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final listSearchPaginationControllerProvider = StateNotifierProvider<
    ListSearchPaginationController, ListsSearchPostPagination>((ref) {
  final listPostService = ref.watch(listSearchServiceProvider);
  return ListSearchPaginationController(listPostService, '');
});

class ListSearchPaginationController
    extends StateNotifier<ListsSearchPostPagination> {
  final ListSearchService _postService;
  final String search;

  ListSearchPaginationController(
    this._postService,
    this.search, [
    ListsSearchPostPagination? state,
  ]) : super(state ?? ListsSearchPostPagination.initial()) {
    resetPosts();
  }

  // -----Fetch Posts
  Future<void> getPosts(String search) async {
    try {
      final posts = await _postService.getPosts(
        state.page!,
        search,
      );
      state = state.copyWith(
        posts: [
          ...state.posts!,
          ...posts,
        ],
        page: state.page! + 1,
      );
    } on ErrorExceptionHandler catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

// -------Reset Posts
  Future<void> resetPosts() async {
    state = state.clearPosts();
  }

  // ---------Refresh Posts
  Future<void> refreshPost() async {
    state = state.refreshPost();
  }

  void handleScrollWithIndex(int index) {
    final itemPosition = index + 1;
    final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
    final pageToRequest = itemPosition ~/ 10;

    if (requestMoreData && pageToRequest + 1 >= state.page!) {
      getPosts(search);
    }
  }
}
