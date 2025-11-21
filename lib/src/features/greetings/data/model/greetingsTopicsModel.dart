class GreetingsTopics {
  String? id;
  String? category;
  String? status;
  String? created;
  String? lastUpdatedDateTime;

  GreetingsTopics({
    this.id,
    this.category,
    this.status,
    this.created,
    this.lastUpdatedDateTime,
  });

  factory GreetingsTopics.fromJson(Map<String, dynamic> json) =>
      GreetingsTopics(
        id: json['id']?.toString(),
        category: json['category'],
        status: json['status']?.toString(),
        created: json['created'],
        lastUpdatedDateTime: json['last_updated_date_time'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'status': status,
        'created': created,
        'last_updated_date_time': lastUpdatedDateTime,
      };
}
