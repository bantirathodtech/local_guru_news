import 'dart:developer' as developer;

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../src.dart';

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
    debugPrint('NewsLayoutComponent Properties:');
    debugPrint('ID: $id');
    debugPrint('Title: $title');
    debugPrint('Description: $description');
    debugPrint('Time: $time');
    debugPrint('Index: $index');
    debugPrint('Layout: $layout');
    debugPrint('Media: $media');
    debugPrint('Channel: $channel');
    debugPrint('Channel Image: $channelImage');
    debugPrint('Topic: $topic');
    debugPrint('Editor: $editor');
    debugPrint('View: $view');

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Channel Image
                  CircleAvatar(
                    backgroundColor: tempColor,
                    radius: 2.5.h,
                    backgroundImage: NetworkImage(channelImage ?? ''),
                  ),
                  // Channel Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Text(
                      channel ?? 'Unknown Channel',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.h),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.eye,
                      size: 14.sp,
                      color: Colors.blueGrey,
                    ),
                    SizedBox(width: 8),
                    Text(
                      view ?? '00',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Text(
              title ?? 'No Title Available',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                letterSpacing: 0.1,
                fontSize: 13.sp,
              ),
            ),
          ),

          // Media Content (Video or Image)
          (layout?.contains("Video") ?? false)
              ? _buildVideoPlayer(context)
              : (layout?.contains('Youtube') ?? false)
                  ? _buildYoutubeThumbnail(context)
                  : _buildImage(context),

          // Time Ago
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              time != null
                  ? TimeAgo.displayTimeAgoFromTimestamp(time!)
                  : 'Time not available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 7.sp,
              ),
            ),
          ),

          // Divider for Social/Bottom Data
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Divider(),
          ),
        ],
      ),
    );
  }

  // Method to build Video Player Widget
  Widget _buildVideoPlayer(BuildContext context) {
    try {
      String videoUrl = media?.first?.toString() ?? '';

      // Check if video URL is valid
      if (!_isValidUrl(videoUrl)) {
        developer.log('Invalid video URL: $videoUrl');
        return _buildFallbackImage(context);
      }

      // Initialize video player
      return Container(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            VideoItems(
              videoPlayerController: VideoPlayerController.network(videoUrl),
              autoplay: false,
              looping: false,
              showControlles: false,
            ),
            // Add an error handler overlay that can be triggered if needed
            ErrorOverlay(
              visible:
                  false, // This would be controlled by a state management solution
              message: "Video playback error. Tap to retry.",
              onRetry: () {
                developer.log('Video retry attempted for: $videoUrl');
              },
            ),
          ],
        ),
      );
    } catch (e) {
      developer.log('Error building video player: $e');
      return _buildFallbackImage(context);
    }
  }

  // Method to build YouTube Thumbnail with improved error handling
  Widget _buildYoutubeThumbnail(BuildContext context) {
    try {
      // First check if we already have a thumbnail URL
      String imageUrl = media?.first?.toString() ?? '';

      // Check if it's already a thumbnail URL
      if (imageUrl.contains('img.youtube.com/vi/')) {
        developer.log('Using provided YouTube thumbnail: $imageUrl');
        return FancyShimmerImage(
          width: MediaQuery.of(context).size.width,
          height: 30.h,
          imageUrl: imageUrl,
          boxFit: BoxFit.cover,
          errorWidget: _buildFallbackImage(context),
        );
      }

      // Try to extract video ID using built-in converter or fallback regex
      String? videoId = _extractYouTubeVideoId(imageUrl);
      if (videoId != null && videoId.isNotEmpty) {
        String thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';
        developer.log(
            'Generated YouTube thumbnail: $thumbnailUrl from ID: $videoId');
        return FancyShimmerImage(
          width: MediaQuery.of(context).size.width,
          height: 30.h,
          imageUrl: thumbnailUrl,
          boxFit: BoxFit.cover,
          errorWidget: _buildFallbackImage(context),
        );
      }

      developer.log('Failed to generate YouTube thumbnail, using fallback');
      return _buildFallbackImage(context);
    } catch (e) {
      developer.log('Error in YouTube thumbnail: $e');
      return _buildFallbackImage(context);
    }
  }

  // Method to build Image
  Widget _buildImage(BuildContext context) {
    try {
      String imageUrl = (media?.isNotEmpty == true &&
              (media?.first?.toString().length ?? 0) > 5)
          ? media?.first?.toString() ?? ''
          : channelImage ?? '';

      return FancyShimmerImage(
        width: MediaQuery.of(context).size.width,
        height: 30.h,
        imageUrl: imageUrl,
        boxFit: BoxFit.contain,
        errorWidget: _buildFallbackImage(context),
      );
    } catch (e) {
      developer.log('Error loading image: $e');
      return _buildFallbackImage(context);
    }
  }

  // Fallback image widget for error cases
  Widget _buildFallbackImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 30.h,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 50,
              color: Colors.grey[600],
            ),
            SizedBox(height: 10),
            Text(
              "Image not available",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Improved YouTube video ID extraction method
  String? _extractYouTubeVideoId(String url) {
    try {
      // First try the built-in converter from youtube_player_flutter
      var videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null && videoId.isNotEmpty) {
        return videoId;
      }

      // Fallback to regex method for different URL formats
      RegExp regExp = RegExp(
        r'(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      );

      Match? match = regExp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }

      // Handle short links and mobile links
      if (url.contains('youtu.be/')) {
        return url.split('youtu.be/')[1].split('?')[0];
      }

      developer.log('Failed to extract YouTube ID from: $url');
      return null;
    } catch (e) {
      developer.log('Error extracting YouTube ID: $e');
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
}

class ErrorOverlay extends StatelessWidget {
  final bool visible;
  final String message;
  final VoidCallback onRetry;

  const ErrorOverlay({
    Key? key,
    required this.visible,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!visible) return SizedBox.shrink();

    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 30),
            SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: onRetry,
              child: Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Video controls overlay
class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
