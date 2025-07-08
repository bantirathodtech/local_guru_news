import 'package:flutter/foundation.dart';

import '../../../src.dart';

class JobsSearchPagination {
  final List<JobsSearchModel>? jobs;
  final int? page;
  final String? errorMessage;

  JobsSearchPagination({
    this.jobs,
    this.page,
    this.errorMessage,
  });

  JobsSearchPagination.initial()
      : jobs = [],
        page = 1,
        errorMessage = '';

  bool get refreshError => errorMessage != '' && jobs!.length <= 10;

  JobsSearchPagination copyWith({
    List<JobsSearchModel>? jobs,
    int? page,
    String? errorMessage,
  }) {
    return JobsSearchPagination(
      jobs: jobs ?? this.jobs,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ------------------Clear Data
  JobsSearchPagination restJobs({
    List<JobsSearchModel>? jobs,
    int? page,
    String? errorMessage,
  }) {
    return JobsSearchPagination(
      jobs: [],
      page: 1,
      errorMessage: '',
    );
  }

  // ------------Refresh Data
  JobsSearchPagination refreshJobs() {
    return JobsSearchPagination(
      jobs: jobs,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  @override
  String toString() =>
      'JobsSearchPagination(jobs: $jobs, page: $page, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is JobsSearchPagination &&
        listEquals(o.jobs, jobs) &&
        o.page == page &&
        o.errorMessage == errorMessage;
  }

  @override
  int get hashCode => jobs.hashCode ^ page.hashCode ^ errorMessage.hashCode;
}
