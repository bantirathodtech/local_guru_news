import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final jobsPaginationControllerProvider =
    StateNotifierProvider<JobsPaginationController, JobsPagination>((ref) {
  final jobsRepository = ref.watch(jobsServiceProvider);
  final district = ref.watch(locationDistrict);
  return JobsPaginationController(jobsRepository, district);
});

class JobsPaginationController extends StateNotifier<JobsPagination> {
  JobsPaginationController(
    this._jobsRepository,
    this._district, [
    JobsPagination? state,
  ]) : super(state ?? JobsPagination.initial()) {
    getJobs();
  }

  final JobsRepository _jobsRepository;
  final String _district;

  Future<void> getJobs() async {
    try {
      final jobs = await _jobsRepository.getJobs(
        page: state.page ?? 1,
        district: _district,
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

  Future<void> addNewJob({
    required String stateId,
    required String district,
    required String landmark,
    required String category,
    required String tags,
    required String salary,
    required String jobType,
    required String title,
    required String hires,
    required String qualification,
    required String location,
    required String contact,
    required String shortDescription,
    required String description,
  }) async {
    try {
      final jobs = await _jobsRepository.addJob(
        state: stateId,
        district: district,
        landmark: landmark,
        category: category,
        tags: tags,
        salary: salary,
        jobType: jobType,
        title: title,
        hires: hires,
        qualification: qualification,
        location: location,
        contact: contact,
        shortDescription: shortDescription,
        description: description,
      );
      state = state.copyWith(
        jobs: [
          ...jobs,
          ...state.jobs ?? const [],
        ],
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
      getJobs();
    }
  }
}
