import 'package:flutter/foundation.dart';

import '../../../src.dart';

class GreetingsPagination {
  final List<GreetingsModel>? greetings;
  final int? page;
  final String? errorMessage;

  GreetingsPagination({
    this.greetings,
    this.page,
    this.errorMessage,
  });

  GreetingsPagination.initial()
      : greetings = [],
        page = 1,
        errorMessage = '';

  bool get refreshError => errorMessage != '' && greetings!.length <= 10;

  GreetingsPagination copyWith({
    List<GreetingsModel>? greetings,
    int? page,
    String? errorMessage,
  }) {
    return GreetingsPagination(
      greetings: greetings ?? this.greetings,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // ------------------Clear Data
  GreetingsPagination clearGreetings({
    List<GreetingsModel>? greetings,
    int? page,
    String? errorMessage,
  }) {
    return GreetingsPagination(
      greetings: [],
      page: 1,
      errorMessage: '',
    );
  }

  // ------------Refresh Data
  GreetingsPagination refreshGreetings() {
    return GreetingsPagination(
      greetings: greetings,
      page: this.page,
      errorMessage: this.errorMessage,
    );
  }

  @override
  String toString() =>
      'GreetingsPagination(posts: $greetings, page: $page, errorMessage: $errorMessage)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is GreetingsPagination &&
        listEquals(o.greetings, greetings) &&
        o.page == page &&
        o.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      greetings.hashCode ^ page.hashCode ^ errorMessage.hashCode;
}
