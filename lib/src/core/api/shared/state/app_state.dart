import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:local_guru_all/src/features/listing/data/model/listTopics.dart';
import 'package:local_guru_all/src/features/listing/data/repository/list_topics_repository.dart';
import 'package:local_guru_all/src/features/requirement/data/model/requirementsModel.dart';
import 'package:local_guru_all/src/features/requirement/data/repository/requirements_repository.dart';

// Box provider to centralise Hive box access and allow overriding in tests.
final _userBoxProvider = Provider<Box<String>>(
  (ref) => Hive.box<String>('user'),
);

/// Bottom navigation index tracker.
final currentIndexProvider = StateProvider<int>((ref) => 0);

/// News topic selection (id/type/name) used across legacy and new flows.
/// Default: Latest News (topicId='0', topicType='latest')
final topicId = StateProvider<String>((ref) => '0');
final topicType = StateProvider<String>((ref) => 'latest');
final topic = StateProvider<String>((ref) => 'Latest News');

/// Currently opened post identifier (used for navigation and comments).
final postId = StateProvider<String>((ref) => '0');

/// Selected location for news filtering (state, district, landmark)
/// These are separate from persisted location values
final selectedNewsStateIdProvider = StateProvider<String?>((ref) => null);
final selectedNewsStateNameProvider = StateProvider<String?>((ref) => null);
final selectedNewsDistrictIdProvider = StateProvider<String?>((ref) => null);
final selectedNewsDistrictNameProvider = StateProvider<String?>((ref) => null);
final selectedNewsLandmarkIdProvider = StateProvider<String?>((ref) => null);
final selectedNewsLandmarkNameProvider = StateProvider<String?>((ref) => null);

/// Greetings topics selection.
final greetingTopicId = StateProvider<String>((ref) => '0');

/// Listings topics selection.
final listTopicId = StateProvider<String>((ref) => '0');

/// Persisted location metadata (state / district / landmark / label).
final locationState = StateProvider<String>((ref) {
  final box = ref.watch(_userBoxProvider);
  return box.get('state', defaultValue: '') ?? '';
});

final locationDistrict = StateProvider<String>((ref) {
  final box = ref.watch(_userBoxProvider);
  return box.get('district', defaultValue: '') ?? '';
});

final locationLandmark = StateProvider<String>((ref) {
  final box = ref.watch(_userBoxProvider);
  return box.get('landmark', defaultValue: '') ?? '';
});

final selectedLocation = StateProvider<String>((ref) {
  final box = ref.watch(_userBoxProvider);
  return box.get('location', defaultValue: '') ?? '';
});

/// Helper function to convert Telugu state names to English for API compatibility
String? _getStateEnglishName(String? teluguName) {
  if (teluguName == null || teluguName.isEmpty) return null;
  
  // Map common Telugu state names to English
  final stateMap = {
    'తెలంగాణ': 'Telangana',
    'ఆంధ్రప్రదేశ్': 'Andhra Pradesh',
    'తమిళనాడు': 'Tamil Nadu',
    'కర్ణాటక': 'Karnataka',
    'మహారాష్ట్ర': 'Maharashtra',
  };
  
  return stateMap[teluguName] ?? teluguName; // Fallback to original if not found
}

/// Computed location name for news filtering
/// Combines state, district, and landmark names based on what's selected (using English names for API compatibility)
final selectedNewsLocationNameProvider = Provider<String?>((ref) {
  final stateName = ref.watch(selectedNewsStateNameProvider);
  final districtName = ref.watch(selectedNewsDistrictNameProvider);
  final landmarkName = ref.watch(selectedNewsLandmarkNameProvider);

  // Convert state name to English for API compatibility
  final stateEnglishName = _getStateEnglishName(stateName);

  if (landmarkName != null && landmarkName.isNotEmpty) {
    // If landmark is selected, return the full hierarchy: State, District, Landmark
    final parts = <String>[];
    if (stateEnglishName != null && stateEnglishName.isNotEmpty) parts.add(stateEnglishName);
    if (districtName != null && districtName.isNotEmpty) parts.add(districtName);
    parts.add(landmarkName);
    return parts.join(', ');
  } else if (districtName != null && districtName.isNotEmpty) {
    // If only district is selected, return State, District
    final parts = <String>[];
    if (stateEnglishName != null && stateEnglishName.isNotEmpty) parts.add(stateEnglishName);
    parts.add(districtName);
    return parts.join(', ');
  } else if (stateEnglishName != null && stateEnglishName.isNotEmpty) {
    // If only state is selected, return just State (in English)
    return stateEnglishName;
  }

  return null;
});

/// Jobs search tag used on the jobs dashboard.
final jobSearchTag = StateProvider<String>((ref) => '');

/// Deep link target post id.
final deepLinkPostId = StateProvider<int>((ref) => 0);

/// Logged-in user id (defaults to '0' for guest sessions).
final userIdProvider = Provider<String>((ref) {
  final box = ref.watch(_userBoxProvider);
  return box.get('id', defaultValue: '0') ?? '0';
});

/// Fetch list topics (Listings feature) using the core API bridge.
final listTopicsRepositoryProvider = Provider<ListTopicsRepository>(
  (ref) => ListTopicsRepository(),
);

final fetchListTopics = FutureProvider<List<ListsTopics>>((ref) async {
  final repository = ref.watch(listTopicsRepositoryProvider);
  final userId = ref.watch(userIdProvider);
  return repository.fetchTopics(userId: userId);
});

final fetchRequirementsData = FutureProvider<List<RequirementsModel>>((ref) async {
  final repository = ref.watch(requirementsRepositoryProvider);
  return repository.fetchRequirements();
});

final fetchRequirementsMenu =
    FutureProvider<List<RequirementsModel>>((ref) async {
  final repository = ref.watch(requirementsRepositoryProvider);
  return repository.fetchMenu();
});


