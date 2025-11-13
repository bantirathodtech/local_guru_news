import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final listSearchPaginationControllerProvider = StateNotifierProvider<
    ListSearchPaginationController, ListsSearchPostPagination>((ref) {
  final listSearchRepository = ref.watch(listSearchServiceProvider);
  return ListSearchPaginationController(listSearchRepository);
});

class ListSearchPaginationController
    extends StateNotifier<ListsSearchPostPagination> {
  ListSearchPaginationController(
    this._listSearchRepository, [
    ListsSearchPostPagination? state,
  ]) : super(state ?? ListsSearchPostPagination.initial());

  final ListSearchRepository _listSearchRepository;

  Future<void> getPosts(String search) async {
    try {
      final posts = await _listSearchRepository.getPosts(
        page: state.page ?? 1,
        search: search,
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

  Future<void> refreshPost() async {
    state = state.refreshPost();
  }

  void handleScrollWithIndex(int index, String search) {
    final itemPosition = index + 1;
    final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
    final pageToRequest = itemPosition ~/ 10;

    if (requestMoreData && pageToRequest + 1 >= (state.page ?? 1)) {
      getPosts(search);
    }
  }
}