import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final listsPaginationControllerProvider =
    StateNotifierProvider<ListPaginationController, ListsPostPagination>((ref) {
  final listRepository = ref.watch(listServiceProvider);
  final topicId = ref.watch(listTopicId);
  return ListPaginationController(listRepository, topicId);
});

class ListPaginationController extends StateNotifier<ListsPostPagination> {
  ListPaginationController(
    this._listsRepository,
    this._topicId, [
    ListsPostPagination? state,
  ]) : super(state ?? ListsPostPagination.initial()) {
    getPosts();
  }

  final ListsRepository _listsRepository;
  final String _topicId;

  Future<void> getPosts() async {
    try {
      final posts = await _listsRepository.getPosts(
        page: state.page ?? 1,
        topicId: _topicId,
      );

      state = state.copyWith(
        posts: [
          ...state.posts ?? const [],
          ...posts,
        ],
        page: (state.page ?? 1) + 1,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> resetPosts() async {
    state = state.clearPosts();
  }

  Future<void> refreshPost(String postId, int index) async {
    state = state.refreshPost(postId, index);
  }

  void handleScrollWithIndex(int index) {
    final itemPosition = index + 1;
    final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
    final pageToRequest = itemPosition ~/ 10;

    if (requestMoreData && pageToRequest + 1 >= (state.page ?? 1)) {
      getPosts();
    }
  }
}
