import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src.dart';

final jobsSearchPaginationControllerProvider =
    StateNotifierProvider<JobsSearchPaginationController, JobsSearchPagination>(
        (ref) {
  final getJobService = ref.watch(jobsSearchServiceProvider);
  final getJobSearch = ref.watch(jobSearchTag);
  return JobsSearchPaginationController(
    getJobService,
    getJobSearch,
  );
});

class JobsSearchPaginationController
    extends StateNotifier<JobsSearchPagination> {
  final JobsSearchService _jobsService;
  final String search;

  JobsSearchPaginationController(
    this._jobsService,
    this.search, [
    JobsSearchPagination? state,
  ]) : super(state ?? JobsSearchPagination.initial()) {
    restJobs();
  }

  // -----Fetch Posts
  Future<void> getJobs(String search) async {
    try {
      final jobs = await _jobsService.getJobs(
        state.page!,
        search,
      );
      state = state.copyWith(
        jobs: [
          ...state.jobs!,
          ...jobs,
        ],
        page: state.page! + 1,
      );
    } on ErrorExceptionHandler catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

// -------Reset Greetings
  Future<void> restJobs() async {
    state = state.restJobs();
  }

  // ---------Refresh Greetings
  Future<void> refreshJobs() async {
    state = state.refreshJobs();
  }

  void handleScrollWithIndex(int index) {
    final itemPosition = index + 1;
    final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
    final pageToRequest = itemPosition ~/ 10;

    if (requestMoreData && pageToRequest + 1 >= state.page!) {
      getJobs(search);
    }
  }
}
