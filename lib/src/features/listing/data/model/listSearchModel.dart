class ListsSearchPosts {
  ListsSearchPosts({
    this.id,
    this.title,
    this.description,
    this.media,
    this.time,
    this.customlocation,
    this.contact,
    this.readableTime,
    this.location,
  });

  String? id;
  String? title;
  String? description;
  List<String>? media;
  DateTime? time;
  String? customlocation;
  String? contact;
  String? readableTime;
  String? location;

  factory ListsSearchPosts.fromJson(Map<String, dynamic> json) =>
      ListsSearchPosts(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        media: List<String>.from(json["media"].map((x) => x)),
        time: DateTime.parse(json["time"]),
        customlocation: json["customlocation"],
        contact: json["contact"],
        readableTime: json["readableTime"],
        location: json["location"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "media": List<dynamic>.from(media!.map((x) => x)),
        "time": time,
        "customlocation": customlocation,
        "contact": contact,
        "readableTime": readableTime,
        "location": location,
      };
}
