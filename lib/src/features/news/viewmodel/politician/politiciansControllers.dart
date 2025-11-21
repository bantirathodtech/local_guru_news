import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/features/news/data/model/politician/politiciansModel.dart';
import 'package:local_guru_all/src/features/news/data/repository/politician/politiciansServices.dart';
import 'package:local_guru_all/src/features/news/data/repository/post/post_engagement_repository.dart';

final politiciansControllerProvider =
    StateNotifierProvider<PoliticiansController, PoliticiansModelProvider>(
  (ref) {
    final getPoliticiansServiceProvider = ref.read(politicansServiceProvider);
    return PoliticiansController(getPoliticiansServiceProvider);
  },
);

class PoliticiansController extends StateNotifier<PoliticiansModelProvider> {
  final PoliticiansService _politiciansService;
  bool _isLoading = false; // Prevent overlapping requests

  PoliticiansController(
    this._politiciansService, [
    PoliticiansModelProvider? state,
  ]) : super(state ?? PoliticiansModelProvider.initial()) {
    loadInitialPoliticians();
  }

  Future<void> loadInitialPoliticians({String search = ''}) async {
    developer.log('PoliticiansController: loadInitialPoliticians "$search"');
    state = state.copyWith(
      isLoading: true,
      errorMessage: '',
      searchQuery: search,
      politicians: [],
      currentPage: 0,
      hasMore: true,
    );
    await _fetchPoliticians(page: 1, reset: true, search: search);
  }

  Future<void> loadMorePoliticians() async {
    if (_isLoading) {
      developer.log('PoliticiansController: loadMore skipped - busy');
      return;
    }
    if (!state.hasMore) {
      developer.log('PoliticiansController: loadMore skipped - no more data');
      return;
    }
    final nextPage = state.currentPage + 1;
    await _fetchPoliticians(page: nextPage);
  }

  Future<void> searchPoliticians(String query) async {
    developer.log('PoliticiansController: search="$query"');
    await loadInitialPoliticians(search: query);
  }

  Future<void> _fetchPoliticians({
    required int page,
    bool reset = false,
    String? search,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    state = state.copyWith(isLoading: true);
    final effectiveSearch = search ?? state.searchQuery;
    try {
      final result = await _politiciansService.getTopics(
        page: page,
        search: effectiveSearch,
      );
      developer.log(
        'PoliticiansController: Page $page returned ${result.length} politicians',
      );

      final updatedList = [
        if (!reset) ...?state.politicians,
        ...result,
      ];

      state = state.copyWith(
        politicians: updatedList,
        errorMessage: '',
        isLoading: false,
        currentPage: result.isEmpty && page == 1 ? 0 : page,
        hasMore: result.isNotEmpty,
        searchQuery: effectiveSearch,
      );
      developer.log(
        'PoliticiansController: State updated count=${state.politicians?.length ?? 0}',
      );
    } catch (e, stackTrace) {
      developer.log(
        'PoliticiansController: Error fetching politicians: $e',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
        hasMore: false,
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> resetPoliticians() async {
    state = state.resetPoliticians();
    await loadInitialPoliticians();
  }

  // Update Follow Status
  Future<void> updateStatus(
    String status,
    int index,
    String id,
  ) async {
    if (status == '0') {
      state.politicians![index].status = '1';
      state = state.updateStatus();
    } else {
      state.politicians![index].status = '0';
      state = state.updateStatus();
    }
    await PostEngagementRepository.instance.updatePoliticianStatus(id);
  }
}
