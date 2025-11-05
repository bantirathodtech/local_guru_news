import 'dart:developer' as developer;

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_guru_all/src/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../src.dart';

class NewsLayoutComponent extends StatelessWidget {
  final String? id;
  final String? title;
  final String? description;
  final String? layout;
  final List? media;
  final String? channel;
  final String? channelImage;
  final String? topic;
  final String? editor;
  final String? time;
  final String? view;
  final int? index;

  const NewsLayoutComponent({
    Key? key,
    this.id,
    this.title,
    this.description,
    this.time,
    this.index,
    this.layout,
    this.media,
    this.channel,
    this.channelImage,
    this.topic,
    this.editor,
    this.view,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasMedia = (layout?.contains("Video") ?? false) ||
        (layout?.contains('Youtube') ?? false) ||
        (media?.isNotEmpty == true &&
            _isValidImageUrl(media?.first?.toString() ?? ''));

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image Section
          if (hasMedia)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  (layout?.contains("Video") ?? false)
                      ? _buildVideoPlayer(context)
                      : (layout?.contains('Youtube') ?? false)
                          ? _buildYoutubeThumbnail(context)
                          : _buildImage(context),
                  // Gradient overlay for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Topic badge if available
                  if (topic != null && topic!.isNotEmpty)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          topic!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Content Section
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Channel Info Row
                Row(
                  children: [
                    // Channel Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.lightGrey,
                        backgroundImage: _isValidImageUrl(channelImage)
                            ? NetworkImage(channelImage!)
                            : null,
                        child: _isValidImageUrl(channelImage)
                            ? null
                            : Icon(
                                Icons.newspaper,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Channel Name and Metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            channel ?? 'Unknown Channel',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.clock,
                                size: 11.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                time != null
                                    ? TimeAgo.displayTimeAgoFromTimestamp(time!)
                                    : 'Just now',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 16),
                              Icon(
                                FontAwesomeIcons.eye,
                                size: 11.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                _formatViews(view ?? '0'),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Title with premium typography
                Text(
                  title ?? 'No Title Available',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.35,
                    letterSpacing: -0.3,
                    fontFamily: 'Roboto',
                  ),
                ),

                // Description preview (if available and no image)
                if (!hasMedia &&
                    description != null &&
                    description!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    description!.length > 120
                        ? '${description!.substring(0, 120)}...'
                        : description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Format views count (e.g., 1000 -> 1K)
  String _formatViews(String views) {
    try {
      final count = int.parse(views);
      if (count >= 1000000) {
        return '${(count / 1000000).toStringAsFixed(1)}M';
      } else if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(1)}K';
      }
      return views;
    } catch (e) {
      return views;
    }
  }

  // Method to build Video Player Widget
  Widget _buildVideoPlayer(BuildContext context) {
    try {
      String videoUrl = media?.first?.toString() ?? '';

      if (!_isValidUrl(videoUrl)) {
        return _buildFallbackImage(context);
      }

      return Container(
        height: 45.h,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            VideoItems(
              videoPlayerController: VideoPlayerController.network(videoUrl),
              autoplay: false,
              looping: false,
              showControlles: false,
            ),
            // Play button overlay
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      developer.log('Error building video player: $e');
      return _buildFallbackImage(context);
    }
  }

  // Method to build YouTube Thumbnail
  Widget _buildYoutubeThumbnail(BuildContext context) {
    try {
      String imageUrl = media?.first?.toString() ?? '';

      if (imageUrl.contains('img.youtube.com/vi/')) {
        return _buildImageWithPlayButton(context, imageUrl);
      }

      String? videoId = _extractYouTubeVideoId(imageUrl);
      if (videoId != null && videoId.isNotEmpty) {
        String thumbnailUrl =
            'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
        return _buildImageWithPlayButton(context, thumbnailUrl);
      }

      return _buildFallbackImage(context);
    } catch (e) {
      developer.log('Error in YouTube thumbnail: $e');
      return _buildFallbackImage(context);
    }
  }

  Widget _buildImageWithPlayButton(BuildContext context, String imageUrl) {
    return Container(
      height: 45.h,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          FancyShimmerImage(
            width: MediaQuery.of(context).size.width,
            height: 45.h,
            imageUrl: imageUrl,
            boxFit: BoxFit.cover,
            errorWidget: _buildFallbackImage(context),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                FontAwesomeIcons.play,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build Image
  Widget _buildImage(BuildContext context) {
    try {
      String? imageUrl;

      if (media?.isNotEmpty == true &&
          (media?.first?.toString().length ?? 0) > 5) {
        final mediaUrl = media?.first?.toString() ?? '';
        if (_isValidImageUrl(mediaUrl)) {
          imageUrl = mediaUrl;
        }
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        if (_isValidImageUrl(channelImage)) {
          imageUrl = channelImage;
        }
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        return SizedBox.shrink();
      }

      return Container(
        width: MediaQuery.of(context).size.width,
        height: 45.h,
        child: FancyShimmerImage(
          width: MediaQuery.of(context).size.width,
          height: 45.h,
          imageUrl: imageUrl,
          boxFit: BoxFit.cover,
          errorWidget: SizedBox.shrink(),
        ),
      );
    } catch (e) {
      developer.log('Error loading image: $e');
      return SizedBox.shrink();
    }
  }

  // Fallback image widget
  Widget _buildFallbackImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 45.h,
      color: AppColors.lightGrey,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // Improved YouTube video ID extraction method
  String? _extractYouTubeVideoId(String url) {
    try {
      var videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null && videoId.isNotEmpty) {
        return videoId;
      }

      RegExp regExp = RegExp(
        r'(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      );

      Match? match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }

      if (url.contains('youtu.be/')) {
        return url.split('youtu.be/')[1].split('?')[0];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Utility method to validate a URL
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Utility method to validate an image URL
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    if (url.startsWith('file:///') || url.trim().isEmpty) {
      return false;
    }

    return _isValidUrl(url);
  }
}
