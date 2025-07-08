import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../src.dart';

class GreetingsTopicsModelProvider {
  final List<GreetingsTopics>? topics;
  final String? errorMessage;

  Box<String> box = Hive.box('user');

  GreetingsTopicsModelProvider({
    this.topics,
    this.errorMessage,
  });

  GreetingsTopicsModelProvider.initial()
      : topics = [],
        errorMessage = '';

  bool get refreshError => errorMessage != '' && topics!.length <= 10;

  GreetingsTopicsModelProvider copyWith({
    List<GreetingsTopics>? topics,
    String? errorMessage,
  }) {
    return GreetingsTopicsModelProvider(
      topics: topics ?? this.topics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ------------------Clear Data
  GreetingsTopicsModelProvider resetTopics({
    List<GreetingsTopicsModelProvider>? topics,
    String? errorMessage,
  }) {
    return GreetingsTopicsModelProvider(
      topics: [],
      errorMessage: '',
    );
  }

  @override
  String toString() =>
      'GreetingsTopicsModelProvider(topics: $topics, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is GreetingsTopicsModelProvider &&
        listEquals(o.topics, topics) &&
        o.errorMessage == errorMessage;
  }

  @override
  int get hashCode => topics.hashCode ^ errorMessage.hashCode;
}
