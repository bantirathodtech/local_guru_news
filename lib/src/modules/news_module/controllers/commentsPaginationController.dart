import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final postid = StateProvider<String>((ref) => '0');

final commentsPaginationControllerProvider =
    StateNotifierProvider<CommentsPaginationController, CommentsPagination>(
        (ref) {
  final getPostId = ref.watch(postid);
  final commentServiceProvider = ref.read(commentsServiceProvider);
  return CommentsPaginationController(commentServiceProvider, getPostId);
});

class CommentsPaginationController extends StateNotifier<CommentsPagination> {
  final CommentsService _commentsService;
  final String _postId;

  CommentsPaginationController(
    this._commentsService,
    this._postId, [
    CommentsPagination? state,
  ]) : super(state ?? CommentsPagination.initial()) {
    getComments();
  }

  // -----Fetch Posts
  Future<void> getComments() async {
    try {
      final comments = await _commentsService.getComments(state.page!, _postId);
      state = state.copyWith(
        comments: [
          ...state.comments!,
          ...comments,
        ],
        page: state.page! + 1,
      );
    } on ErrorExceptionHandler catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

  // New Comment
  Future<void> newComment(
    String message,
  ) async {
    try {
      final comments = await DatabaseService().newComment(
        _postId,
        0,
        0,
        message,
      );
      state = state.newComment(comments: [
        ...state.comments!,
        CommentsModel(
          id: comments.first.id,
          dislikes: comments.first.dislikes,
          commentData: comments.first.commentData,
          commentDate: comments.first.commentDate,
          liked: comments.first.liked,
          likes: comments.first.likes,
          username: comments.first.username,
          userImage: comments.first.userImage,
          replyCount: comments.first.replyCount,
          replyId: comments.first.replyId,
        )
      ]);
    } on ErrorExceptionHandler catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

  // --------------Update Comments Count
  Future<void> commentsCount(int index) async {
    state = state.commentCount(index);
  }

  // Update Likes/Dislikes
  Future<void> likes(
      int id, String type, int like, int index, int replyIndex) async {
    state = state.likes(id, type, like, index, replyIndex);
  }

  void handleScrollWithIndex(int index) {
    final itemPosition = index + 1;
    final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
    final pageToRequest = itemPosition ~/ 10;

    if (requestMoreData && pageToRequest + 1 >= state.page!) {
      getComments();
    }
  }
}
