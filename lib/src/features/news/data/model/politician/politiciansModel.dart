import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_guru_all/src/features/news/data/model/politician/politicians_Model.dart';

import '../../../../../src.dart';

class PoliticiansModelProvider {
  final List<PoliticianModel>? politicians;
  final String? errorMessage;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String searchQuery;

  Box<String> box = Hive.box('user');

  PoliticiansModelProvider({
    this.politicians,
    this.errorMessage,
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.searchQuery = '',
  });

  PoliticiansModelProvider.initial()
      : politicians = [],
        errorMessage = '',
        isLoading = false,
        hasMore = true,
        currentPage = 0,
        searchQuery = '';

  bool get refreshError => errorMessage != '' && politicians!.length <= 10;

  PoliticiansModelProvider copyWith({
    List<PoliticianModel>? politicians,
    String? errorMessage,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
  }) {
    return PoliticiansModelProvider(
      politicians: politicians ?? this.politicians,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  // ------------------Clear Data
  PoliticiansModelProvider resetPoliticians() {
    return PoliticiansModelProvider.initial();
  }

  // ------------------Update Status
  PoliticiansModelProvider updateStatus({
    String? errorMessage,
  }) {
    return PoliticiansModelProvider(
      politicians: politicians ?? this.politicians,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading,
      hasMore: hasMore,
      currentPage: currentPage,
      searchQuery: searchQuery,
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
      'PoliticiansModelProvider(politicians: $politicians, errorMessage: $errorMessage, isLoading: $isLoading, hasMore: $hasMore, currentPage: $currentPage, searchQuery: $searchQuery)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is PoliticiansModelProvider &&
        listEquals(o.politicians, politicians) &&
        o.errorMessage == errorMessage &&
        o.isLoading == isLoading &&
        o.hasMore == hasMore &&
        o.currentPage == currentPage &&
        o.searchQuery == searchQuery;
  }

  @override
  int get hashCode =>
      politicians.hashCode ^
      errorMessage.hashCode ^
      isLoading.hashCode ^
      hasMore.hashCode ^
      currentPage.hashCode ^
      searchQuery.hashCode;
}
