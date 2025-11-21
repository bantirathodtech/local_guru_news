import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/features/news/data/model/topics/topics_Model.dart';
import 'package:local_guru_all/src/features/news/data/repository/topics/topicsRepository.dart';

/// Topics Provider - State management and logic layer
/// Acts as a bridge between TopicsRepository (data layer) and UI (screen/widget)
final topicsProvider =
    StateNotifierProvider<TopicsNotifier, TopicsModelProvider>((ref) {
  final topicsRepository = ref.read(topicsRepositoryProvider);
  return TopicsNotifier(topicsRepository);
});

/// TopicsNotifier - State management controller
/// Handles business logic and state updates for topics
class TopicsNotifier extends StateNotifier<TopicsModelProvider> {
  final TopicsRepository _topicsRepository;
  bool _isLoading = false;

  TopicsNotifier(
    this._topicsRepository, [
    TopicsModelProvider? initialState,
  ]) : super(initialState ?? TopicsModelProvider.initial()) {
    // Auto-load topics when notifier is created
    getTopics();
  }

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Fetch topics from repository
  /// Updates state with topics list or error message
  /// Adds "Latest News" as the first item and "Editor News" as the second item
  Future<void> getTopics() async {
    // Prevent duplicate concurrent calls
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    state = state.copyWith(errorMessage: '');

    try {
      final topics = await _topicsRepository.getTopics();
      
      // Create "Latest News" topic as the first item
      final latestNewsTopic = TopicsModel(
        id: '0', // Use '0' as special ID for "Latest News"
        name: 'Latest News',
        icon: '', // Can be set to a default icon URL if needed
        type: 'latest', // Special type to identify "Latest News"
      );

      // Create "Editor News" topic as the second item
      final editorNewsTopic = TopicsModel(
        id: 'editor', // Use 'editor' as special ID for "Editor News"
        name: 'Editor News',
        icon: '', // Can be set to a default icon URL if needed
        type: 'editor', // Special type to identify "Editor News"
      );

      // Combine "Latest News", "Editor News", and fetched topics
      final allTopics = [latestNewsTopic, editorNewsTopic, ...topics];
      
      state = state.copyWith(
        topics: allTopics,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  /// Refresh topics - clears current state and fetches fresh data
  Future<void> refreshTopics() async {
    state = state.resetTopics();
    await getTopics();
  }

  /// Clear all topics from state
  void clearTopics() {
    state = state.resetTopics();
  }

  /// Add a new topic to the list
  /// If topic already exists (same id, name, type), removes it first
  void addTopic(
    String id,
    String name,
    String type,
    String icon,
  ) {
    try {
      final currentTopics = List<TopicsModel>.from(state.topics ?? []);

      // Check if topic already exists
      final existingIndex = currentTopics.indexWhere((element) =>
          element.id == id &&
          element.name == name &&
          element.type == type);

      if (existingIndex != -1) {
        // Remove existing topic
        currentTopics.removeAt(existingIndex);
      }

      // Add new topic at the beginning
      currentTopics.insert(
        0,
        TopicsModel(
          id: id,
          name: name,
          type: type,
          icon: icon,
        ),
      );

      state = state.newTopic(topics: currentTopics);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Remove a topic from the list by id
  void removeTopic(String id) {
    try {
      final currentTopics = List<TopicsModel>.from(state.topics ?? []);
      currentTopics.removeWhere((element) => element.id == id);
      state = state.newTopic(topics: currentTopics);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Check if a topic exists in the list
  bool hasTopic(String id) {
    return state.topics?.any((topic) => topic.id == id) ?? false;
  }

  /// Get topic by id
  TopicsModel? getTopicById(String id) {
    try {
      return state.topics?.firstWhere((topic) => topic.id == id);
    } catch (e) {
      return null;
    }
  }
}
