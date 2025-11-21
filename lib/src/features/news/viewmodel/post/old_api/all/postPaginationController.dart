import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/log/logging.dart';
import 'package:local_guru_all/src/core/api/shared/state/app_state.dart';
import 'package:local_guru_all/src/features/news/data/model/posts/all/postsPaginationModel.dart';
import 'package:local_guru_all/src/features/news/data/model/posts/all/posts_Model.dart';
import 'package:local_guru_all/src/features/news/data/repository/post/new_api/all/postsRepository.dart';
import 'package:local_guru_all/src/features/news/viewmodel/post/old_api/all/legacy_news_filters.dart';

/// Legacy pagination controller that keeps the previous Riverpod flow
/// operational. Now uses new APIs (get_all_posts_api.php and get_posts_by_topic_api.php)
final legacyPostPaginationControllerProvider =
    StateNotifierProvider<LegacyPostPaginationController, PostsPagination>(
        (ref) {
  final selectedTopicId = ref.watch(topicId);
  final selectedTopicType = ref.watch(topicType);
  final userIdValue = ref.watch(userIdProvider);
  final selectedPoliticianId = ref.watch(selectedPoliticianIdProvider);
  // For location type, use location IDs (stateId, districtId, landmarkId)
  final selectedStateId = ref.watch(selectedNewsStateIdProvider);
  final selectedDistrictId = ref.watch(selectedNewsDistrictIdProvider);
  final selectedLandmarkId = ref.watch(selectedNewsLandmarkIdProvider);
  final postsRepository = ref.read(postsRepositoryProvider);

  return LegacyPostPaginationController(
    topicId: selectedTopicId,
    topicType: selectedTopicType,
    userId: userIdValue,
    politicianId: selectedPoliticianId,
    stateId: selectedTopicType.toLowerCase() == 'location' ? selectedStateId : null,
    districtId: selectedTopicType.toLowerCase() == 'location' ? selectedDistrictId : null,
    landmarkId: selectedTopicType.toLowerCase() == 'location' ? selectedLandmarkId : null,
    postsRepository: postsRepository,
  );
});

class LegacyPostPaginationController extends StateNotifier<PostsPagination> {
  LegacyPostPaginationController({
    required this.topicId,
    required this.topicType,
    required this.userId,
    this.politicianId,
    this.stateId,
    this.districtId,
    this.landmarkId,
    required this.postsRepository,
  }) : super(PostsPagination.initial()) {
    // Don't call API in constructor - let it be called explicitly when needed
    // This prevents continuous calls when provider is recreated due to watched dependencies
  }

  final String topicId;
  final String topicType;
  final String userId;
  final String? politicianId;
  final String? stateId;
  final String? districtId;
  final String? landmarkId;
  final PostsRepository postsRepository;
  
  // Editor user ID - can be configured (default: 38 as per requirements)
  static const String editorUserId = '38';

  bool _isLoading = false;

  Future<void> getPosts() async {
    if (_isLoading) {
      AppLogger.logInfo('Legacy getPosts skipped: already running',
          tag: 'legacyPostPagination');
      return;
    }

    final normalizedTopicType = topicType.toLowerCase();
    if (normalizedTopicType == 'politician' &&
        ((politicianId ?? '').isEmpty)) {
      AppLogger.logInfo(
        'Legacy getPosts skipped: awaiting politician selection',
        tag: 'legacyPostPagination',
      );
      return;
    }
    
    // Guard: Check if we already have data for the first page
    // Only skip if we have posts AND we're on page 1 (initial load)
    final currentPage = state.page ?? 1;
    if (currentPage == 1 && 
        state.posts != null && 
        state.posts!.isNotEmpty) {
      AppLogger.logInfo('Legacy getPosts skipped: already have initial data',
          tag: 'legacyPostPagination');
      return;
    }

    _isLoading = true;
    try {
      AppLogger.logInfo(
        'Legacy getPosts(page=$currentPage, topicId=$topicId, topicType=$topicType)',
        tag: 'legacyPostPagination',
      );

      List<PostsModel> posts;

      // Check if "Latest News" is selected (topicId is '0' or type is 'latest')
      final isLatestNews = topicId == '0' || 
                          topicId.isEmpty || 
                          topicType == 'latest' ||
                          (topicId.contains('/') && topicId.split('/').last == '0');

      const pageLimit = 20;
      if (isLatestNews) {
        // Use getAllPosts API for "Latest News"
        AppLogger.logInfo('Legacy: Fetching all posts (Latest News)',
            tag: 'legacyPostPagination');
        posts = await postsRepository.getAllPosts(
          page: currentPage,
          limit: pageLimit,
        );
      } else {
        // Use getPostsByTopic API for filtered posts
        AppLogger.logInfo(
            'Legacy: Fetching posts by topic: topicId=$topicId, topicType=$topicType',
            tag: 'legacyPostPagination');

        // Extract topicId if it's in format "topic/1" or just "1"
        String? resolvedTopicId = topicId;
        if (topicId.contains('/')) {
          resolvedTopicId = topicId.split('/').last;
        }
        // Handle special case for editor type
        if (topicType == 'editor' && resolvedTopicId == 'editor') {
          resolvedTopicId = null; // Editor type doesn't need topicId
        } else if (resolvedTopicId == '0' || resolvedTopicId.isEmpty) {
          resolvedTopicId = null;
        }

        // Determine additional parameters based on topicType
        String? politicianIdParam;
        String? stateIdParam;
        String? districtIdParam;
        String? landmarkIdParam;
        String? editorUserIdParam;

        switch (topicType.toLowerCase()) {
          case 'politician':
            // For politician, use politicianId from filter
            if (politicianId != null && politicianId!.isNotEmpty) {
              politicianIdParam = politicianId;
            }
            break;
          case 'location':
            // For location, use stateId (required), districtId and landmarkId (optional)
            if (stateId != null && stateId!.isNotEmpty) {
              stateIdParam = stateId;
            }
            if (districtId != null && districtId!.isNotEmpty) {
              districtIdParam = districtId;
            }
            if (landmarkId != null && landmarkId!.isNotEmpty) {
              landmarkIdParam = landmarkId;
            }
            break;
          case 'editor':
            // For editor, use editor user ID (default: 38)
            editorUserIdParam = editorUserId;
            break;
          case 'topic':
          default:
            // For regular topics, just use topicId
            break;
        }

        final isPoliticianFeed = topicType.toLowerCase() == 'politician' &&
            (politicianIdParam != null && politicianIdParam.isNotEmpty);

        if (isPoliticianFeed) {
          AppLogger.logInfo(
              'Legacy: Fetching politician news via dedicated API (id=$politicianIdParam)',
              tag: 'legacyPostPagination');
          posts = await postsRepository.getPoliticianNews(
            page: currentPage,
            politicianId: politicianIdParam,
            limit: pageLimit,
          );
        } else {
          AppLogger.logInfo(
              'Legacy: Calling getPostsByTopic with topicType=$topicType, topicId=$resolvedTopicId, politicianId=$politicianIdParam, stateId=$stateIdParam, districtId=$districtIdParam, landmarkId=$landmarkIdParam, userId=$editorUserIdParam',
              tag: 'legacyPostPagination');

          posts = await postsRepository.getPostsByTopic(
            page: currentPage,
            topicType: topicType,
            topicId: resolvedTopicId,
            politicianId: politicianIdParam,
            stateId: stateIdParam,
            districtId: districtIdParam,
            landmarkId: landmarkIdParam,
            userId: editorUserIdParam,
            limit: pageLimit,
          );
        }
      }

      if (!mounted) {
        _isLoading = false;
        return;
      }

      state = state.copyWith(
        posts: [...?state.posts, ...posts],
        page: currentPage + 1,
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        _isLoading = false;
        return;
      }
      AppLogger.logError('Legacy getPosts error: $error',
          tag: 'legacyPostPagination', stackTrace: stackTrace);
      state = state.copyWith(errorMessage: error.toString());
    } finally {
      _isLoading = false;
    }
  }

  Future<void> resetPosts() async {
    _isLoading = false; // Reset loading state
    state = PostsPagination.initial();
    await getPosts();
  }

  void clearPosts() {
    _isLoading = false;
    state = PostsPagination.initial();
  }
  
  /// Initialize posts - call this explicitly when screen loads
  /// This prevents automatic calls in constructor
  /// Note: When filters change, the provider is recreated, so this will be called
  /// with a fresh state, which will trigger a fetch if needed
  Future<void> initializePosts() async {
    // If no data exists, fetch initial page
    if (state.posts == null || state.posts!.isEmpty) {
      await getPosts();
    }
  }

  Future<void> refreshPost(String postId, int index) async {
    state = state.refreshPost(postId, index);
  }

  Future<void> postViews(String id, String views, int index) async {
    state = state.postViews(id, views, index);
  }

  /// Update likes/dislikes with batch optimization
  /// Uses unawaited to prevent blocking and allows batch updates
  Future<void> likes(int id, String type, int like, int index) async {
    // Batch update: Update state immediately for instant UI feedback
    // The API call is handled inside the model's likes() method
    state = state.likes(id, type, like, index);
  }

  Future<void> whatsShare(String id, String share, int index) async {
    state = state.whatsShare(id, share, index);
  }

  Future<void> commentsCount(int index) async {
    state = state.commentCount(index);
  }

  void handleScrollWithIndex(int index) {
    final itemPosition = index + 1;
    // Use page size of 20 (matching the new API limit)
    const pageSize = 20;
    final requestMoreData = itemPosition % pageSize == 0;
    final pageToRequest = itemPosition ~/ pageSize;
    if (requestMoreData && pageToRequest + 1 >= (state.page ?? 1)) {
      getPosts();
    }
  }
}
