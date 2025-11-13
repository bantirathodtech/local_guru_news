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
final topicId = StateProvider<String>((ref) => '0');
final topicType = StateProvider<String>((ref) => 'topic');
final topic = StateProvider<String>((ref) => 'మీ కోసం');

/// Currently opened post identifier (used for navigation and comments).
final postId = StateProvider<String>((ref) => '0');

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


