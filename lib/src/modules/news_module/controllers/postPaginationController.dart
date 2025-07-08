import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final postPaginationControllerProvider =
    StateNotifierProvider<PostPaginationController, PostsPagination>((ref) {
  final getTopicID = ref.watch(topicId);
  final postService = ref.read(postServiceProvider);
  final getTopicType = ref.read(topicType);
  return PostPaginationController(postService, getTopicID, getTopicType);
});

class PostPaginationController extends StateNotifier<PostsPagination> {
  final PostService _postService;
  final String _topicId;
  final String _topicType;

  PostPaginationController(
    this._postService,
    this._topicId,
    this._topicType, [
    PostsPagination? state,
  ]) : super(state ?? PostsPagination.initial()) {
    getPosts();
  }

  // -----Fetch Posts

  Future<void> getPosts() async {
    try {
      final currentPage = state.page ?? 0;

      final posts = await _postService.getPosts(currentPage, _topicId, _topicType);

     if (!mounted) return;

      state = state.copyWith(
        posts: [
          ...state.posts ?? [], // Use empty list if state.posts is null.
          ...posts,
        ],
        page: currentPage + 1, // Increment page number
      );
    } on ErrorExceptionHandler catch (e) {
      if (!mounted) return;

      state = state.copyWith(errorMessage: e.message);
    }
  }



  // Future<void> getPosts() async {
  //   try {
  //     final posts =
  //         await _postService.getPosts(state.page!, _topicId, _topicType);
  //     state = state.copyWith(
  //       posts: [
  //         ...state.posts!,
  //         ...posts,
  //       ],
  //       page: state.page! + 1,
  //     );
  //   } on ErrorExceptionHandler catch (e) {
  //     state = state.copyWith(errorMessage: e.message);
  //   }
  // }


// -------Reset Posts
  Future<void> resetPosts() async {
    state = state.clearPosts();
  }

  // ---------Refresh Posts
  Future<void> refreshPost(String postId, int index) async {
    state = state.refreshPost(postId, index);
  }

  // -------------Update Post View Count
  Future<void> postViews(String id, String views, int index) async {
    state = state.postViews(id, views, index);
  }

  // Update Likes/Dislikes
  Future<void> likes(int id, String type, int like, int index) async {
    state = state.likes(id, type, like, index);
  }

  // --------------Update Whats Share Count
  Future<void> whatsShare(String id, String share, int index) async {
    state = state.whatsShare(id, share, index);
  }

  // --------------Update Comments Count
  Future<void> commentsCount(int index) async {
    state = state.commentCount(index);
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
