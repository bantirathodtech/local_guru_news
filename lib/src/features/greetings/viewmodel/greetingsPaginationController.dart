import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final greetingsPaginationControllerProvider =
    StateNotifierProvider<GreetingsPaginationController, GreetingsPagination>(
        (ref) {
  final greetingsRepository = ref.watch(greetingsServiceProvider);
  final topicId = ref.watch(greetingTopicId);
  return GreetingsPaginationController(
    greetingsRepository,
    topicId,
  );
});

class GreetingsPaginationController extends StateNotifier<GreetingsPagination> {
  GreetingsPaginationController(
    this._greetingsRepository,
    this._topicId, [
    GreetingsPagination? state,
  ]) : super(state ?? GreetingsPagination.initial()) {
    getGreetings();
  }

  final GreetingsRepository _greetingsRepository;
  final String _topicId;

  Future<void> getGreetings() async {
    try {
      final greetings = await _greetingsRepository.getGreetings(
        page: state.page ?? 1,
        topicId: _topicId,
      );

      state = state.copyWith(
        greetings: [
          ...state.greetings ?? const [],
          ...greetings,
        ],
        page: (state.page ?? 1) + 1,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> resetGreetings() async {
    state = state.clearGreetings();
  }

  Future<void> refreshGreetings() async {
    state = state.refreshGreetings();
  }

  void handleScrollWithIndex(int index) {
    final itemPosition = index + 1;
    final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
    final pageToRequest = itemPosition ~/ 10;

    if (requestMoreData && pageToRequest + 1 >= (state.page ?? 1)) {
      getGreetings();
    }
  }
}
