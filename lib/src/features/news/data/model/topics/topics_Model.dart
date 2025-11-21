import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// TopicsModel - Data model for a single topic
/// Based on API response: { "id": "1", "name": "క్రీడలు", "icon": "https://..." }
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
        id: json['id']?.toString(),
        name: json['name']?.toString(),
        icon: json['icon']?.toString(),
        type: json['type']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
        'type': type,
      };
}

/// TopicsModelProvider - State provider for topics list
class TopicsModelProvider {
  final List<TopicsModel>? topics;
  final String? errorMessage;

  Box<String> box = Hive.box('user');

  TopicsModelProvider({
    this.topics,
    this.errorMessage,
  });

  TopicsModelProvider.initial()
      : topics = [],
        errorMessage = '';

  bool get refreshError => errorMessage != '' && topics!.length <= 10;

  TopicsModelProvider copyWith({
    List<TopicsModel>? topics,
    String? errorMessage,
  }) {
    return TopicsModelProvider(
      topics: topics ?? this.topics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ------------------Clear Data
  TopicsModelProvider resetTopics({
    List<TopicsModelProvider>? topics,
    String? errorMessage,
  }) {
    return TopicsModelProvider(
      topics: [],
      errorMessage: '',
    );
  }

  // Enter new Topic
  TopicsModelProvider newTopic({
    List<TopicsModel>? topics,
  }) {
    return TopicsModelProvider(
      topics: topics ?? this.topics,
      errorMessage: this.errorMessage,
    );
  }

  @override
  String toString() =>
      'TopicsModelProvider(topics: $topics, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is TopicsModelProvider &&
        listEquals(o.topics, topics) &&
        o.errorMessage == errorMessage;
  }

  @override
  int get hashCode => topics.hashCode ^ errorMessage.hashCode;
}
