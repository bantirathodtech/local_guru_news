import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/log/logging.dart';

import '../../../../../../src.dart';

final postPaginationControllerProvider =
    StateNotifierProvider<PostPaginationController, PostsPagination>((ref) {
  final selectedTopicId = ref.watch(topicId);
  final selectedTopicType = ref.watch(topicType);
  final userIdValue = ref.watch(userIdProvider);
  
  // For location topic, use news location ID providers, otherwise use persisted location
  final newsStateId = ref.watch(selectedNewsStateIdProvider);
  final newsDistrictId = ref.watch(selectedNewsDistrictIdProvider);
  final newsLandmarkId = ref.watch(selectedNewsLandmarkIdProvider);
  final persistedLandmarkId = ref.watch(locationLandmark);
  final persistedStateId = ref.watch(locationState);
  final persistedDistrictId = ref.watch(locationDistrict);
  
  // Use news location IDs if location topic is selected, otherwise use persisted location
  final stateIdValue = selectedTopicType.toLowerCase() == 'location' && newsStateId != null
      ? newsStateId
      : persistedStateId;
  final districtIdValue = selectedTopicType.toLowerCase() == 'location' && newsDistrictId != null
      ? newsDistrictId
      : persistedDistrictId;
  final landmarkIdValue = selectedTopicType.toLowerCase() == 'location' && newsLandmarkId != null
      ? newsLandmarkId
      : persistedLandmarkId;
  
  final postsRepository = ref.read(postsRepositoryProvider);
  return PostPaginationController(
    selectedTopicId,
    selectedTopicType,
    userIdValue,
    landmarkIdValue,
    stateIdValue,
    districtIdValue,
    postsRepository,
  );
});

class PostPaginationController extends StateNotifier<PostsPagination> {
  final String topicId;
  final String topicType;
  final String userId;
  final String landmarkId;
  final String stateId;
  final String districtId;
  final PostsRepository _postsRepository;
  bool _isLoading = false;

  PostPaginationController(
    this.topicId,
    this.topicType,
    this.userId,
    this.landmarkId,
    this.stateId,
    this.districtId,
    this._postsRepository,
  ) : super(PostsPagination.initial()) {
    // Auto-load posts when controller is created
    getPosts();
  }

  Future<void> getPosts() async {
    // Prevent duplicate concurrent calls
    if (_isLoading) {
      AppLogger.logInfo(
          'getPosts already in progress, skipping duplicate call');
      return;
    }

    AppLogger.logInfo(
        'getPosts called for topicId=$topicId, topicType=$topicType, page=${state.page}, userId=$userId, stateId=$stateId, districtId=$districtId, landmarkId=$landmarkId');

    _isLoading = true;
    try {
      final currentPage = state.page ?? 1;
      List<PostsModel> posts;

      // Check if "Latest News" is selected (topicId is '0' or type is 'latest')
      final isLatestNews =
          topicId == '0' || topicId.isEmpty || topicType == 'latest';

      if (isLatestNews) {
        // Use getAllPosts API for "Latest News"
        AppLogger.logInfo('Fetching all posts (Latest News)');
        posts = await _postsRepository.getAllPosts(
          page: currentPage,
          limit: 20,
        );
      } else {
        // Use getPostsByTopic API for filtered posts
        AppLogger.logInfo(
            'Fetching posts by topic: topicId=$topicId, topicType=$topicType');

        // Extract topicId if it's in format "topic/1" or just "1"
        String? resolvedTopicId = topicId;
        if (topicId.contains('/')) {
          resolvedTopicId = topicId.split('/').last;
        }
        if (resolvedTopicId == '0' || resolvedTopicId.isEmpty) {
          resolvedTopicId = null;
        }

        // Determine additional parameters based on topicType
        String? politicianId;
        String? stateIdParam;
        String? districtIdParam;
        String? landmarkIdParam;
        String? editorUserId;

        switch (topicType.toLowerCase()) {
          case 'politician':
            // For politician, we need politicianId from filters
            // This will be handled by the filter system
            politicianId = null; // Will be set from filter state
            break;
          case 'location':
            // For location, use stateId (required), districtId and landmarkId (optional)
            if (stateId.isNotEmpty && stateId != '0') {
              stateIdParam = stateId;
            }
            if (districtId.isNotEmpty && districtId != '0') {
              districtIdParam = districtId;
            }
            if (landmarkId.isNotEmpty && landmarkId != '0') {
              landmarkIdParam = landmarkId;
            }
            break;
          case 'editor':
            editorUserId = userId;
            break;
          case 'topic':
          default:
            // For regular topics, just use topicId
            break;
        }

        posts = await _postsRepository.getPostsByTopic(
          page: currentPage,
          topicType: topicType,
          topicId: resolvedTopicId,
          politicianId: politicianId,
          stateId: stateIdParam,
          districtId: districtIdParam,
          landmarkId: landmarkIdParam,
          userId: editorUserId,
          limit: 20,
        );
      }

      if (!mounted) {
        _isLoading = false;
        return;
      }
      AppLogger.logInfo('Posts fetched count: ${posts.length}');

      state = state.copyWith(
        posts: [...?state.posts, ...posts],
        page: currentPage + 1,
      );
      AppLogger.logInfo(
          'State updated: total posts count = ${state.posts?.length}');
    } catch (e) {
      if (!mounted) {
        _isLoading = false;
        return;
      }
      AppLogger.logError('getPosts error: $e');

      state = state.copyWith(errorMessage: e.toString());
    } finally {
      _isLoading = false;
    }
  }

  Future<void> resetPosts() async {
    AppLogger.logInfo('resetPosts called');

    state = PostsPagination.initial();
    await getPosts();
  }

  Future<void> refreshPost(String postId, int index) async {
    state = state.refreshPost(postId, index);
  }

  Future<void> postViews(String id, String views, int index) async {
    state = state.postViews(id, views, index);
  }

  Future<void> likes(int id, String type, int like, int index) async {
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
    final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
    final pageToRequest = itemPosition ~/ 10;
    if (requestMoreData && pageToRequest + 1 >= state.page!) {
      getPosts();
    }
  }
}

// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../../../src.dart';
//
// final postPaginationControllerProvider =
//     StateNotifierProvider<PostPaginationController, PostsPagination>((ref) {
//   final getTopicID = ref.watch(topicId);
//   final postService = ref.read(postServiceProvider);
//   final getTopicType = ref.read(topicType);
//   return PostPaginationController(postService, getTopicID, getTopicType);
// });
//
// class PostPaginationController extends StateNotifier<PostsPagination> {
//   final PostService _postService;
//   final String _topicId;
//   final String _topicType;
//
//   PostPaginationController(
//     this._postService,
//     this._topicId,
//     this._topicType, [
//     PostsPagination? state,
//   ]) : super(state ?? PostsPagination.initial()) {
//     getPosts();
//   }
//
//   // -----Fetch Posts
//
//   Future<void> getPosts() async {
//     try {
//       final currentPage = state.page ?? 0;
//
//       final posts =
//           await _postService.getPosts(currentPage, _topicId, _topicType);
//
//       if (!mounted) return;
//
//       state = state.copyWith(
//         posts: [
//           ...state.posts ?? [], // Use empty list if state.posts is null.
//           ...posts,
//         ],
//         page: currentPage + 1, // Increment page number
//       );
//     } on ErrorExceptionHandler catch (e) {
//       if (!mounted) return;
//
//       state = state.copyWith(errorMessage: e.message);
//     }
//   }
//
//   // Future<void> getPosts() async {
//   //   try {
//   //     final posts =
//   //         await _postService.getPosts(state.page!, _topicId, _topicType);
//   //     state = state.copyWith(
//   //       posts: [
//   //         ...state.posts!,
//   //         ...posts,
//   //       ],
//   //       page: state.page! + 1,
//   //     );
//   //   } on ErrorExceptionHandler catch (e) {
//   //     state = state.copyWith(errorMessage: e.message);
//   //   }
//   // }
//
// // -------Reset Posts
//   Future<void> resetPosts() async {
//     state = state.clearPosts();
//   }
//
//   // ---------Refresh Posts
//   Future<void> refreshPost(String postId, int index) async {
//     state = state.refreshPost(postId, index);
//   }
//
//   // -------------Update Post View Count
//   Future<void> postViews(String id, String views, int index) async {
//     state = state.postViews(id, views, index);
//   }
//
//   // Update Likes/Dislikes
//   Future<void> likes(int id, String type, int like, int index) async {
//     state = state.likes(id, type, like, index);
//   }
//
//   // --------------Update Whats Share Count
//   Future<void> whatsShare(String id, String share, int index) async {
//     state = state.whatsShare(id, share, index);
//   }
//
//   // --------------Update Comments Count
//   Future<void> commentsCount(int index) async {
//     state = state.commentCount(index);
//   }
//
//   void handleScrollWithIndex(int index) {
//     final itemPosition = index + 1;
//     final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
//     final pageToRequest = itemPosition ~/ 10;
//
//     if (requestMoreData && pageToRequest + 1 >= state.page!) {
//       getPosts();
//     }
//   }
// }

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:local_guru_all/src/core/log/logging.dart';
//
// import '../../../../../src.dart';
//
// final postPaginationControllerProvider =
//     StateNotifierProvider<PostPaginationController, PostsPagination>((ref) {
//   final topicId = ref.watch(topicIdProvider);
//   final topicType = ref.watch(topicTypeProvider);
//   final userId =
//       ref.watch(userIdProvider); // Provided from riverpodService.dart
//   return PostPaginationController(topicId, topicType, userId);
// });
//
// final topicIdProvider = StateProvider<String>((ref) => '');
//
// final topicTypeProvider = StateProvider<String>((ref) => '');
//
// class PostPaginationController extends StateNotifier<PostsPagination> {
//   final String topicId;
//   final String topicType;
//   final String userId;
//
//   PostPaginationController(this.topicId, this.topicType, this.userId)
//       : super(PostsPagination.initial());
//
//   Future<void> getPosts() async {
//     AppLogger.logInfo(
//         'getPosts called for topicId=$topicId, page=${state.page}, userId=$userId');
//
//     try {
//       final currentPage = state.page ?? 1;
//       final posts = await PostPaginationService.fetchPosts(
//           topicId, topicType, currentPage, userId);
//       if (!mounted) return;
//       AppLogger.logInfo('Posts fetched count: ${posts.length}');
//
//       state = state.copyWith(
//         posts: [...?state.posts, ...posts],
//         page: currentPage + 1,
//       );
//       AppLogger.logInfo(
//           'State updated: total posts count = ${state.posts?.length}');
//     } catch (e) {
//       if (!mounted) return;
//       AppLogger.logError('getPosts error: $e');
//
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }
//
//   Future<void> resetPosts() async {
//     AppLogger.logInfo('resetPosts called');
//
//     state = PostsPagination.initial();
//     await getPosts();
//   }
//
//   Future<void> refreshPost(String postId, int index) async {
//     state = state.refreshPost(postId, index);
//   }
//
//   Future<void> postViews(String id, String views, int index) async {
//     state = state.postViews(id, views, index);
//   }
//
//   Future<void> likes(int id, String type, int like, int index) async {
//     state = state.likes(id, type, like, index);
//   }
//
//   Future<void> whatsShare(String id, String share, int index) async {
//     state = state.whatsShare(id, share, index);
//   }
//
//   Future<void> commentsCount(int index) async {
//     state = state.commentCount(index);
//   }
//
//   void handleScrollWithIndex(int index) {
//     final itemPosition = index + 1;
//     final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
//     final pageToRequest = itemPosition ~/ 10;
//     if (requestMoreData && pageToRequest + 1 >= state.page!) {
//       getPosts();
//     }
//   }
// }
//
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// //
// // import '../../../../../src.dart';
// //
// // final postPaginationControllerProvider =
// //     StateNotifierProvider<PostPaginationController, PostsPagination>((ref) {
// //   final getTopicID = ref.watch(topicId);
// //   final postService = ref.read(postServiceProvider);
// //   final getTopicType = ref.read(topicType);
// //   return PostPaginationController(postService, getTopicID, getTopicType);
// // });
// //
// // class PostPaginationController extends StateNotifier<PostsPagination> {
// //   final PostService _postService;
// //   final String _topicId;
// //   final String _topicType;
// //
// //   PostPaginationController(
// //     this._postService,
// //     this._topicId,
// //     this._topicType, [
// //     PostsPagination? state,
// //   ]) : super(state ?? PostsPagination.initial()) {
// //     getPosts();
// //   }
// //
// //   // -----Fetch Posts
// //
// //   Future<void> getPosts() async {
// //     try {
// //       final currentPage = state.page ?? 0;
// //
// //       final posts =
// //           await _postService.getPosts(currentPage, _topicId, _topicType);
// //
// //       if (!mounted) return;
// //
// //       state = state.copyWith(
// //         posts: [
// //           ...state.posts ?? [], // Use empty list if state.posts is null.
// //           ...posts,
// //         ],
// //         page: currentPage + 1, // Increment page number
// //       );
// //     } on ErrorExceptionHandler catch (e) {
// //       if (!mounted) return;
// //
// //       state = state.copyWith(errorMessage: e.message);
// //     }
// //   }
// //
// //   // Future<void> getPosts() async {
// //   //   try {
// //   //     final posts =
// //   //         await _postService.getPosts(state.page!, _topicId, _topicType);
// //   //     state = state.copyWith(
// //   //       posts: [
// //   //         ...state.posts!,
// //   //         ...posts,
// //   //       ],
// //   //       page: state.page! + 1,
// //   //     );
// //   //   } on ErrorExceptionHandler catch (e) {
// //   //     state = state.copyWith(errorMessage: e.message);
// //   //   }
// //   // }
// //
// // // -------Reset Posts
// //   Future<void> resetPosts() async {
// //     state = state.clearPosts();
// //   }
// //
// //   // ---------Refresh Posts
// //   Future<void> refreshPost(String postId, int index) async {
// //     state = state.refreshPost(postId, index);
// //   }
// //
// //   // -------------Update Post View Count
// //   Future<void> postViews(String id, String views, int index) async {
// //     state = state.postViews(id, views, index);
// //   }
// //
// //   // Update Likes/Dislikes
// //   Future<void> likes(int id, String type, int like, int index) async {
// //     state = state.likes(id, type, like, index);
// //   }
// //
// //   // --------------Update Whats Share Count
// //   Future<void> whatsShare(String id, String share, int index) async {
// //     state = state.whatsShare(id, share, index);
// //   }
// //
// //   // --------------Update Comments Count
// //   Future<void> commentsCount(int index) async {
// //     state = state.commentCount(index);
// //   }
// //
// //   void handleScrollWithIndex(int index) {
// //     final itemPosition = index + 1;
// //     final requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
// //     final pageToRequest = itemPosition ~/ 10;
// //
// //     if (requestMoreData && pageToRequest + 1 >= state.page!) {
// //       getPosts();
// //     }
// //   }
// // }
