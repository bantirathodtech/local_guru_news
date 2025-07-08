import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_guru_all/src/models/requirementsModel.dart';
import '../src.dart';

// ! Bottom Navigation Current Index
final currentIndexProvider = StateProvider<int>((ref) => 0);

Box<String> box = Hive.box('user');

//Posts
final topicId = StateProvider<String>((ref) => '0');
final topic = StateProvider<String>((ref) => 'మీ కోసం');
final topicType = StateProvider<String>((ref) => 'landmark');
final postId = StateProvider<String>((ref) => '0');

// Greetings
final greetingTopicId = StateProvider<String>((ref) => '0');

// Listings
final listTopicId = StateProvider<String>((ref) => '0');

// Requirements menu
final fetchRequirementsMenu =
    FutureProvider<List<RequirementsModel>>((ref) async {
  return DatabaseService.requirementsMenu();
});
// Requirements menu
final fetchRequirementsData =
    FutureProvider<List<RequirementsModel>>((ref) async {
  return DatabaseService().fetchrequirements();
});

//! ---------------------Location--------------------

final locationState =
    StateProvider<String>((ref) => box.get('state').toString()); //State
final locationDistrict =
    StateProvider<String>((ref) => box.get('district').toString()); //District
final locationLandmark =
    StateProvider<String>((ref) => box.get('landmark').toString()); //Landmark

final selectedLocation = StateProvider<String>(
    (ref) => box.get('location').toString()); //Selected Location

final fetchLocation = FutureProvider<List<LocationModel>>((ref) {
  return DatabaseService.fetchLoction();
});

final getDistricts = StateProvider<List<District>>((ref) => []);
final getLandmarks = StateProvider<List<Landmark>>((ref) => []);

final fetchListTopics = FutureProvider<List<ListsTopics>>((ref) {
  return DatabaseService().fetchListTopics();
});

//! ---------------------Jobs--------------------
final jobSearchTag = StateProvider<String>((ref) => '');
final jobData = FutureProvider<NewJobModel>((ref) {
  return DatabaseService().fetchJobData();
});

//! ---------------------Topics--------------------

// final fetchPoliticians = FutureProvider<List<PoliticianModel>>((ref) async {
//   return DatabaseService().fetchPoliticians();
// });
// ---------------------Posts--------------------
// final fetchPosts = FutureProvider<List<PostsModel>>((ref) async {
//   return DatabaseService.fetchPosts(ref.read(topicId).state);
// });

// DeepLink Post Id
final deepLinkPostId = StateProvider<int>((ref) => 0);
