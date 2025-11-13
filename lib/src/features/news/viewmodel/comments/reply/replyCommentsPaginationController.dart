import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/features/news/data/model/comments/all/commentsModel.dart';
import 'package:local_guru_all/src/features/news/data/model/comments/reply/replyCommentsPagination.dart';
import 'package:local_guru_all/src/features/news/data/repository/comments/reply/replyCommentsPaginationService.dart';
import 'package:local_guru_all/src/features/news/data/repository/post/post_engagement_repository.dart';

final commentId = StateProvider<String>((ref) => '0');
final commentPostId = StateProvider<String>((ref) => '0');

final replyCommentsPaginationControllerProvider = StateNotifierProvider<
    ReplyCommentsPaginationController, ReplyCommentsPagination>((ref) {
  final commentIdentifier = ref.watch(commentId);
  final postIdentifier = ref.watch(commentPostId);
  final replyCommentsRepository = ref.read(replyCommentsServiceProvider);
  return ReplyCommentsPaginationController(
    replyCommentsRepository,
    commentIdentifier,
    postIdentifier,
  );
});

class ReplyCommentsPaginationController
    extends StateNotifier<ReplyCommentsPagination> {
  ReplyCommentsPaginationController(
    this._commentsRepository,
    this._commentId,
    this._postId, [
    ReplyCommentsPagination? state,
  ]) : super(state ?? ReplyCommentsPagination.initial()) {
    getComments();
  }

  final ReplyCommentsRepository _commentsRepository;
  final String _commentId;
  final String _postId;

  Future<void> getComments() async {
    try {
      final comments = await _commentsRepository.getComments(
        page: state.page ?? 1,
        replyId: _commentId,
        postId: _postId,
      );
      state = state.copyWith(
        comments: [
          ...state.comments ?? const [],
          ...comments,
        ],
        page: (state.page ?? 1) + 1,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Reply Comment
  Future<void> replyComment(
    int replyId,
    int userReplyId,
    String message,
  ) async {
    try {
      final comments = await PostEngagementRepository.instance.addComment(
        postId: _postId,
        message: message,
        replyId: replyId,
        replyUserId: userReplyId,
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
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
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
