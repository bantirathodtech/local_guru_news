import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/features/news/data/model/politician/politiciansModel.dart';
import 'package:local_guru_all/src/features/news/data/repository/politician/politiciansServices.dart';
import 'package:local_guru_all/src/features/news/data/repository/post/post_engagement_repository.dart';

final politiciansControllerProvider =
    StateNotifierProvider<PoliticiansController, PoliticiansModelProvider>(
        (ref) {
  final getPoliticiansServiceProvider = ref.read(politicansServiceProvider);
  return PoliticiansController(getPoliticiansServiceProvider);
});

class PoliticiansController extends StateNotifier<PoliticiansModelProvider> {
  final PoliticiansService _politiciansService;

  PoliticiansController(
    this._politiciansService, [
    PoliticiansModelProvider? state,
  ]) : super(state ?? PoliticiansModelProvider.initial()) {
    getPoliticians();
  }

  // -----Fetch Politicians
  Future<void> getPoliticians() async {
    try {
      final politicians = await _politiciansService.getTopics();
      state = state.copyWith(
        politicians: [
          ...state.politicians!,
          ...politicians,
        ],
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

// Clear Politicians
  Future<void> resetPoliticians() async {
    state = state.resetPoliticians();
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
