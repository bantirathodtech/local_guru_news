import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../src.dart';

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
