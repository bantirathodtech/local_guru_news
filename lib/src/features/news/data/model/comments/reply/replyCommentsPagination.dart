import 'package:flutter/foundation.dart';
import 'package:local_guru_all/src/features/news/data/model/comments/all/commentsModel.dart';
import 'package:local_guru_all/src/features/news/data/repository/post/post_engagement_repository.dart';

class ReplyCommentsPagination {
  final List<ReplyComments>? comments;
  final int? page;
  final String? errorMessage;

  ReplyCommentsPagination({
    this.comments,
    this.page,
    this.errorMessage,
  });

  ReplyCommentsPagination.initial()
      : comments = [],
        page = 1,
        errorMessage = '';

  bool get refreshError => errorMessage != '' && comments!.length <= 10;

  ReplyCommentsPagination copyWith({
    List<ReplyComments>? comments,
    int? page,
    String? errorMessage,
  }) {
    return ReplyCommentsPagination(
      comments: comments ?? this.comments,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

// Enter new Comment
  ReplyCommentsPagination replyComment({
    List<ReplyComments>? comments,
  }) {
    return ReplyCommentsPagination(
      comments: comments ?? this.comments,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  // -----------Update Likes Count
  ReplyCommentsPagination likes(
      int id, String type, int like, int index, int replyIndex) {
    // User Liked
    if (like == 1 && comments![index].liked! == '0') {
      PostEngagementRepository.instance.react(
        typeId: id.toString(),
        type: type,
        like: like,
      );
      comments![index].liked = '1';
      comments![index].likes =
          (int.parse(comments![index].likes!) + 1).toString();
    }
    // User Already Liked
    else if (like == 1 && comments![index].liked! == '1') {
      PostEngagementRepository.instance.react(
        typeId: id.toString(),
        type: type,
        like: like,
      );
      comments![index].liked = '0';
      comments![index].likes =
          (int.parse(comments![index].likes!) - 1).toString();
    }
    // User Already Disliked Want to Like
    else if (like == 1 && comments![index].liked! == '-1') {
      PostEngagementRepository.instance.react(
        typeId: id.toString(),
        type: type,
        like: like,
      );
      comments![index].liked = '1';
      comments![index].likes =
          (int.parse(comments![index].likes!) + 1).toString();
      comments![index].dislikes =
          (int.parse(comments![index].dislikes!) - 1).toString();
    }

    // User Disliked
    else if (like == -1 && comments![index].liked == '0') {
      PostEngagementRepository.instance.react(
        typeId: id.toString(),
        type: type,
        like: like,
      );
      comments![index].liked = '-1';
      comments![index].dislikes =
          (int.parse(comments![index].dislikes!) + 1).toString();
    }
    // User Already Disliked
    else if (like == -1 && comments![index].liked == '-1') {
      PostEngagementRepository.instance.react(
        typeId: id.toString(),
        type: type,
        like: like,
      );
      comments![index].liked = '0';
      comments![index].dislikes =
          (int.parse(comments![index].dislikes!) - 1).toString();
    }
    // User Already Liked Want to DisLike
    else if (like == -1 && comments![index].liked == '1') {
      PostEngagementRepository.instance.react(
        typeId: id.toString(),
        type: type,
        like: like,
      );
      comments![index].liked = '-1';
      comments![index].dislikes =
          (int.parse(comments![index].dislikes!) + 1).toString();
      comments![index].likes =
          (int.parse(comments![index].likes!) - 1).toString();
    }
    return ReplyCommentsPagination(
      comments: comments,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  @override
  String toString() =>
      'ReplyCommentsPagination(comments: $comments, page: $page, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ReplyCommentsPagination &&
        listEquals(o.comments, comments) &&
        o.page == page &&
        o.errorMessage == errorMessage;
  }

  @override
  int get hashCode => comments.hashCode ^ page.hashCode ^ errorMessage.hashCode;
}
