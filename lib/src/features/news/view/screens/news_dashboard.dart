import 'dart:developer' as developer;

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
import 'package:local_guru_all/src/core/components/paginated_list/paginated_list_view.dart';
import 'package:local_guru_all/src/src.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/constants/app_colors.dart';

class NewsDashboard extends ConsumerStatefulWidget {
  const NewsDashboard({Key? key}) : super(key: key);

  @override
  _NewsDashboardState createState() => _NewsDashboardState();
}

class _NewsDashboardState extends ConsumerState<NewsDashboard> {
  @override
  void initState() {
    super.initState();
    developer.log('NewsDashboard screen opened/initialized');
    print('NewsDashboard screen opened/initialized');

    // Ensure posts are loaded when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paginationState =
          ref.read(postPaginationControllerProvider.notifier).state;
      if (paginationState.posts == null || paginationState.posts!.isEmpty) {
        ref.read(postPaginationControllerProvider.notifier).getPosts();
      }
    });
  }

  @override
  void dispose() {
    developer.log('NewsDashboard screen disposed/closed');
    print('NewsDashboard screen disposed/closed');
    super.dispose();
  }

  // Load more posts called by PaginatedListView when list end reached
  void _loadMore() {
    ref.read(postPaginationControllerProvider.notifier).getPosts();
  }

  // Build individual post item (extracted for reusability)
  Widget _buildPostItem(
    BuildContext context,
    PostsModel post,
    int index,
    dynamic politiciansState,
    String selectedTopic,
  ) {
    // Thumbnail extraction logic for YouTube or default media
    String? thumbnailUrl;
    if (post.media != null && post.media!.isNotEmpty) {
      thumbnailUrl = post.layout == "Youtube"
          ? _getYoutubeThumbnail(post.media!.first)
          : post.media!.first;
    }

          // Wrap each post and its social banner inside a single container
          return Container(
            margin: EdgeInsets.only(bottom: 4),
            child: Column(
              children: [
          // Inject politicians section for political topic on even indexes
          if (index.isEven && selectedTopic == 'political')
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              height: 22.h,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildPoliticiansSection(politiciansState),
            ),

          // Unified News Card with News Content + Social Actions
          Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clickable news layout content area (top part)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      try {
                        await ref
                            .read(postPaginationControllerProvider.notifier)
                            .postViews(
                              post.id!,
                              post.views!,
                              index,
                            );
                        ref.read(postId.notifier).state = post.id.toString();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostViewScreen(
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: NewsLayoutComponent(
                      id: post.id ?? '',
                      title: post.title,
                      description: post.description,
                      media: thumbnailUrl != null ? [thumbnailUrl] : post.media ?? [],
                      time: post.time,
                      channel: post.channel,
                      channelImage: post.channelImage,
                      layout: post.layout,
                      view: post.views,
                      index: index,
                    ),
                  ),
                ),

                // Subtle divider line between news and social
                Container(
                  height: 1,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.grey.withOpacity(0.1),
                ),

                // Social banner with interaction buttons (bottom part)
                SocialBanner(
                  id: post.id ?? 'default-id',
                  index: index,
                  likes: post.likes ?? '',
                  dislikes: post.dislikes ?? '',
                  whatsCount: post.whatsApp,
                  liked: post.liked ?? '',
                  title: post.title,
                  description: post.description,
                  image: thumbnailUrl ??
                      (post.media != null && post.media!.isNotEmpty
                          ? post.media![0]
                          : ''),
                  layout: post.layout,
                  single: false,
                  comments: post.comments ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Utility to extract YouTube thumbnail URL from video URL
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
      developer
          .log('NewsDashboard build method called - screen is being rendered');
      print('NewsDashboard build method called - screen is being rendered');

      // Watching providers to rebuild when state changes
      ref.watch(topicsGreetingsControllerProvider);
      final topicsState = ref.watch(topicsControllerProvider);

      ref.watch(postPaginationControllerProvider);
      final paginationState =
          ref.watch(postPaginationControllerProvider.notifier).state;

      ref.watch(politiciansControllerProvider);
      final politiciansState =
          ref.watch(politiciansControllerProvider.notifier).state;

      return SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'News',
            backgroundColor: AppColors.primary,
            iconColor: AppColors.black,
            titleColor: AppColors.black,
          ),
          drawer: const CustomDrawer(),
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
              // Search bar with user profile avatar and search functionality
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 5, left: 10, right: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Row(
                    children: [
                      // Builder(
                      //   builder: (context) => InkWell(
                      //     onTap: () {
                      //       final auth =
                      //           classic_provider.Provider.of<AuthProvider>(
                      //               context,
                      //               listen: false);
                      //       if (auth.currentUser != null) {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) => const ProfileScreenV2(),
                      //           ),
                      //         );
                      //       } else {
                      //         _showLoginRegisterDialog(context);
                      //       }
                      //     },
                      //     child: Container(
                      //       height: 35,
                      //       width: 35,
                      //       decoration: BoxDecoration(
                      //         color: disabledColor,
                      //         image: box.containsKey('profile') &&
                      //                 box.get('profile') != null
                      //             ? DecorationImage(
                      //                 image: NetworkImage(
                      //                     box.get('profile').toString()),
                      //                 fit: BoxFit.cover,
                      //                 onError: (exception, stackTrace) {
                      //                   developer.log(
                      //                       'Profile image loading error: $exception');
                      //                 },
                      //               )
                      //             : DecorationImage(
                      //                 image: AssetImage(
                      //                     'assets/placeholders/user.png'),
                      //                 fit: BoxFit.cover,
                      //               ),
                      //         shape: BoxShape.circle,
                      //         border: Border.all(
                      //           width: 1,
                      //           style: BorderStyle.solid,
                      //           color: disabledColor,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchScreen()),
                                );
                              },
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Icon(
                                      FontAwesomeIcons.search,
                                      size: 20,
                                      color: disabledColor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 58,
                                  ),
                                  Text(
                                    'Search News',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  // Optional space on right to balance left padding
                                  // SizedBox(width: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Topics horizontal list bar below search area
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    try {
                      if (topicsState.refreshError) {
                        developer.log(
                            'Topics refresh error: ${topicsState.errorMessage}');
                        return Center(
                          child: ErrorBody(message: topicsState.errorMessage),
                        );
                      } else if (topicsState.topics == null ||
                          topicsState.topics!.isEmpty) {
                        developer.log('Topics list is null or empty');
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 100,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
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
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          itemCount: topicsState.topics!.length,
                          itemBuilder: (context, index) {
                            final topic = topicsState.topics![index];
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                              child: TopicListComponent(
                                id: topic.id,
                                name: topic.name,
                                type: topic.type,
                              ),
                            );
                          },
                        );
                      }
                    } catch (e) {
                      developer.log('Error in topics builder: $e');
                      return Center(
                        child: ErrorBody(message: 'Error loading topics'),
                      );
                    }
                  },
                ),
              ),

              // Posts list expanded to use remaining vertical space
              Expanded(
                child: Container(
                  color: AppColors.background,
                  child: Builder(
                    builder: (context) {
                      try {
                        // Use reusable PaginatedListView which handles all states
                        return PaginatedListView<PostsModel>(
                        items: paginationState.posts ?? [],
                        isLoading: paginationState.posts == null ||
                            (paginationState.posts!.isEmpty &&
                                (paginationState.errorMessage?.isEmpty ?? true)),
                        hasError: paginationState.refreshError,
                        errorMessage: paginationState.errorMessage,
                        onLoadMore: _loadMore,
                        onRefresh: () async {
                          ref
                              .refresh(postPaginationControllerProvider.notifier)
                              .resetPosts();
                          await ref
                              .read(postPaginationControllerProvider.notifier)
                              .getPosts();
                        },
                        itemBuilder: (context, index, post) {
                          return _buildPostItem(
                            context,
                            post,
                            index,
                            politiciansState,
                            ref.watch(topic),
                          );
                        },
                        loadingWidget: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return NewsShimmer();
                          },
                          separatorBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: Divider(
                                thickness: 2.0,
                                color: Colors.grey.shade300,
                              ),
                            );
                          },
                          itemCount: 4,
                        ),
                        errorWidget: ErrorBody(
                          message: paginationState.errorMessage,
                          textSize: 16.sp,
                        ),
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                      );
                      } catch (e) {
                        developer.log('Error in posts builder: $e');
                        return ErrorBody(
                          message: 'Error loading posts',
                          textSize: 16.sp,
                        );
                      }
                    },
                  ),
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

  void _showLoginRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login required'),
        content: const Text('Please login or register to access your profile.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreenV2()),
              );
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreenV2()),
              );
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  // Politicians section builder for political topic posts
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
        // Cap politicians shown to 5 plus one for the "More" tile
        int finalLength = politiciansState.politicians!.length <= 5
            ? politiciansState.politicians!.length
            : 5;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: finalLength + 1,
          // Add one for "More" button
          itemBuilder: (context, politicianIndex) {
            if (politicianIndex == finalLength) {
              // "More" button tile to navigate to followers screen
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

              // Display politician info with follow/unfollow button
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
                              image: NetworkImage(
                                politician.profile ??
                                    'https://via.placeholder.com/150',
                              ),
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
                                                    SignInScreenV2()),
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
