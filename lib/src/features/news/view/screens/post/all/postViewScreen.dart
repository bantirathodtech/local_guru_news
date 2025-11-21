import 'package:carousel_slider/carousel_slider.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
import 'package:local_guru_all/src/core/constants/app_colors.dart';
import 'package:local_guru_all/src/core/log/logging.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../../../src.dart';

class PostViewScreen extends StatefulWidget {
  final String? id;
  final int? index;
  final String? layout;
  final String? whatsCount;
  final String? description;

  const PostViewScreen({
    Key? key,
    this.id,
    this.index,
    this.layout,
    this.whatsCount,
    this.description,
  }) : super(key: key);

  @override
  _PostViewScreenState createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  YoutubePlayerController? _youtubeController;
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _scrollProgress =
            maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _youtubeController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer(
      builder: (context, ref, child) {
        final paginationState =
            ref.watch(legacyPostPaginationControllerProvider);
        AppLogger.logInfo(
          'Legacy PostViewScreen state posts=${paginationState.posts?.length ?? 0}',
          tag: 'legacyNewsView',
        );

        // Initialize YouTube controller for YouTube layout
        if (widget.layout == "Youtube" && paginationState.posts != null) {
          final post = paginationState.posts![widget.index!];
          if (post.media != null && post.media!.isNotEmpty) {
            final mediaUrl = post.media!.first.toString();
            final videoId = YoutubePlayer.convertUrlToId(mediaUrl);
            if (videoId != null && videoId.isNotEmpty) {
              _youtubeController = YoutubePlayerController(
                initialVideoId: videoId,
                flags: const YoutubePlayerFlags(
                  autoPlay: true,
                  mute: false,
                  showLiveFullscreenButton: true,
                ),
              );
            }
          }
        }

        return widget.layout == "Video"
            ? WillPopScope(
                onWillPop: () async {
                  Navigator.pop(context);
                  return Future.value(false);
                },
                child: Scaffold(
                  backgroundColor: Colors.black,
                  appBar: CustomAppBar(
                    title: 'Posts',
                    backgroundColor:
                        isDark ? Colors.grey.shade900 : AppColors.primary,
                    iconColor: isDark ? Colors.white : AppColors.black,
                    titleColor: isDark ? Colors.white : AppColors.black,
                  ),
                  bottomNavigationBar: _buildSocialBanner(paginationState),
                  body: _buildVideoContent(paginationState),
                ),
              )
            : widget.layout == "Youtube"
                ? WillPopScope(
                    onWillPop: () async {
                      Navigator.pop(context);
                      return Future.value(false);
                    },
                    child: Scaffold(
                      backgroundColor: Colors.black,
                      appBar: CustomAppBar(
                        title: 'Youtube',
                        backgroundColor:
                            isDark ? Colors.grey.shade900 : AppColors.primary,
                        iconColor: isDark ? Colors.white : AppColors.black,
                        titleColor: isDark ? Colors.white : AppColors.black,
                      ),
                      bottomNavigationBar: _buildSocialBanner(paginationState),
                      body: _buildYoutubeContent(paginationState),
                    ),
                  )
                : widget.layout == "Slider"
                    ? Scaffold(
                        backgroundColor: Colors.black,
                        appBar: CustomAppBar(
                          title: 'Slider',
                          backgroundColor:
                              isDark ? Colors.grey.shade900 : AppColors.primary,
                          iconColor: isDark ? Colors.white : AppColors.black,
                          titleColor: isDark ? Colors.white : AppColors.black,
                        ),
                        bottomNavigationBar:
                            _buildSocialBanner(paginationState),
                        body: _buildSliderContent(paginationState),
                      )
                    : Scaffold(
                        extendBodyBehindAppBar: true,
                        appBar: _buildTransparentAppBar(),
                        bottomNavigationBar:
                            _buildSocialBanner(paginationState),
                        body: Stack(
                          children: [
                            // Content starts from top with no padding
                            _buildDefaultContent(paginationState),
                            // Reading progress indicator
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 3,
                                child: LinearProgressIndicator(
                                  value: _scrollProgress,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.accent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
      },
    );
  }

  //bottom side
  Widget _buildSocialBanner(dynamic paginationState) {
    // Safely get the post data
    final post = paginationState.posts![widget.index!];

    // Safely get media image (handle empty list)
    String? imageUrl;
    if (post.media != null && post.media!.isNotEmpty) {
      final mediaItem = post.media!.first;
      if (mediaItem != null) {
        imageUrl = mediaItem.toString();
      }
    }

    // Get description (it's already a String, not a List)
    final description = post.description ?? '';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.grey.shade700.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SocialBanner(
        id: post.id ?? '',
        index: widget.index!,
        likes: post.likes ?? '0',
        dislikes: post.dislikes ?? '0',
        whatsCount: post.whatsApp ?? '0',
        liked: post.liked ?? '0',
        title: post.title ?? '',
        image: imageUrl ?? '',
        description: description,
        layout: post.layout ?? 'Text',
        comments: post.comments ?? '0',
        single: false,
      ),
    );
  }

  Widget _buildVideoContent(dynamic paginationState) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _buildChannelInfo(paginationState),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: Builder(
                builder: (context) {
                  final post = paginationState.posts![widget.index!];
                  if (post.media == null || post.media!.isEmpty) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 50),
                    );
                  }
                  final videoUrl = post.media!.first?.toString() ?? '';
                  if (videoUrl.isEmpty) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 50),
                    );
                  }
                  return VideoItems(
                    videoPlayerController:
                        VideoPlayerController.network(videoUrl),
                    autoplay: true,
                    looping: true,
                    showControlles: true,
                  );
                },
              ),
            ),
          ),
          _buildBottomContent(paginationState),
        ],
      ),
    );
  }

  Widget _buildYoutubeContent(dynamic paginationState) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _buildChannelInfo(paginationState),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: _youtubeController != null
                  ? YoutubePlayer(
                      controller: _youtubeController!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.red,
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          _buildBottomContent(paginationState),
        ],
      ),
    );
  }

  Widget _buildSliderContent(dynamic paginationState) {
    final post = paginationState.posts![widget.index!];
    final mediaList = post.media ?? [];

    // If no media, show error placeholder
    if (mediaList.isEmpty) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: _buildChannelInfo(paginationState),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, size: 50),
              ),
            ),
            _buildBottomContent(paginationState),
          ],
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _buildChannelInfo(paginationState),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CarouselSlider(
                  items: mediaList
                      .map<Widget>((e) => _buildCarouselItem(e))
                      .toList(),
                  options: CarouselOptions(
                    height: 30.h,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    viewportFraction: 1.0,
                    autoPlay: mediaList.length > 1,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayCurve: Curves.ease,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() => _current = index);
                    },
                  ),
                ),
                if (mediaList.length > 1) _buildCarouselDots(paginationState),
              ],
            ),
          ),
          _buildBottomContent(paginationState),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTransparentAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Share functionality
                },
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent(dynamic paginationState) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero, // No padding - content starts from top
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hero image section - starts from top with no spacing
          _buildPostImage(paginationState),

          // Content section with card design - overlapping with image
          Transform.translate(
            offset: Offset(0,
                -100), // Overlap image to ensure no gap and seamless connection
            child: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Channel Info
                        _buildChannelInfo(paginationState),
                        SizedBox(height: 24),

                        // Title with premium typography
                        _buildPostTitle(paginationState),
                        SizedBox(height: 20),

                        // Metadata
                        _buildPostMetadata(paginationState),
                        SizedBox(height: 32),

                        // Divider
                        Builder(
                          builder: (context) {
                            final theme = Theme.of(context);
                            final isDark = theme.brightness == Brightness.dark;
                            return Divider(
                              height: 1,
                              thickness: 1,
                              color: isDark
                                  ? Colors.grey.shade700
                                  : AppColors.lightGrey,
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        // Description/Content with optimal reading width
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 680),
                            child:
                                _buildPostDescription(paginationState, context),
                          ),
                        ),

                        // Editor Info if available
                        if (paginationState.posts![widget.index!].editor !=
                            null) ...[
                          Builder(
                            builder: (context) {
                              final theme = Theme.of(context);
                              final isDark =
                                  theme.brightness == Brightness.dark;
                              return Divider(
                                height: 1,
                                thickness: 1,
                                color: isDark
                                    ? Colors.grey.shade700
                                    : AppColors.lightGrey,
                              );
                            },
                          ),
                          _buildEditorInfo(paginationState),
                        ],

                        Builder(
                          builder: (context) {
                            final theme = Theme.of(context);
                            final isDark = theme.brightness == Brightness.dark;
                            return Divider(
                              height: 1,
                              thickness: 1,
                              color: isDark
                                  ? Colors.grey.shade700
                                  : AppColors.lightGrey,
                            );
                          },
                        ),
                        // Related Posts
                        RelatedNewsCard(
                          currentPostId: widget.id,
                          currentPostIndex: widget.index,
                          currentTopic:
                              paginationState.posts![widget.index!].topic,
                          allPosts: paginationState.posts!,
                          maxItems: 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelInfo(dynamic paginationState) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Safely get the post data
    final post = paginationState.posts![widget.index!];

    // Safely get channel image URL
    String? channelImageUrl;
    if (post.channelImage != null && post.channelImage!.isNotEmpty) {
      channelImageUrl = post.channelImage.toString();
    }

    // Get channel name and readable time with safe defaults
    final channelName = post.channel ?? 'Unknown Channel';
    final readableTime = post.readableTime ??
        (post.time != null
            ? TimeAgo.displayTimeAgoFromTimestamp(post.time!)
            : 'Time not available');

    return Row(
      children: [
        // Channel Avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : AppColors.lightGrey,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor:
                isDark ? Colors.grey.shade800 : AppColors.lightGrey,
            backgroundImage:
                channelImageUrl != null && channelImageUrl.isNotEmpty
                    ? NetworkImage(channelImageUrl)
                    : null,
            child: channelImageUrl == null || channelImageUrl.isEmpty
                ? Icon(
                    Icons.newspaper,
                    color:
                        isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                    size: 28,
                  )
                : null,
          ),
        ),
        SizedBox(width: 16),
        // Channel Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channelName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.clock,
                    size: 12.sp,
                    color:
                        isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    readableTime,
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey.shade400
                          : AppColors.textSecondary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomContent(dynamic paginationState) {
    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paginationState.posts![widget.index!].title ?? 'No Title',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(FontAwesomeIcons.eye, size: 12.sp, color: Colors.white70),
                SizedBox(width: 1.w),
                Text(
                  '${paginationState.posts![widget.index!].views ?? '0'} views',
                  style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () {
                    // Fullscreen functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FancyShimmerImage(
          width: MediaQuery.of(context).size.width,
          height: 250,
          imageUrl: imageUrl,
          boxFit: BoxFit.cover,
          errorWidget: Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselDots(dynamic paginationState) {
    final post = paginationState.posts![widget.index!];
    final mediaList = post.media ?? [];

    if (mediaList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: mediaList.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == index ? Colors.red : Colors.white,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPostImage(dynamic paginationState) {
    final post = paginationState.posts![widget.index!];
    final mediaList = post.media ?? [];

    // Get image URL safely
    String? imageUrl;
    if (mediaList.isNotEmpty) {
      final mediaItem = mediaList.first;
      if (mediaItem != null) {
        imageUrl = mediaItem.toString();
      }
    }

    // If no valid image URL, don't show anything
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      height: 50.h, // Fixed height for consistent layout
      color: isDark
          ? Colors.grey.shade900
          : Colors.white, // Background to match theme
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image container that shows full image without cropping
          Center(
            child: FancyShimmerImage(
              width: screenWidth,
              height: 50.h,
              imageUrl: imageUrl,
              boxFit: BoxFit
                  .contain, // Contain shows full image without cropping or zooming
              errorWidget: Container(
                color: AppColors.lightGrey,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          // Multi-stop gradient overlay for better text readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Top gradient for app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTitle(dynamic paginationState) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final post = paginationState.posts![widget.index!];
    return Text(
      post.title ?? 'No Title Available',
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 22.sp,
        letterSpacing: -0.3,
        height: 1.3,
        color: isDark ? Colors.white : AppColors.textPrimary,
        fontFamily: 'Roboto',
      ),
    );
  }

  Widget _buildPostMetadata(dynamic paginationState) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final post = paginationState.posts![widget.index!];
    final readableTime = post.readableTime ??
        (post.time != null
            ? TimeAgo.displayTimeAgoFromTimestamp(post.time!)
            : 'Time not available');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withOpacity(0.5)
            : AppColors.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.eye,
            size: 14.sp,
            color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
          ),
          SizedBox(width: 8),
          Text(
            '${post.views ?? '0'} views',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 20),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade500 : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 20),
          Icon(
            FontAwesomeIcons.clock,
            size: 14.sp,
            color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
          ),
          SizedBox(width: 8),
          Text(
            readableTime,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String removeImgTags(String htmlContent) {
    final imgTagRegex = RegExp(r'<img[^>]*>', caseSensitive: false);
    return htmlContent.replaceAll(imgTagRegex, '');
  }

  Widget _buildPostDescription(
    dynamic paginationState,
    BuildContext buildContext,
  ) {
    final theme = Theme.of(buildContext);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    final post = paginationState.posts![widget.index!];
    final fullDescription = post.fulldescription ?? post.description ?? '';
    final descriptionWithoutImgs = removeImgTags(fullDescription);

    return Html(
      data: descriptionWithoutImgs,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(18.sp),
          lineHeight: LineHeight(1.8),
          color: textColor,
          fontFamily: 'Roboto',
          letterSpacing: 0.3,
        ),
        "p": Style(
          margin: Margins.only(bottom: 24),
          fontSize: FontSize(18.sp),
          lineHeight: LineHeight(1.8),
          color: textColor,
          letterSpacing: 0.3,
        ),
        "h1": Style(
          margin: Margins.only(bottom: 20, top: 32),
          fontSize: FontSize(26.sp),
          fontWeight: FontWeight.w800,
          color: textColor,
          lineHeight: LineHeight(1.3),
        ),
        "h2": Style(
          margin: Margins.only(bottom: 16, top: 28),
          fontSize: FontSize(22.sp),
          fontWeight: FontWeight.w700,
          color: textColor,
          lineHeight: LineHeight(1.35),
        ),
        "h3": Style(
          margin: Margins.only(bottom: 14, top: 24),
          fontSize: FontSize(20.sp),
          fontWeight: FontWeight.w600,
          color: textColor,
          lineHeight: LineHeight(1.4),
        ),
        "strong": Style(
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        "em": Style(
          fontStyle: FontStyle.italic,
        ),
        "a": Style(
          color: AppColors.accent,
          textDecoration: TextDecoration.underline,
        ),
        "ul": Style(
          margin: Margins.only(bottom: 16, left: 16),
        ),
        "ol": Style(
          margin: Margins.only(bottom: 16, left: 16),
        ),
        "li": Style(
          margin: Margins.only(bottom: 8),
          fontSize: FontSize(18.sp),
          lineHeight: LineHeight(1.8),
        ),
        "blockquote": Style(
          margin: Margins.symmetric(vertical: 16, horizontal: 0),
          padding: HtmlPaddings.only(left: 20),
          border: Border(
            left: BorderSide(
              color: AppColors.accent,
              width: 4,
            ),
          ),
          fontStyle: FontStyle.italic,
          color: AppColors.textSecondary,
        ),
      },
    );
  }

  Widget _buildEditorInfo(dynamic paginationState) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Posted By',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: FancyShimmerImage(
                    imageUrl: paginationState
                        .posts![widget.index!].editorProfile
                        .toString(),
                    boxFit: BoxFit.cover,
                    errorWidget: Container(
                      color: isDark ? Colors.grey.shade700 : Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paginationState.posts![widget.index!].editor ??
                          'Unknown Editor',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Editor',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.message,
                  size: 20.sp,
                  color:
                      isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                ),
                onPressed: () {
                  // Contact editor functionality
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
