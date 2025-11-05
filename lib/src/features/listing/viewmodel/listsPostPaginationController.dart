import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final listsPaginationControllerProvider =
    StateNotifierProvider<ListPaginationController, ListsPostPagination>((ref) {
  final listPostService = ref.watch(listServiceProvider);
  final getTopicID = ref.watch(listTopicId);
  return ListPaginationController(listPostService, getTopicID);
});

class ListPaginationController extends StateNotifier<ListsPostPagination> {
  final ListService _postService;
  final String _topicId;

  ListPaginationController(
    this._postService,
    this._topicId, [
    ListsPostPagination? state,
  ]) : super(state ?? ListsPostPagination.initial()) {
    getPosts();
  }

  // -----Fetch Posts
  Future<void> getPosts() async {
    try {
      final posts = await _postService.getPosts(state.page!, _topicId);
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
  Future<void> refreshPost(String postId, int index) async {
    state = state.refreshPost(postId, index);
  }

  void handleScrollWithIndex(int index) {
    final itemPosition = index + 1;
    final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
    final pageToRequest = itemPosition ~/ 10;

    if (requestMoreData && pageToRequest + 1 >= state.page!) {
      getPosts();
    }
  }
}
