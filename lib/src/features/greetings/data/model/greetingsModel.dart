class GreetingsModel {
  String? id;
  String? catId;
  String? image;

  GreetingsModel({
    this.id,
    this.catId,
    this.image,
  });

  factory GreetingsModel.fromJson(Map<String, dynamic> json) => GreetingsModel(
      id: json['id'], catId: json['cat_id'], image: json['image']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'cat_id': catId,
        'image': image,
      };
}
