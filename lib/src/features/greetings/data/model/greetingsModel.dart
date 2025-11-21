class GreetingsModel {
  String? id;
  String? catId;
  String? image;
  String? status;
  String? created;
  String? lastUpdatedDateTime;
  String? userName;
  String? userId;

  GreetingsModel({
    this.id,
    this.catId,
    this.image,
    this.status,
    this.created,
    this.lastUpdatedDateTime,
    this.userName,
    this.userId,
  });

  factory GreetingsModel.fromJson(Map<String, dynamic> json) => GreetingsModel(
        id: json['id']?.toString(),
        catId: json['cat_id']?.toString(),
        image: json['image'],
        status: json['status']?.toString(),
        created: json['created'],
        lastUpdatedDateTime: json['last_updated_date_time'],
        userName: json['user_name'],
        userId: json['user_id']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cat_id': catId,
        'image': image,
        'status': status,
        'created': created,
        'last_updated_date_time': lastUpdatedDateTime,
        'user_name': userName,
        'user_id': userId,
      };
}
