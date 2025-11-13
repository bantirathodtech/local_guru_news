import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/log/logging.dart';

import '../../../../../../src.dart';

final postPaginationControllerProvider =
    StateNotifierProvider<PostPaginationController, PostsPagination>((ref) {
  final selectedTopicId = ref.watch(topicId);
  final selectedTopicType = ref.watch(topicType);
  final userIdValue = ref.watch(userIdProvider);
  final landmarkIdValue = ref.watch(locationLandmark);
  final stateIdValue = ref.watch(locationState);
  final districtIdValue = ref.watch(locationDistrict);
  return PostPaginationController(
    selectedTopicId,
    selectedTopicType,
    userIdValue,
    landmarkIdValue,
    stateIdValue,
    districtIdValue,
  );
});

class PostPaginationController extends StateNotifier<PostsPagination> {
  final String topicId;
  final String topicType;
  final String userId;
  final String landmarkId;
  final String stateId;
  final String districtId;
  bool _isLoading = false;

  PostPaginationController(this.topicId, this.topicType, this.userId,
      this.landmarkId, this.stateId, this.districtId)
      : super(PostsPagination.initial()) {
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
        'getPosts called for topicId=$topicId, page=${state.page}, userId=$userId, stateId=$stateId, districtId=$districtId, landmarkId=$landmarkId');

    _isLoading = true;
    try {
      final currentPage = state.page ?? 1;
      final resolvedLandmarkId = _resolveLocationId(landmarkId);
      final resolvedStateId = _resolveLocationId(stateId);
      final resolvedDistrictId = _resolveLocationId(districtId);
      final posts = await PostPaginationService.fetchPosts(
        topicId: topicId,
        topicType: topicType,
        page: currentPage,
        userId: userId,
        landmarkId: resolvedLandmarkId,
        stateId: resolvedStateId,
        districtId: resolvedDistrictId,
        editorId: userId,
      );
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

String _resolveLocationId(String value) {
  if (value.isEmpty || value.toLowerCase() == 'null') {
    return '0';
  }
  return value;
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
