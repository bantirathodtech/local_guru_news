import 'package:carousel_slider/carousel_slider.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
// import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

import '../../../src.dart';

class SinglePostView extends StatefulWidget {
  const SinglePostView({Key? key}) : super(key: key);

  @override
  _SinglePostViewState createState() => _SinglePostViewState();
}

class _SinglePostViewState extends State<SinglePostView> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.watch(postIndividualControllerProvider);
        final paginationState =
            ref.watch(postIndividualControllerProvider.notifier).state;

        return Builder(
          builder: (context) {
            return Builder(builder: (context) {
              if (paginationState.refreshError) {
                return Scaffold(
                  body: Center(
                    child: ErrorBody(
                      message: paginationState.errorMessage,
                    ),
                  ),
                );
              } else if (paginationState.posts!.isEmpty) {
                return Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewsDashboard()),
                        (route) => false,
                      ),
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  body: Center(
                    child: DelayedDisplay(
                      // delay: Duration(seconds: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.featured_play_list_rounded,
                            size: 30,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text('No Posts Available'),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return paginationState.posts![0].layout == "Video"
                    ? Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          leading: IconButton(
                            onPressed: () async {
                              ref.read(postPaginationControllerProvider);

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewsDashboard()),
                                  (route) => false);
                            },
                            icon: Icon(
                              Icons.keyboard_arrow_left_rounded,
                              color: Colors.white,
                            ),
                          ),
                          elevation: 0.5,
                        ),
                        bottomNavigationBar: Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: SocialBanner(
                            id: paginationState.posts![0].id!,
                            index: 0,
                            likes: paginationState.posts![0].likes!,
                            dislikes: paginationState.posts![0].dislikes!,
                            whatsCount: paginationState.posts![0].whatsApp!,
                            liked: paginationState.posts![0].liked!,
                            title: paginationState.posts![0].title!,
                            description: paginationState.posts![0].description!,
                            image: paginationState.posts![0].media![0]!,
                            layout: paginationState.posts![0].layout!,
                            comments: paginationState.posts![0].comments!,
                            single: true,
                          ),
                        ),
                        body: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          margin: EdgeInsets.all(
                            10,
                          ),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: tempColor,
                                    radius: 2.5.h,
                                    backgroundImage: NetworkImage(
                                      paginationState.posts![0].channelImage
                                          .toString(),
                                    ),
                                  ),

                                  // channel Name
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 1.5.h,
                                      ),
                                      child: Text(
                                        paginationState.posts![0].channel!,
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
                              ),
                              // Video Playback
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: 250,
                                  width: MediaQuery.of(context).size.width,
                                  child: VideoItems(
                                    videoPlayerController:
                                        VideoPlayerController.network(
                                      paginationState.posts![0].media!.first,
                                    ),
                                    autoplay: true,
                                    looping: true,
                                    showControlles: true,
                                  ),
                                ),
                              ),

                              // Bottom
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 250,
                                  child: Stack(
                                    children: [
                                      // Title
                                      Positioned(
                                        bottom: 60,
                                        right: 5,
                                        left: 5,
                                        child: Text(
                                          '${paginationState.posts![0].title!}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        right: 5,
                                        left: 5,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: tempColor,
                                              radius: 2.5.h,
                                              backgroundImage: NetworkImage(
                                                paginationState
                                                    .posts![0].editorProfile
                                                    .toString(),
                                              ),
                                            ),

                                            // Editor Name
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 1.5.h,
                                                ),
                                                child: Text(
                                                  paginationState
                                                      .posts![0].editor!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : paginationState.posts![0].layout == "Youtube"
                        ? WillPopScope(
                            onWillPop: () async {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NewsDashboard()),
                                  (route) => false);
                              return Future.value(false);
                            },
                            child: Scaffold(
                              backgroundColor: Colors.black,
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                leading: IconButton(
                                  onPressed: () {
                                    ref.read(postPaginationControllerProvider);

                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NewsDashboard()),
                                        (route) => false);
                                  },
                                  icon: Icon(
                                    Icons.keyboard_arrow_left_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                elevation: 0.5,
                              ),
                              bottomNavigationBar: Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: SocialBanner(
                                  id: paginationState.posts![0].id!,
                                  index: 0,
                                  likes: paginationState.posts![0].likes!,
                                  dislikes: paginationState.posts![0].dislikes!,
                                  whatsCount:
                                      paginationState.posts![0].whatsApp!,
                                  liked: paginationState.posts![0].liked!,
                                  title: paginationState.posts![0].title!,
                                  description:
                                      paginationState.posts![0].description!,
                                  image: paginationState.posts![0].media![0]!,
                                  layout: paginationState.posts![0].layout!,
                                  comments: paginationState.posts![0].comments!,
                                  single: true,
                                ),
                              ),
                              body: Consumer(
                                builder: (context, ref, child) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    margin: EdgeInsets.all(
                                      10,
                                    ),
                                    child: Stack(
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: tempColor,
                                              radius: 2.5.h,
                                              backgroundImage: NetworkImage(
                                                paginationState
                                                    .posts![0].channelImage
                                                    .toString(),
                                              ),
                                            ),
                                            // channel Name
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 1.5.h,
                                                ),
                                                child: Text(
                                                  paginationState
                                                      .posts![0].channel!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                        ),

                                        // Youtube Video player
                                        Align(
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Container(
                                              height: 250,
                                              // child: YoutubePlayerIFrame(
                                              //   controller:
                                              //       YoutubePlayerController(
                                              //     initialVideoId:
                                              //         paginationState.posts![0]
                                              //             .media!.first
                                              //             .toString()
                                              //             .split("?")
                                              //             .last
                                              //             .split('&')
                                              //             .first
                                              //             .split('=')
                                              //             .last,
                                              //     params: YoutubePlayerParams(
                                              //       showFullscreenButton: true,
                                              //       autoPlay: true,
                                              //     ),
                                              //   ),
                                              // ),  //Balu

                                            ),
                                          ),
                                        ),

                                        // Bottom
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 250,
                                            child: Stack(
                                              children: [
                                                // Title
                                                Positioned(
                                                  bottom: 60,
                                                  right: 5,
                                                  left: 5,
                                                  child: Text(
                                                    '${paginationState.posts![0].title!}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 10,
                                                  right: 5,
                                                  left: 5,
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            tempColor,
                                                        radius: 2.5.h,
                                                        backgroundImage:
                                                            NetworkImage(
                                                          paginationState
                                                              .posts![0]
                                                              .channelImage
                                                              .toString(),
                                                        ),
                                                      ),

                                                      // Editor Name
                                                      Expanded(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 1.5.h,
                                                          ),
                                                          child: Text(
                                                            paginationState
                                                                .posts![0]
                                                                .channel!,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 10.sp,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : paginationState.posts![0].layout == "Slider"
                            ? WillPopScope(
                                onWillPop: () async {
                                  ref.read(postPaginationControllerProvider);

                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NewsDashboard()),
                                      (route) => false);
                                  return Future.value(false);
                                },
                                child: Scaffold(
                                  backgroundColor: Colors.black,
                                  appBar: AppBar(
                                    backgroundColor: Colors.transparent,
                                    leading: IconButton(
                                      onPressed: () async {
                                        ref.read(
                                            postPaginationControllerProvider);

                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NewsDashboard()),
                                            (route) => false);
                                      },
                                      icon: Icon(
                                        Icons.keyboard_arrow_left_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    elevation: 0.5,
                                  ),
                                  bottomNavigationBar: Container(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.grey.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: SocialBanner(
                                      id: paginationState.posts![0].id!,
                                      index: 0,
                                      likes: paginationState.posts![0].likes!,
                                      dislikes:
                                          paginationState.posts![0].dislikes!,
                                      whatsCount:
                                          paginationState.posts![0].whatsApp!,
                                      liked: paginationState.posts![0].liked!,
                                      title: paginationState.posts![0].title!,
                                      description: paginationState
                                          .posts![0].description!,
                                      image:
                                          paginationState.posts![0].media![0]!,
                                      layout: paginationState.posts![0].layout!,
                                      comments:
                                          paginationState.posts![0].comments!,
                                      single: true,
                                    ),
                                  ),
                                  body: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    margin: EdgeInsets.all(
                                      10,
                                    ),
                                    child: Stack(
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: tempColor,
                                              radius: 2.5.h,
                                              backgroundImage: NetworkImage(
                                                paginationState
                                                    .posts![0].channelImage
                                                    .toString(),
                                              ),
                                            ),

                                            // channel Name
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 1.5.h,
                                                ),
                                                child: Text(
                                                  paginationState
                                                      .posts![0].channel!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                        ),
                                        // Slider

                                        Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CarouselSlider(
                                                  items: paginationState
                                                      .posts![0].media!
                                                      .map<Widget>((e) {
                                                    return Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: FancyShimmerImage(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 250,
                                                        imageUrl: e,
                                                        boxFit: BoxFit.contain,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  options: CarouselOptions(
                                                      // height: ResponsiveService.isMobile(context)
                                                      //     ? 250
                                                      //     : ResponsiveService.isTablet(context)
                                                      //         ? 400
                                                      //         : 620,
                                                      height: 30.h,
                                                      initialPage: 0,
                                                      enableInfiniteScroll:
                                                          true,
                                                      viewportFraction: 1.0,
                                                      reverse: false,
                                                      autoPlay: paginationState
                                                                  .posts![0]
                                                                  .media!
                                                                  .length >
                                                              1
                                                          ? true
                                                          : false,
                                                      autoPlayInterval:
                                                          Duration(seconds: 5),
                                                      autoPlayCurve:
                                                          Curves.ease,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      disableCenter: false,
                                                      onPageChanged:
                                                          (index, reason) {
                                                        setState(() {
                                                          _current = index;
                                                        });
                                                      }),
                                                ),
                                                paginationState.posts![0].media!
                                                            .length >
                                                        1
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children:
                                                            paginationState
                                                                .posts![0]
                                                                .media!
                                                                .map((event) {
                                                          int index =
                                                              paginationState
                                                                  .posts![0]
                                                                  .media!
                                                                  .indexOf(
                                                                      event);
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 3.0,
                                                            ),
                                                            child: Container(
                                                              width: 10,
                                                              height: 10,
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          2.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                color: _current ==
                                                                        index
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .white,
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      )
                                                    : SizedBox.shrink(),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Bottom
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 250,
                                            child: Stack(
                                              children: [
                                                // Title
                                                Positioned(
                                                  bottom: 60,
                                                  right: 5,
                                                  left: 5,
                                                  child: Text(
                                                    '${paginationState.posts![0].title!}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 10,
                                                  right: 5,
                                                  left: 5,
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            tempColor,
                                                        radius: 2.5.h,
                                                        backgroundImage:
                                                            NetworkImage(
                                                          paginationState
                                                              .posts![0]
                                                              .editorProfile
                                                              .toString(),
                                                        ),
                                                      ),

                                                      // Editor Name
                                                      Expanded(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 1.5.h,
                                                          ),
                                                          child: Text(
                                                            paginationState
                                                                .posts![0]
                                                                .editor!,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 10.sp,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : WillPopScope(
                                onWillPop: () async {
                                  ref.read(postPaginationControllerProvider);

                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NewsDashboard()),
                                      (route) => false);
                                  return Future.value(false);
                                },
                                child: Scaffold(
                                  appBar: AppBar(
                                    leading: IconButton(
                                      onPressed: () async {
                                        ref.read(
                                            postPaginationControllerProvider);

                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NewsDashboard()),
                                            (route) => false);
                                      },
                                      icon: Icon(
                                        Icons.keyboard_arrow_left_rounded,
                                        color: Colors.black,
                                      ),
                                    ),
                                    elevation: 0.5,
                                  ),
                                  bottomNavigationBar: Container(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.grey.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: SocialBanner(
                                      id: paginationState.posts![0].id!,
                                      index: 0,
                                      likes: paginationState.posts![0].likes!,
                                      dislikes:
                                          paginationState.posts![0].dislikes!,
                                      whatsCount:
                                          paginationState.posts![0].whatsApp!,
                                      liked: paginationState.posts![0].liked!,
                                      title: paginationState.posts![0].title!,
                                      description: paginationState
                                          .posts![0].description!,
                                      image:
                                          paginationState.posts![0].media![0]!,
                                      layout: paginationState.posts![0].layout!,
                                      comments:
                                          paginationState.posts![0].comments!,
                                      single: true,
                                    ),
                                  ),
                                  body: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    child: Container(
                                      margin: EdgeInsets.all(
                                        10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Logo
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: tempColor,
                                                radius: 2.5.h,
                                                backgroundImage: NetworkImage(
                                                  paginationState
                                                      .posts![0].channelImage
                                                      .toString(),
                                                ),
                                              ),

                                              // channel Name
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 1.5.h,
                                                  ),
                                                  child: Text(
                                                    paginationState
                                                        .posts![0].channel!,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Image
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 1.2.h,
                                            ),
                                            child: FancyShimmerImage(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 30.h,
                                              imageUrl: paginationState
                                                  .posts![0].media!.first,
                                              boxFit: BoxFit.contain,
                                            ),
                                          ),

                                          // Name
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            child: Text(
                                              paginationState.posts![0].title!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13.sp,
                                                letterSpacing: 0.1,
                                              ),
                                            ),
                                          ),

                                          // Time
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 0.8.h,
                                              horizontal: 0.5.h,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  TimeAgo
                                                      .displayTimeAgoFromTimestamp(
                                                    paginationState
                                                        .posts![0].time!,
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 8.sp,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 0.5.h,
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        FontAwesomeIcons.eye,
                                                        size: 13.sp,
                                                        color: Colors.blueGrey,
                                                      ),
                                                      SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        '${paginationState.posts![0].views!} వీక్షించారు',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blueGrey,
                                                          fontSize: 8.sp,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),

                                          // Description
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 2.h,
                                              horizontal: 1.h,
                                            ),
                                            child: Html(
                                              data: paginationState
                                                  .posts![0].description!,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 2.h,
                                          ),

                                          // Posted By
                                          // Posted By
                                          paginationState.posts![0].editor ==
                                                  null
                                              ? SizedBox.shrink()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Posted By',
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ),
                                          paginationState.posts![0].editor ==
                                                  null
                                              ? SizedBox.shrink()
                                              : Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          tempColor,
                                                      backgroundImage:
                                                          NetworkImage(
                                                        paginationState
                                                            .posts![0]
                                                            .editorProfile
                                                            .toString(),
                                                      ),
                                                    ),

                                                    // Editor Name
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 10,
                                                        ),
                                                        child: Text(
                                                          paginationState
                                                              .posts![0]
                                                              .editor!,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: 11.sp,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
              }
            });
          },
        );
      },
    );
  }
}
