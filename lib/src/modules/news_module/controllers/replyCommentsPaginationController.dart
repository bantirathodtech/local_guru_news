import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final commentId = StateProvider<String>((ref) => '0');
final commentPostId = StateProvider<String>((ref) => '0');

final replyCommentsPaginationControllerProvider = StateNotifierProvider<
    ReplyCommentsPaginationController, ReplyCommentsPagination>((ref) {
  final getCommentId = ref.watch(commentId);
  final getPostid = ref.watch(commentPostId);
  final replyCommentServiceProvider = ref.read(replyCommentsServiceProvider);
  return ReplyCommentsPaginationController(
      replyCommentServiceProvider, getCommentId, getPostid);
});

class ReplyCommentsPaginationController
    extends StateNotifier<ReplyCommentsPagination> {
  final ReplyCommentsService _commentsService;
  final String _commentId;
  final String _postId;

  ReplyCommentsPaginationController(
    this._commentsService,
    this._commentId,
    this._postId, [
    ReplyCommentsPagination? state,
  ]) : super(state ?? ReplyCommentsPagination.initial()) {
    getComments();
  }

  // -----Fetch Posts
  Future<void> getComments() async {
    try {
      final comments =
          await _commentsService.getComments(state.page!, _commentId, _postId);
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

  // Reply Comment
  Future<void> replyComment(
    int replyId,
    int userReplyId,
    String message,
  ) async {
    try {
      final comments = await DatabaseService().newComment(
        _postId,
        replyId,
        userReplyId,
        message,
      );
      state = state.replyComment(comments: [
        ...state.comments!,
        ReplyComments(
          id: comments.first.id,
          dislikes: comments.first.dislikes,
          commentData: comments.first.commentData,
          commentDate: comments.first.commentDate,
          liked: comments.first.liked,
          likes: comments.first.likes,
          username: comments.first.username,
          userImage: comments.first.userImage,
          replyId: comments.first.replyId,
        )
      ]);
    } on ErrorExceptionHandler catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
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
