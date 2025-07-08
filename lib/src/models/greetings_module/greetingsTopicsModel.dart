class GreetingsTopics {
  String? id;
  String? category;

  GreetingsTopics({
    this.id,
    this.category,
  });

  factory GreetingsTopics.fromJson(Map<String, dynamic> json) =>
      GreetingsTopics(
        id: json['id'],
        category: json['category'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
      };
}
