import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/modules/greetings_module/models/greetingsPaginationModel.dart';
import '../../../src.dart';

final greetingsPaginationControllerProvider =
    StateNotifierProvider<GreetingsPaginationController, GreetingsPagination>(
        (ref) {
  final getGreetingsService = ref.watch(greetingsServiceProvider);
  final getTopicId = ref.watch(greetingTopicId);
  return GreetingsPaginationController(getGreetingsService, getTopicId);
});

class GreetingsPaginationController extends StateNotifier<GreetingsPagination> {
  final GreetingsService _greetingsService;
  final String topicId;

  GreetingsPaginationController(
    this._greetingsService,
    this.topicId, [
    GreetingsPagination? state,
  ]) : super(state ?? GreetingsPagination.initial()) {
    getGreetings();
  }

  // -----Fetch Posts
  Future<void> getGreetings() async {
    try {
      final greetings =
          await _greetingsService.getGreetings(state.page!, topicId);
      state = state.copyWith(
        greetings: [
          ...state.greetings!,
          ...greetings,
        ],
        page: state.page! + 1,
      );
    } on ErrorExceptionHandler catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

// -------Reset Greetings
  Future<void> resetGreetings() async {
    state = state.clearGreetings();
  }

  // ---------Refresh Greetings
  Future<void> refreshGreetings() async {
    state = state.refreshGreetings();
  }

  void handleScrollWithIndex(int index) {
    final itemPosition = index + 1;
    final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
    final pageToRequest = itemPosition ~/ 10;

    if (requestMoreData && pageToRequest + 1 >= state.page!) {
      getGreetings();
    }
  }
}
