import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final topicsControllerProvider =
    StateNotifierProvider<TopicsController, TopicsModelProvider>((ref) {
  final getTopicsServiceProvider = ref.read(topicsServiceProvider);
  final getTopicId = ref.read(topicId);
  return TopicsController(getTopicsServiceProvider, getTopicId);
});

class TopicsController extends StateNotifier<TopicsModelProvider> {
  final TopicsService _topicsService;
  final String topicId;

  TopicsController(
    this._topicsService,
    this.topicId, [
    TopicsModelProvider? state,
  ]) : super(state ?? TopicsModelProvider.initial()) {
    getTopics();
  }

  // -----Fetch Posts
  Future<void> getTopics() async {
    try {
      final topics = await _topicsService.getTopics(topicId);
      state = state.copyWith(
        topics: [
          ...state.topics!,
          ...topics,
        ],
      );
    } on ErrorExceptionHandler catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

// Clear Topics
  Future<void> resetTopics() async {
    state = state.resetTopics();
  }

  // New Topic
  Future<void> newTopic(
    String id,
    String name,
    String type,
    String icon,
  ) async {
    try {
      if (state.topics!.any((element) =>
          element.id == id && element.name == name && element.type == type)) {
        state.topics!.removeWhere((element) =>
            element.id == id && element.name == name && element.type == type);
        state = state.newTopic(
          topics: [
            ...state.topics!,
          ],
        );
      } else {
        state = state.newTopic(
          topics: [
            TopicsModel(
              id: id,
              name: name,
              type: type,
              icon: icon,
            ),
            ...state.topics!,
          ],
        );
      }
    } on ErrorExceptionHandler catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }
}
