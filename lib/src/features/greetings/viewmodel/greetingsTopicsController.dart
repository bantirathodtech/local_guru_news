import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final topicsGreetingsControllerProvider = StateNotifierProvider<
    GreetingsTopicsController, GreetingsTopicsModelProvider>((ref) {
  final topicsRepository = ref.watch(greetingsTopicsServiceProvider);
  return GreetingsTopicsController(topicsRepository);
});

class GreetingsTopicsController
    extends StateNotifier<GreetingsTopicsModelProvider> {
  GreetingsTopicsController(
    this._topicsRepository, [
    GreetingsTopicsModelProvider? state,
  ]) : super(state ?? GreetingsTopicsModelProvider.initial()) {
    getTopics();
  }

  final GreetingsTopicsRepository _topicsRepository;

  Future<void> getTopics() async {
    try {
      final topics = await _topicsRepository.getGreetings();
      state = state.copyWith(
        topics: [
          ...state.topics ?? const [],
          ...topics,
        ],
      );
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> resetTopics() async {
    state = state.resetTopics();
  }
}
