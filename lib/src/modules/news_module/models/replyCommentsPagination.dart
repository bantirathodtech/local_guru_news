import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../src.dart';

class ReplyCommentsPagination {
  final List<ReplyComments>? comments;
  final int? page;
  final String? errorMessage;

  Box<String> box = Hive.box('user');

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
      DatabaseService().like(id.toString(), type, '1');
      comments![index].liked = '1';
      comments![index].likes =
          (int.parse(comments![index].likes!) + 1).toString();
    }
    // User Already Liked
    else if (like == 1 && comments![index].liked! == '1') {
      DatabaseService().like(id.toString(), type, '0');
      comments![index].liked = '0';
      comments![index].likes =
          (int.parse(comments![index].likes!) - 1).toString();
    }
    // User Already Disliked Want to Like
    else if (like == 1 && comments![index].liked! == '-1') {
      DatabaseService().like(id.toString(), type, '1');
      comments![index].liked = '1';
      comments![index].likes =
          (int.parse(comments![index].likes!) + 1).toString();
      comments![index].dislikes =
          (int.parse(comments![index].dislikes!) - 1).toString();
    }

    // User Disliked
    else if (like == -1 && comments![index].liked == '0') {
      DatabaseService().like(id.toString(), type, '-1');
      comments![index].liked = '-1';
      comments![index].dislikes =
          (int.parse(comments![index].dislikes!) + 1).toString();
    }
    // User Already Disliked
    else if (like == -1 && comments![index].liked == '-1') {
      DatabaseService().like(id.toString(), type, '0');
      comments![index].liked = '0';
      comments![index].dislikes =
          (int.parse(comments![index].dislikes!) - 1).toString();
    }
    // User Already Liked Want to DisLike
    else if (like == -1 && comments![index].liked == '1') {
      DatabaseService().like(id.toString(), type, '-1');
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
