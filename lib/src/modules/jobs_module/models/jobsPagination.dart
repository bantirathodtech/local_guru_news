import 'package:flutter/foundation.dart';

import '../../../src.dart';

class JobsPagination {
  final List<JobsModel>? jobs;
  final int? page;
  final String? errorMessage;

  JobsPagination({
    this.jobs,
    this.page,
    this.errorMessage,
  });

  JobsPagination.initial()
      : jobs = [],
        page = 1,
        errorMessage = '';

  bool get refreshError => errorMessage != '' && jobs!.length <= 10;

  JobsPagination copyWith({
    List<JobsModel>? jobs,
    int? page,
    String? errorMessage,
  }) {
    return JobsPagination(
      jobs: jobs ?? this.jobs,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ------------------Clear Data
  JobsPagination restJobs({
    List<JobsModel>? jobs,
    int? page,
    String? errorMessage,
  }) {
    return JobsPagination(
      jobs: [],
      page: 1,
      errorMessage: '',
    );
  }

  // ------------Refresh Data
  JobsPagination refreshJobs() {
    return JobsPagination(
      jobs: jobs,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  @override
  String toString() =>
      'JobsPagination(jobs: $jobs, page: $page, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is JobsPagination &&
        listEquals(o.jobs, jobs) &&
        o.page == page &&
        o.errorMessage == errorMessage;
  }

  @override
  int get hashCode => jobs.hashCode ^ page.hashCode ^ errorMessage.hashCode;
}
