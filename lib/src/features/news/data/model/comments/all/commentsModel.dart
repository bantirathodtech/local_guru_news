class CommentsModel {
  String? id;
  String? replyId;
  String? userId;
  String? username;
  String? userImage;
  String? commentData;
  String? commentDate;
  String? likes;
  String? dislikes;
  String? liked;
  String? replyCount;

  CommentsModel({
    this.id,
    this.replyId,
    this.userId,
    this.username,
    this.userImage,
    this.commentData,
    this.commentDate,
    this.likes,
    this.dislikes,
    this.liked,
    this.replyCount,
  });

  factory CommentsModel.fromJson(Map<String, dynamic> json) {
    return CommentsModel(
      id: json['id'],
      replyId: json['reply_id'],
      userId: json['user_id'],
      username: json['user_name'],
      userImage: json['user_image'],
      commentData: json['comment_data'],
      commentDate: json['comment_date'],
      likes: json['likes'],
      dislikes: json['dislikes'],
      liked: json['liked'],
      replyCount: json['reply_count'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reply_id': replyId,
        'user_id': userId,
        'user_name': username,
        'user_image': userImage,
        'comment_data': commentData,
        'comment_date': commentDate,
        'likes': likes,
        'dislikes': dislikes,
        'liked': liked,
        'reply_count': replyCount,
      };
}

class ReplyComments {
  String? id;
  String? replyId;
  String? userId;
  String? username;
  String? userImage;
  String? repliedUserName;
  String? commentData;
  String? commentDate;
  String? likes;
  String? dislikes;
  String? liked;

  ReplyComments({
    this.id,
    this.replyId,
    this.userId,
    this.username,
    this.userImage,
    this.repliedUserName,
    this.commentData,
    this.commentDate,
    this.likes,
    this.dislikes,
    this.liked,
  });

  factory ReplyComments.fromJson(Map<String, dynamic> json) {
    return ReplyComments(
      id: json['id'],
      replyId: json['reply_id'],
      userId: json['user_id'],
      username: json['user_name'],
      userImage: json['user_image'],
      repliedUserName: json['replied_user'],
      commentData: json['comment_data'],
      commentDate: json['comment_date'],
      likes: json['likes'],
      dislikes: json['dislikes'],
      liked: json['liked'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reply_id': replyId,
        'user_id': userId,
        'user_name': username,
        'user_image': userImage,
        'replied_user': repliedUserName,
        'comment_data': commentData,
        'comment_date': commentDate,
        'likes': likes,
        'dislikes': dislikes,
        'liked': liked,
      };
}
