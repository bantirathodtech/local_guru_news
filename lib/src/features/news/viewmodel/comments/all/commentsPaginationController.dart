import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_guru_all/src/features/news/data/model/comments/all/commentsModel.dart';
import 'package:local_guru_all/src/features/news/data/model/comments/all/commentsPagination.dart';
import 'package:local_guru_all/src/features/news/data/repository/comments/all/commentsPaginationService.dart';
import 'package:local_guru_all/src/features/news/data/repository/post/post_engagement_repository.dart';

final postid = StateProvider<String>((ref) => '0');

final commentsPaginationControllerProvider =
    StateNotifierProvider<CommentsPaginationController, CommentsPagination>(
        (ref) {
  final postIdValue = ref.watch(postid);
  final commentsRepository = ref.read(commentsServiceProvider);
  return CommentsPaginationController(commentsRepository, postIdValue);
});

class CommentsPaginationController extends StateNotifier<CommentsPagination> {
  CommentsPaginationController(
    this._commentsRepository,
    this._postId, [
    CommentsPagination? state,
  ]) : super(state ?? CommentsPagination.initial()) {
    getComments();
  }

  final CommentsRepository _commentsRepository;
  final String _postId;

  Future<void> getComments() async {
    try {
      final comments = await _commentsRepository.getComments(
        page: state.page ?? 1,
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

  // New Comment
  Future<void> newComment(
    String message,
  ) async {
    try {
      final comments = await PostEngagementRepository.instance.addComment(
        postId: _postId,
        message: message,
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
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
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
