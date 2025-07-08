import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final topicsGreetingsControllerProvider = StateNotifierProvider<
    GreetingsTopicsController, GreetingsTopicsModelProvider>((ref) {
  final getTopicsServiceProvider = ref.read(greetingsTopicsServiceProvider);
  final getTopicId = ref.read(greetingTopicId.notifier).state;
  return GreetingsTopicsController(getTopicsServiceProvider, getTopicId);
});

class GreetingsTopicsController
    extends StateNotifier<GreetingsTopicsModelProvider> {
  final GreetingsTopicsService _topicsService;
  final String topicId;

  GreetingsTopicsController(
    this._topicsService,
    this.topicId, [
    GreetingsTopicsModelProvider? state,
  ]) : super(state ?? GreetingsTopicsModelProvider.initial()) {
    getTopics();
  }

  // -----Fetch Posts
  Future<void> getTopics() async {
    try {
      final topics = await _topicsService.getGreetings();
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
}
