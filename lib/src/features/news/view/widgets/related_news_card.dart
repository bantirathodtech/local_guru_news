import 'dart:developer' as developer;

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_guru_all/src/core/constants/app_colors.dart';
import 'package:local_guru_all/src/core/log/logging.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../src.dart';

class RelatedNewsCard extends ConsumerWidget {
  final String? currentPostId;
  final int? currentPostIndex;
  final String? currentTopic;
  final List<PostsModel> allPosts;
  final int maxItems;

  const RelatedNewsCard({
    Key? key,
    required this.currentPostId,
    required this.currentPostIndex,
    required this.currentTopic,
    required this.allPosts,
    this.maxItems = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Filter related posts by topic, excluding current post
    final relatedPosts = allPosts
        .where((element) =>
            element.topic == currentTopic && element.id != currentPostId)
        .toList();

    if (relatedPosts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced Header Section
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                FontAwesomeIcons.newspaper,
                size: 18.sp,
                color: AppColors.accent,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'సంబంధిత వార్తలు',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${relatedPosts.length > maxItems ? maxItems : relatedPosts.length} related articles',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? Colors.grey.shade400
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16), // Reduced from 24
        // Related Posts List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              relatedPosts.length > maxItems ? maxItems : relatedPosts.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(
                bottom: index <
                        (relatedPosts.length > maxItems
                                ? maxItems
                                : relatedPosts.length) -
                            1
                    ? 12
                    : 0), // Reduced from 16
            child: RelatedNewsItem(
              post: relatedPosts[index],
              allPosts: allPosts,
            ),
          ),
        ),
      ],
    );
  }
}

class RelatedNewsItem extends ConsumerWidget {
  final PostsModel post;
  final List<PostsModel> allPosts;

  const RelatedNewsItem({
    Key? key,
    required this.post,
    required this.allPosts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Find the index of this post in the full posts list
    final postIndex = allPosts.indexWhere((p) => p.id == post.id);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.grey.shade700.withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              if (postIndex != -1 && post.id != null) {
                AppLogger.logInfo(
                  'Legacy related post tapped id=${post.id}',
                  tag: 'legacyNewsView',
                );
                // Update post views
                await ref
                    .read(legacyPostPaginationControllerProvider.notifier)
                    .postViews(
                      post.id!,
                      post.views ?? '0',
                      postIndex,
                    );

                // Set post ID in state
                ref.read(postId.notifier).state = post.id.toString();

                // Navigate to news details screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostViewScreen(
                      index: postIndex,
                      id: post.id,
                      layout: post.layout,
                      whatsCount: post.whatsApp,
                      description: post.description,
                    ),
                  ),
                );
              }
            } catch (e, stackTrace) {
              developer.log('Error navigating to related post: $e');
              AppLogger.logError('Legacy related post navigation failed: $e',
                  tag: 'legacyNewsView', stackTrace: stackTrace);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(12), // Reduced from 16
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Section
                _buildThumbnail(post, isDark),
                SizedBox(width: 12), // Reduced from 16
                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title
                      Text(
                        post.title ?? 'No title',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 8), // Reduced from 12
                      // Metadata Row
                      Row(
                        children: [
                          // Views
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade800.withOpacity(0.6)
                                  : AppColors.lightGrey.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FontAwesomeIcons.eye,
                                  size: 11.sp,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : AppColors.textSecondary,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  _formatViews(post.views ?? '0'),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : AppColors.textSecondary,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          // Time
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade800.withOpacity(0.6)
                                  : AppColors.lightGrey.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FontAwesomeIcons.clock,
                                  size: 11.sp,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : AppColors.textSecondary,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  post.readableTime ??
                                      (post.time != null
                                          ? TimeAgo.displayTimeAgoFromTimestamp(
                                              post.time!)
                                          : ''),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : AppColors.textSecondary,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatViews(String views) {
    try {
      final count = int.parse(views);
      if (count >= 1000000) {
        return '${(count / 1000000).toStringAsFixed(1)}M';
      } else if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(1)}K';
      } else {
        return views;
      }
    } catch (e) {
      return views;
    }
  }

  Widget _buildThumbnail(PostsModel post, bool isDark) {
    final hasVideo = post.layout?.toLowerCase() == 'video' ||
        post.layout?.toLowerCase() == 'youtube';

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _getThumbnailWidget(post, isDark),
          ),
          // Play button overlay for video content
          if (hasVideo)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getThumbnailWidget(PostsModel post, bool isDark) {
    if (post.layout == null || post.media == null || post.media!.isEmpty) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.article_outlined,
          color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
          size: 32,
        ),
      );
    }

    if (post.layout!.toLowerCase() == 'video') {
      final videoUrl = (post.media != null && post.media!.isNotEmpty)
          ? post.media!.first.toString()
          : '';
      if (videoUrl.isEmpty) {
        return _buildFallbackThumbnail(isDark);
      }
      return Container(
        width: 100,
        height: 100,
        color: Colors.black,
        child: VideoItems(
          videoPlayerController: VideoPlayerController.network(videoUrl),
          autoplay: false,
          looping: false,
          showControlles: false,
        ),
      );
    } else if (post.layout!.toLowerCase() == 'youtube') {
      final mediaUrl = (post.media != null && post.media!.isNotEmpty)
          ? post.media!.first.toString()
          : '';
      if (mediaUrl.isEmpty) {
        return _buildFallbackThumbnail(isDark);
      }
      final videoId = YoutubePlayer.convertUrlToId(mediaUrl);
      if (videoId != null && videoId.isNotEmpty) {
        return FancyShimmerImage(
          width: 100,
          height: 100,
          imageUrl: 'https://img.youtube.com/vi/$videoId/0.jpg',
          boxFit: BoxFit.cover,
          errorWidget: _buildFallbackThumbnail(isDark),
        );
      }
      return _buildFallbackThumbnail(isDark);
    } else {
      // Image layout
      final imageUrl = (post.media != null && post.media!.isNotEmpty)
          ? post.media!.first.toString()
          : '';
      if (imageUrl.isEmpty || !_isValidImageUrl(imageUrl)) {
        return _buildFallbackThumbnail(isDark);
      }
      return FancyShimmerImage(
        width: 100,
        height: 100,
        imageUrl: imageUrl,
        boxFit: BoxFit.cover,
        errorWidget: _buildFallbackThumbnail(isDark),
      );
    }
  }

  Widget _buildFallbackThumbnail(bool isDark) {
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
        size: 32,
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    if (url.startsWith('file:///')) return false;
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
