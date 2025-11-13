import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/log/logging.dart';
import 'package:local_guru_all/src/core/api/shared/state/app_state.dart';
import 'package:local_guru_all/src/features/news/data/model/posts/all/postsPaginationModel.dart';
import 'package:local_guru_all/src/features/news/data/repository/post/old_api/all/postPaginationService.dart';

/// Legacy pagination controller that keeps the previous Riverpod flow
/// operational. Useful when managers still rely on the stable PHP endpoint.
final legacyPostPaginationControllerProvider =
    StateNotifierProvider<LegacyPostPaginationController, PostsPagination>(
        (ref) {
  final selectedTopicId = ref.watch(topicId);
  final selectedTopicType = ref.watch(topicType);
  final userIdValue = ref.watch(userIdProvider);

  return LegacyPostPaginationController(
    topicId: selectedTopicId,
    topicType: selectedTopicType,
    userId: userIdValue,
  );
});

class LegacyPostPaginationController extends StateNotifier<PostsPagination> {
  LegacyPostPaginationController({
    required this.topicId,
    required this.topicType,
    required this.userId,
  }) : super(PostsPagination.initial()) {
    getPosts();
  }

  final String topicId;
  final String topicType;
  final String userId;

  bool _isLoading = false;

  Future<void> getPosts() async {
    if (_isLoading) {
      AppLogger.logInfo('Legacy getPosts skipped: already running',
          tag: 'legacyPostPagination');
      return;
    }

    _isLoading = true;
    try {
      final currentPage = state.page ?? 1;
      AppLogger.logInfo(
        'Legacy getPosts(page=$currentPage, topicId=$topicId, topicType=$topicType)',
        tag: 'legacyPostPagination',
      );

      final posts = await LegacyPostPaginationService.fetchPosts(
        topicId: topicId,
        topicType: topicType,
        page: currentPage,
        userId: userId,
      );

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
    final requestMoreData =
        itemPosition % LegacyPostPaginationService.pageSize == 0;
    final pageToRequest = itemPosition ~/ LegacyPostPaginationService.pageSize;
    if (requestMoreData && pageToRequest + 1 >= (state.page ?? 1)) {
      getPosts();
    }
  }
}
