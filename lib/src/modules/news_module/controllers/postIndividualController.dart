import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src.dart';

final postIndividualControllerProvider =
    StateNotifierProvider<PostIndividualController, PostIndividualModel>((ref) {
  final postIndividualService = ref.read(postIndividualServiceProvider);
  final postIndividualId = ref.read(deepLinkPostId);
  return PostIndividualController(postIndividualService, postIndividualId);
});

class PostIndividualController extends StateNotifier<PostIndividualModel> {
  final PostIndividualService _postService;
  final int _id;

  PostIndividualController(
    this._postService,
    this._id, [
    PostIndividualModel? state,
  ]) : super(state ?? PostIndividualModel.initial()) {
    getPosts();
  }

  // -----Fetch Posts
  Future<void> getPosts() async {
    try {
      final posts = await _postService.getPosts(_id);
      state = state.copyWith(
        posts: [...posts],
        errorMessage: state.errorMessage,
      );
    } on ErrorExceptionHandler catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

  // -------Reset Posts
  Future<void> resetPosts() async {
    state = state.clearPosts();
  }

  // -------------Update Post View Count
  Future<void> postViews(String id, String views, int index) async {
    state = state.postViews(id, views, index);
  }

  // Update Likes/Dislikes
  Future<void> likes(int id, String type, int like, int index) async {
    state = state.likes(id, type, like, index);
  }

  // --------------Update Whats Share Count
  Future<void> whatsShare(String id, String share, int index) async {
    state = state.whatsShare(id, share, index);
  }

  // --------------Update Comments Count
  Future<void> commentsCount(String id, int index) async {
    state = state.commentCount(index);
  }
}
