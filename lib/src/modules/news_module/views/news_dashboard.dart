import 'dart:developer' as developer;

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../src.dart';

class NewsDashboard extends ConsumerStatefulWidget {
  const NewsDashboard({Key? key}) : super(key: key);

  @override
  _NewsDashboardState createState() => _NewsDashboardState();
}

class _NewsDashboardState extends ConsumerState<NewsDashboard> {
  void _loadMore() {
    ref.read(postPaginationControllerProvider.notifier).getPosts();
  }

  String? _getYoutubeThumbnail(String? youtubeUrl) {
    try {
      if (youtubeUrl == null || youtubeUrl.isEmpty) {
        developer.log('YouTube URL is null or empty');
        return null;
      }
      final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
      if (videoId == null || videoId.isEmpty) {
        developer.log('Failed to extract video ID from URL: $youtubeUrl');
        return null;
      }
      final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';
      developer.log('Successfully generated thumbnail URL: $thumbnailUrl');
      return thumbnailUrl;
    } catch (e) {
      developer.log('Error generating YouTube thumbnail: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      ref.watch(topicsControllerProvider);
      final topicsState = ref.watch(topicsControllerProvider.notifier).state;

      ref.watch(postPaginationControllerProvider);
      final paginationState =
          ref.watch(postPaginationControllerProvider.notifier).state;

      ref.watch(politiciansControllerProvider);
      final politiciansState =
          ref.watch(politiciansControllerProvider.notifier).state;

      return SafeArea(
        child: Scaffold(
          drawer: Drawer(
            child: DrawerComponent(),
          ),
          floatingActionButton: ref.watch(topic) == 'political'
              ? InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Followers()),
                  ),
                  child: Container(
                    height: 5.h,
                    width: 15.h,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.redAccent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Followers',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox.shrink(),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 5, left: 10, right: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => InkWell(
                          onTap: () {
                            try {
                              if (box.containsKey('1') &&
                                  box.get('1') != null) {
                                Scaffold.of(context).openDrawer();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MobileAuthScreen()),
                                );
                              }
                            } catch (e) {
                              developer.log('Error in drawer tap: $e');
                            }
                          },
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: disabledColor,
                              image: box.containsKey('profile') &&
                                      box.get('profile') != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          box.get('profile').toString()),
                                      fit: BoxFit.cover,
                                      onError: (exception, stackTrace) {
                                        developer.log(
                                            'Profile image loading error: $exception');
                                      },
                                    )
                                  : DecorationImage(
                                      // image: AssetImage('assets/placeholders/user.jpg'),
                                      image: AssetImage(
                                          'assets/placeholders/user.png'),
                                      fit: BoxFit.cover,
                                    ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 1,
                                style: BorderStyle.solid,
                                color: disabledColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Expanded(
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 20, vertical: 8),
                      //     child: Container(
                      //       height: 30,
                      //       decoration: BoxDecoration(
                      //         border: Border(
                      //           bottom: BorderSide(width: 0.2),
                      //         ),
                      //       ),
                      //       child: InkWell(
                      //         highlightColor: Colors.transparent,
                      //         onTap: () => Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (context) => SearchScreen()),
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Icon(
                      //               FontAwesomeIcons.search,
                      //               size: 13,
                      //               color: disabledColor,
                      //             ),
                      //             Expanded(
                      //               child: Padding(
                      //                 padding: const EdgeInsets.symmetric(
                      //                     horizontal: 10),
                      //                 child: Text(
                      //                   'Search News',
                      //                   overflow: TextOverflow.ellipsis,
                      //                   style: TextStyle(
                      //                     color: disabledColor,
                      //                     fontSize: 10.sp,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey, // Subtle border
                                width: 1,
                              ),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.black.withOpacity(0.05),
                              //     blurRadius: 8,
                              //     offset: Offset(0, 2),
                              //   ),
                              // ], // Subtle shadow for depth
                            ),
                            child: TextField(
                              // --- START OF UPDATED CODE ---
                              onTap: () {
                                // Navigate to SearchScreen on tap, keeping existing behavior
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchScreen()),
                                );
                              },
                              readOnly: true,
                              // Makes TextField act as a tappable area
                              decoration: InputDecoration(
                                hintText: 'Search News...',
                                // Improved placeholder text
                                // Improved placeholder
                                hintStyle: TextStyle(
                                  // color: disabledColor.withOpacity(0.6),
                                  color: Colors.grey
                                      .shade600, // Or use Colors.black.withOpacity(0.6)

                                  // Softer hint color
                                  fontSize: 12.sp,
                                ),
                                prefixIcon: Icon(
                                  FontAwesomeIcons.search,
                                  size: 16, // Slightly larger icon
                                  color: disabledColor, // Consistent with theme
                                  semanticLabel: 'Search', // Accessibility
                                ),
                                border: InputBorder.none,
                                isDense: true, // Reduces vertical padding
                                // No default TextField border
                                contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                      10, // You can also try vertical: 0 or 8
                                  horizontal: 0,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black,
                              ),
                              // --- END OF UPDATED CODE ---
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 5),
                margin: EdgeInsets.only(bottom: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    try {
                      if (topicsState.refreshError) {
                        developer.log(
                            'Topics refresh error: ${topicsState.errorMessage}');
                        return ErrorBody(message: topicsState.errorMessage);
                      } else if (topicsState.topics == null ||
                          topicsState.topics!.isEmpty) {
                        developer.log('Topics list is null or empty');
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: 5, // Reduced for better UX
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 100,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: topicsState.topics!.length,
                          itemBuilder: (context, index) {
                            final topic = topicsState.topics![index];
                            return TopicListComponent(
                              id: topic.id,
                              name: topic.name,
                              type: topic.type,
                            );
                          },
                        );
                      }
                    } catch (e) {
                      developer.log('Error in topics builder: $e');
                      return ErrorBody(message: 'Error loading topics');
                    }
                  },
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    try {
                      if (paginationState.posts == null ||
                          paginationState.posts!.isEmpty) {
                        developer.log('Posts list is null or empty');
                        return ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return NewsShimmer();
                          },
                          separatorBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Divider(),
                            );
                          },
                          itemCount: 6, // Reduced for better UX
                        );
                      }

                      if (paginationState.refreshError) {
                        developer.log(
                            'Posts refresh error: ${paginationState.errorMessage}');
                        return ErrorBody(message: paginationState.errorMessage);
                      }

                      return LazyLoadScrollView(
                        onEndOfPage: _loadMore,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ref
                                .refresh(
                                    postPaginationControllerProvider.notifier)
                                .resetPosts();
                            await ref
                                .read(postPaginationControllerProvider.notifier)
                                .getPosts();
                          },
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: paginationState.posts!.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              if (index >= paginationState.posts!.length) {
                                developer.log(
                                    'Index out of bounds in posts: $index');
                                return SizedBox.shrink();
                              }

                              final post = paginationState.posts![index];
                              final thumbnailUrl = post.layout == "Youtube"
                                  ? _getYoutubeThumbnail(post.media?.first)
                                  : post.media?.first;

                              return Column(
                                children: [
                                  if (index.isEven &&
                                      ref.watch(topic) == 'political')
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      height: 18.h,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.blueGrey.withOpacity(0.5),
                                      child: _buildPoliticiansSection(
                                          politiciansState),
                                    ),
                                  InkWell(
                                    onTap: () async {
                                      try {
                                        await ref
                                            .read(
                                                postPaginationControllerProvider
                                                    .notifier)
                                            .postViews(
                                              post.id!,
                                              post.views!,
                                              index,
                                            );
                                        ref.read(postId.notifier).state =
                                            post.id.toString();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PostViewScreen(
                                              index: index,
                                              id: post.id,
                                              layout: post.layout,
                                              whatsCount: post.whatsApp,
                                              description: post.description,
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        developer.log('Error in post tap: $e');
                                      }
                                    },
                                    child: NewsLayoutComponent(
                                      id: post.id ?? '',
                                      title: post.title,
                                      description: post.description,
                                      media: thumbnailUrl != null
                                          ? [thumbnailUrl]
                                          : post.media ?? [],
                                      time: post.time,
                                      channel: post.channel,
                                      channelImage: post.channelImage,
                                      layout: post.layout,
                                      view: post.views,
                                      index: index,
                                    ),
                                  ),
                                  SocialBanner(
                                    id: post.id ?? 'default-id',
                                    index: index,
                                    likes: post.likes ?? '',
                                    dislikes: post.dislikes ?? '',
                                    whatsCount: post.whatsApp,
                                    liked: post.liked ?? '',
                                    title: post.title,
                                    description: post.description,
                                    image: thumbnailUrl ?? post.media?[0] ?? '',
                                    layout: post.layout,
                                    single: false,
                                    comments: post.comments ?? '',
                                  ),
                                  if (index !=
                                      paginationState.posts!.length - 1)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                      child: Divider(thickness: 1.2),
                                    ),
                                  if (index ==
                                      paginationState.posts!.length - 1)
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.93),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    } catch (e) {
                      developer.log('Error in posts builder: $e');
                      return ErrorBody(message: 'Error loading posts');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      developer.log('Error in build method: $e');
      return Scaffold(
        body: Center(
          child: Text('Error loading dashboard: $e'),
        ),
      );
    }
  }

  Widget _buildPoliticiansSection(dynamic politiciansState) {
    try {
      if (politiciansState.refreshError) {
        developer
            .log('Politicians refresh error: ${politiciansState.errorMessage}');
        return ErrorBody(message: politiciansState.errorMessage);
      } else if (politiciansState.politicians == null ||
          politiciansState.politicians!.isEmpty) {
        developer.log('Politicians list is null or empty');
        return DelayedDisplay(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Fetching Data',
                  style: TextStyle(fontSize: 8.sp),
                ),
              ],
            ),
          ),
        );
      } else {
        // // Fix: Ensure finalLength does not exceed actual list length
        // int finalLength = politiciansState.politicians!.length <= 5
        //     ? politiciansState.politicians!.length
        //     : 5; // Cap at 5 to avoid index errors
        int finalLength = politiciansState.politicians!.length <= 5
            ? politiciansState.politicians!.length
            : 5; // Cap at 5 to avoid index errors
        itemCount:
        finalLength + 1; // Add 1 for "More" button
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: finalLength + 1,
          // Add 1 for "More" button
          itemBuilder: (context, politicianIndex) {
            if (politicianIndex == finalLength) {
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Followers()),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: 110,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.chevronCircleRight),
                          SizedBox(height: 3),
                          Text(
                            'More',
                            style: TextStyle(fontSize: 10.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (politicianIndex < politiciansState.politicians!.length) {
              final politician = politiciansState.politicians![politicianIndex];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 110,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 6.h,
                          width: 10.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(politician.profile ??
                                  'https://via.placeholder.com/150'),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                developer
                                    .log('Politician image error: $exception');
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          politician.name ?? 'Unknown',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10.sp),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          margin: EdgeInsets.only(top: 3),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.blue),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: InkWell(
                            onTap: () {
                              try {
                                if (box.containsKey('1') &&
                                    box.get('1')!.isNotEmpty) {
                                  ref
                                      .read(topicsControllerProvider.notifier)
                                      .newTopic(
                                        politician.id!,
                                        politician.name!,
                                        politician.type!,
                                        politician.profile!,
                                      );
                                  ref
                                      .read(politiciansControllerProvider
                                          .notifier)
                                      .updateStatus(
                                        politician.status!,
                                        politicianIndex,
                                        politician.id!,
                                      );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("You must Login to Follow"),
                                      action: SnackBarAction(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MobileAuthScreen()),
                                          );
                                        },
                                        label: 'Login',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                developer.log('Error in follow/unfollow: $e');
                              }
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                politician.status == '0'
                                    ? 'Follow'
                                    : 'Unfollow',
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.blue),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              developer.log('Invalid politician index: $politicianIndex');
              return SizedBox.shrink();
            }
          },
        );
      }
    } catch (e) {
      developer.log('Error in politicians section: $e');
      return ErrorBody(message: 'Error loading politicians');
    }
  }
}
