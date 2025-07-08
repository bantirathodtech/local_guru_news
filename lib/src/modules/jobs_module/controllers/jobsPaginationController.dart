import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src.dart';

final jobsPaginationControllerProvider =
    StateNotifierProvider<JobsPaginationController, JobsPagination>((ref) {
  final getJobService = ref.watch(jobsServiceProvider);
  final getDistrict = ref.watch(locationDistrict);
  return JobsPaginationController(getJobService, getDistrict);
});

class JobsPaginationController extends StateNotifier<JobsPagination> {
  final JobsService _jobsService;
  final String _district;

  JobsPaginationController(
    this._jobsService,
    this._district, [
    JobsPagination? state,
  ]) : super(state ?? JobsPagination.initial()) {
    getJobs();
  }

  // -----Fetch Posts
  Future<void> getJobs() async {
    try {
      final jobs = await _jobsService.getJobs(state.page!, _district);
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

  // New Job
  Future<void> addnewJob(
    String stateId,
    String district,
    String landmark,
    String category,
    String tags,
    String salary,
    String jobType,
    String title,
    String hires,
    String qualification,
    String location,
    String contact,
    String shortDescription,
    String description,
  ) async {
    try {
      final jobs = await _jobsService.addJob(
        stateId,
        district,
        landmark,
        category,
        tags,
        salary,
        jobType,
        title,
        hires,
        qualification,
        location,
        contact,
        shortDescription,
        description,
      );
      state = state.copyWith(
        jobs: [
          ...jobs,
          ...state.jobs!,
        ],
        page: state.page!,
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
      getJobs();
    }
  }
}
