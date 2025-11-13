import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src.dart';

final jobsSearchPaginationControllerProvider =
    StateNotifierProvider<JobsSearchPaginationController, JobsSearchPagination>(
        (ref) {
  final jobsSearchRepository = ref.watch(jobsSearchServiceProvider);
  final jobSearchQuery = ref.watch(jobSearchTag);
  return JobsSearchPaginationController(jobsSearchRepository, jobSearchQuery);
});

class JobsSearchPaginationController
    extends StateNotifier<JobsSearchPagination> {
  JobsSearchPaginationController(
    this._jobsSearchRepository,
    this.search, [
    JobsSearchPagination? state,
  ]) : super(state ?? JobsSearchPagination.initial()) {
    restJobs();
  }

  final JobsSearchRepository _jobsSearchRepository;
  final String search;

  Future<void> getJobs(String search) async {
    try {
      final jobs = await _jobsSearchRepository.getJobs(
        page: state.page ?? 1,
        search: search,
      );
      state = state.copyWith(
        jobs: [
          ...state.jobs ?? const [],
          ...jobs,
        ],
        page: (state.page ?? 1) + 1,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> restJobs() async {
    state = state.restJobs();
  }

  Future<void> refreshJobs() async {
    state = state.refreshJobs();
  }

  void handleScrollWithIndex(int index) {
    final itemPosition = index + 1;
    final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
    final pageToRequest = itemPosition ~/ 10;

    if (requestMoreData && pageToRequest + 1 >= (state.page ?? 1)) {
      getJobs(search);
    }
  }
}
