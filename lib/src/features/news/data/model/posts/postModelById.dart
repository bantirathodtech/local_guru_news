class PostsModelByID {
  String? id;
  String? title;
  String? description;
  String? fulldescription;
  String? layout;
  List? media;
  String? channel;
  String? channelImage;
  List? tags;
  String? topic;
  String? editor;
  String? editorProfile;
  String? views;
  String? likes;
  String? dislikes;
  String? liked;
  String? comments;
  String? whatsApp;
  String? time;
  String? readableTime;

  PostsModelByID({
    this.id,
    this.title,
    this.description,
    this.fulldescription,
    this.layout,
    this.media,
    this.channel,
    this.channelImage,
    this.tags,
    this.topic,
    this.editor,
    this.editorProfile,
    this.views,
    this.likes,
    this.dislikes,
    this.liked,
    this.comments,
    this.whatsApp,
    this.time,
    this.readableTime,
  });

  factory PostsModelByID.fromJson(Map<String, dynamic> json) => PostsModelByID(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      fulldescription: json['fulldescription'],
      layout: json['layout'],
      media: json['media'],
      channel: json['channel'],
      channelImage: json['channelImage'],
      tags: json['tags'],
      topic: json['topic'],
      editor: json['editor'],
      editorProfile: json['editor_profile'],
      views: json['views'],
      likes: json['likes'],
      liked: json['liked'],
      comments: json['comments'],
      dislikes: json['dislikes'],
      whatsApp: json['whats_app'],
      time: json['time'],
      readableTime: json['readableTime']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "fulldescription": fulldescription,
        "layout": layout,
        "media": media,
        "channel": channel,
        "channelImage": channelImage,
        'tags': tags,
        "topic": topic,
        "editor": editor,
        'editor_profile': editorProfile,
        "views": views,
        'likes': likes,
        'dislikes': dislikes,
        'liked': liked,
        'comments': comments,
        "whats_app": whatsApp,
        'time': time,
        'readabaleTime': readableTime,
      };
}
