import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../src.dart';

class PoliticiansModelProvider {
  final List<PoliticianModel>? politicians;
  final String? errorMessage;

  Box<String> box = Hive.box('user');

  PoliticiansModelProvider({
    this.politicians,
    this.errorMessage,
  });

  PoliticiansModelProvider.initial()
      : politicians = [],
        errorMessage = '';

  bool get refreshError => errorMessage != '' && politicians!.length <= 10;

  PoliticiansModelProvider copyWith({
    List<PoliticianModel>? politicians,
    String? errorMessage,
  }) {
    return PoliticiansModelProvider(
      politicians: politicians ?? this.politicians,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ------------------Clear Data
  PoliticiansModelProvider resetPoliticians({
    List<PoliticiansModelProvider>? topics,
    String? errorMessage,
  }) {
    return PoliticiansModelProvider(
      politicians: [],
      errorMessage: '',
    );
  }

  // ------------------Update Status
  PoliticiansModelProvider updateStatus({
    List<PoliticiansModelProvider>? topics,
    String? errorMessage,
  }) {
    return PoliticiansModelProvider(
      politicians: politicians ?? this.politicians,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // // Enter new Topic
  // TopicsModelProvider newTopic({
  //   List<TopicsModel>? topics,
  // }) {
  //   return TopicsModelProvider(
  //     topics: topics ?? this.topics,
  //     errorMessage: this.errorMessage,
  //   );
  // }

  @override
  String toString() =>
      'PoliticiansModelProvider(politicians: $politicians, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is PoliticiansModelProvider &&
        listEquals(o.politicians, politicians) &&
        o.errorMessage == errorMessage;
  }

  @override
  int get hashCode => politicians.hashCode ^ errorMessage.hashCode;
}
