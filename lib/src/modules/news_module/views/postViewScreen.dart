import 'package:carousel_slider/carousel_slider.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../src.dart';

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

class _PostViewScreenState extends State<PostViewScreen> {
  int _current = 0;
  YoutubePlayerController? _youtubeController;

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.watch(postPaginationControllerProvider);
        final paginationState =
            ref.watch(postPaginationControllerProvider.notifier).state;

        // Initialize YouTube controller for YouTube layout
        if (widget.layout == "Youtube" && paginationState.posts != null) {
          final videoId = YoutubePlayer.convertUrlToId(
            paginationState.posts![widget.index!].media!.first,
          );
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId ?? '',
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              showLiveFullscreenButton: true,
            ),
          );
        }

        return widget.layout == "Video"
            ? WillPopScope(
                onWillPop: () async {
                  Navigator.pop(context);
                  return Future.value(false);
                },
                child: Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: Colors.white,
                      ),
                    ),
                    elevation: 0.5,
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
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        leading: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.keyboard_arrow_left_rounded,
                            color: Colors.white,
                          ),
                        ),
                        elevation: 0.5,
                      ),
                      bottomNavigationBar: _buildSocialBanner(paginationState),
                      body: _buildYoutubeContent(paginationState),
                    ),
                  )
                : widget.layout == "Slider"
                    ? Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          leading: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.keyboard_arrow_left_rounded,
                              color: Colors.white,
                            ),
                          ),
                          elevation: 0.5,
                        ),
                        bottomNavigationBar:
                            _buildSocialBanner(paginationState),
                        body: _buildSliderContent(paginationState),
                      )
                    : Scaffold(
                        appBar: AppBar(
                          leading: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.keyboard_arrow_left_rounded,
                              color: Colors.black,
                            ),
                          ),
                          elevation: 0.5,
                        ),
                        bottomNavigationBar:
                            _buildSocialBanner(paginationState),
                        body: _buildDefaultContent(paginationState),
                      );
      },
    );
  }

  Widget _buildSocialBanner(dynamic paginationState) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SocialBanner(
        id: paginationState.posts![widget.index!].id!,
        index: widget.index!,
        likes: paginationState.posts![widget.index!].likes!,
        dislikes: paginationState.posts![widget.index!].dislikes!,
        whatsCount: paginationState.posts![widget.index!].whatsApp!,
        liked: paginationState.posts![widget.index!].liked!,
        title: paginationState.posts![widget.index!].title!,
        image: paginationState.posts![widget.index!].media![0]!,
        description: paginationState.posts![widget.index!].description![0],
        layout: paginationState.posts![widget.index!].layout!,
        comments: paginationState.posts![widget.index!].comments!,
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
          _buildChannelInfo(paginationState),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: VideoItems(
                videoPlayerController: VideoPlayerController.network(
                  paginationState.posts![widget.index!].media!.first,
                ),
                autoplay: true,
                looping: true,
                showControlles: true,
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
          _buildChannelInfo(paginationState),
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
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.all(10),
      child: Stack(
        children: [
          _buildChannelInfo(paginationState),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CarouselSlider(
                  items: paginationState.posts![widget.index!].media!
                      .map<Widget>((e) => _buildCarouselItem(e))
                      .toList(),
                  options: CarouselOptions(
                    height: 30.h,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    viewportFraction: 1.0,
                    autoPlay:
                        paginationState.posts![widget.index!].media!.length > 1,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayCurve: Curves.ease,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() => _current = index);
                    },
                  ),
                ),
                if (paginationState.posts![widget.index!].media!.length > 1)
                  _buildCarouselDots(paginationState),
              ],
            ),
          ),
          _buildBottomContent(paginationState),
        ],
      ),
    );
  }

  // Widget _buildDefaultContent(dynamic paginationState) {
  //   return SingleChildScrollView(
  //     physics: const BouncingScrollPhysics(),
  //     child: Container(
  //       margin: const EdgeInsets.all(8),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           _buildChannelInfo(paginationState),
  //           _buildPostImage(paginationState),
  //           _buildPostTitle(paginationState),
  //           _buildPostMetadata(paginationState),
  //           // _buildPostDescription(paginationState),
  //           _buildPostDescription(paginationState, context), // Pass context
  //           if (paginationState.posts![widget.index!].editor != null)
  //             _buildEditorInfo(paginationState),
  //           const Divider(height: 0.5),
  //           _buildRelatedPosts(paginationState),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildDefaultContent(dynamic paginationState) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8), // 16px horizontal margin
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChannelInfo(paginationState),
            _buildPostImage(paginationState),
            _buildPostTitle(paginationState),
            _buildPostMetadata(paginationState),
            _buildPostDescription(paginationState, context), // Pass context
            if (paginationState.posts![widget.index!].editor != null)
              _buildEditorInfo(paginationState),
            const Divider(height: 0.5),
            _buildRelatedPosts(paginationState),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelInfo(dynamic paginationState) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: tempColor,
          radius: 2.5.h,
          backgroundImage: NetworkImage(
            paginationState.posts![widget.index!].channelImage.toString(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.5.h),
            child: Text(
              paginationState.posts![widget.index!].channel!,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomContent(dynamic paginationState) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 250,
        child: Stack(
          children: [
            Positioned(
              bottom: 60,
              right: 5,
              left: 5,
              child: Text(
                paginationState.posts![widget.index!].title!,
                style: TextStyle(color: Colors.white, fontSize: 10.sp),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 5,
              left: 5,
              child: _buildChannelInfo(paginationState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(String imageUrl) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: FancyShimmerImage(
        width: MediaQuery.of(context).size.width,
        height: 250,
        imageUrl: imageUrl,
        boxFit: BoxFit.contain,
        errorWidget: Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildCarouselDots(dynamic paginationState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          paginationState.posts![widget.index!].media!.map<Widget>((event) {
        int index = paginationState.posts![widget.index!].media!.indexOf(event);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index ? Colors.red : Colors.white,
              border: Border.all(color: Colors.black.withOpacity(0.5)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPostImage(dynamic paginationState) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: FancyShimmerImage(
        width: MediaQuery.of(context).size.width,
        height: 30.h,
        imageUrl: paginationState.posts![widget.index!].media!.first,
        boxFit: BoxFit.contain,
        errorWidget: Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildPostTitle(dynamic paginationState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        paginationState.posts![widget.index!].title!,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18.sp,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildPostMetadata(dynamic paginationState) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h, horizontal: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            paginationState.posts![widget.index!].readableTime!,
            style: TextStyle(color: Colors.grey, fontSize: 8.sp),
          ),
          Row(
            children: [
              Icon(FontAwesomeIcons.eye, size: 13.sp, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Text(
                '${paginationState.posts![widget.index!].views!} వీక్షించారు',
                style: TextStyle(color: Colors.blueGrey, fontSize: 8.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildPostDescription(dynamic paginationState) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 1.h),
  //     child: Html(
  //       data: paginationState.posts![widget.index!].fulldescription!,
  //     ),
  //   );
  // }
  Widget _buildPostDescription(
      dynamic paginationState, BuildContext buildContext) {
    return Html(
      data: paginationState.posts![widget.index!].fulldescription!,
      // shrinkWrap: true, // Ensure Html doesn't constrain content
      // style: {
      //   "img": Style(
      //     width: Width(MediaQuery.of(buildContext).size.width - 32),
      //     height: Height(30.h),
      //     padding: HtmlPaddings.symmetric(horizontal: 16.0, vertical: 1.h),
      //   ),
      // },
      extensions: [
        TagExtension(
          tagsToExtend: {"img"},
          builder: (ExtensionContext context) {
            final src = context.attributes['src'] ?? '';
            return src.isNotEmpty
                ? FancyShimmerImage(
                    width: MediaQuery.of(buildContext).size.width -
                        32, // Full width minus 16px padding
                    height: 8.h, // Match _buildPostImage height
                    imageUrl: src,
                    boxFit: BoxFit.contain,
                    errorWidget: Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  )
                : Container(); // Return empty widget if src is empty
          },
        ),
      ],
      // --- END OF UPDATED CODE ---
    );
  }

  Widget _buildEditorInfo(dynamic paginationState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Posted By', style: TextStyle(fontSize: 10)),
        ),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: tempColor,
              backgroundImage: NetworkImage(
                paginationState.posts![widget.index!].editorProfile.toString(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  paginationState.posts![widget.index!].editor!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRelatedPosts(dynamic paginationState) {
    final relatedPosts = paginationState.posts!
        .where((element) =>
            element.topic == paginationState.posts![widget.index!].topic &&
            element.id != widget.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'సంబంధిత వార్తలు',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: relatedPosts.length > 10 ? 10 : relatedPosts.length,
          itemBuilder: (context, index) =>
              _buildRelatedPostItem(relatedPosts[index]),
        ),
      ],
    );
  }

  Widget _buildRelatedPostItem(PostsModel post) {
    return InkWell(
      onTap: () {
        // Navigation logic here
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 12.h,
          child: Row(
            children: [
              _buildRelatedPostThumbnail(post),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(
                    //   post.title!,
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: TextStyle(
                    //       fontSize: 10.sp, fontWeight: FontWeight.w500),
                    // ),
                    Text(
                      // --- START OF UPDATED CODE ---
                      post.title ?? 'No title', // Fallback for null title
                      // --- END OF UPDATED CODE ---
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w500),
                    ),
                    // Row(
                    //   children: [
                    //     Icon(FontAwesomeIcons.eye,
                    //         size: 8.sp, color: Colors.blueGrey),
                    //     const SizedBox(width: 8),
                    //     Text(
                    //       '${post.views!} వీక్షించారు',
                    //       style:
                    //           TextStyle(color: Colors.blueGrey, fontSize: 8.sp),
                    //     ),
                    //   ],
                    // ),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.eye,
                            size: 8.sp, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Text(
                          // --- START OF UPDATED CODE ---
                          '${post.views ?? 0} వీక్షించారు',
                          // Fallback for null views
                          // --- END OF UPDATED CODE ---
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 8.sp),
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
    );
  }

  Widget _buildRelatedPostThumbnail(PostsModel post) {
    if (post.layout == null || post.media == null || post.media!.isEmpty) {
      return Container(
        height: 10.h,
        width: 12.h,
        color: Colors.grey[300],
        child: const Icon(Icons.error),
      );
    }
    if (post.layout!.toLowerCase() == 'video') {
      return SizedBox(
        height: 10.h,
        width: 12.h,
        child: VideoItems(
          videoPlayerController: VideoPlayerController.network(post.media![0]),
          autoplay: false,
          looping: false,
          showControlles: false,
        ),
      );
    } else if (post.layout!.toLowerCase() == 'youtube') {
      final videoId = YoutubePlayer.convertUrlToId(post.media!.first);
      return FancyShimmerImage(
        height: 10.h,
        width: 12.h,
        imageUrl: 'https://img.youtube.com/vi/${videoId ?? ''}/0.jpg',
        boxFit: BoxFit.cover,
        errorWidget: Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      );
    } else {
      return FancyShimmerImage(
        height: 10.h,
        width: 12.h,
        imageUrl: post.media!.first,
        boxFit: BoxFit.cover,
        errorWidget: Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      );
    }
  }
}
