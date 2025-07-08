class TopicsModel {
  String? id;
  String? name;
  String? icon;
  String? type;

  TopicsModel({
    this.id,
    this.name,
    this.icon,
    this.type,
  });

  factory TopicsModel.fromJson(Map<String, dynamic> json) => TopicsModel(
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
        'type': type,
      };
}
