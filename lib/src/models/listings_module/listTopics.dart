class ListsTopics {
  ListsTopics({
    this.id,
    this.category,
    this.icon,
  });

  String? id;
  String? category;
  String? icon;

  factory ListsTopics.fromJson(Map<String, dynamic> json) => ListsTopics(
        id: json["id"],
        category: json["category"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category": category,
        "icon": icon,
      };
}
