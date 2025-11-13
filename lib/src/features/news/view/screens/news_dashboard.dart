import 'dart:developer' as developer;

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
import 'package:local_guru_all/src/core/log/logging.dart';
import 'package:local_guru_all/src/features/location/viewmodel/location_provider.dart';
import 'package:local_guru_all/src/src.dart';
import 'package:provider/provider.dart' hide Consumer;
import 'package:sizer/sizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/legacy_filter_bar.dart';
import '../widgets/news_feed_card.dart';

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
      final paginationState = ref.read(legacyPostPaginationControllerProvider);
      if (paginationState.posts == null || paginationState.posts!.isEmpty) {
        AppLogger.logInfo(
          'Legacy init trigger: posts empty, requesting first page',
          tag: 'legacyNewsView',
        );
        ref.read(legacyPostPaginationControllerProvider.notifier).getPosts();
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
    AppLogger.logInfo('Legacy loadMore requested from UI',
        tag: 'legacyNewsView');
    ref.read(legacyPostPaginationControllerProvider.notifier).getPosts();
  }

  String _formatLandmarkLabel(String? raw) {
    const fallback = 'Set location';
    if (raw == null) {
      return fallback;
    }

    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
      return fallback;
    }

    return trimmed;
  }

  // Build individual post item (extracted for reusability)
  Widget _buildPostItem(
    BuildContext context,
    PostsModel post,
    int index,
    PoliticiansModelProvider politiciansState,
    String selectedTopic,
  ) {
    String? thumbnailUrl;
    if (post.media != null && post.media!.isNotEmpty) {
      thumbnailUrl = post.layout == 'Youtube'
          ? _getYoutubeThumbnail(post.media!.first)
          : post.media!.first.toString();
    }

    final card = NewsFeedCard(
      post: post,
      thumbnailUrl: thumbnailUrl,
      onTap: () async {
        final postIdValue = post.id;
        if (postIdValue == null || postIdValue.isEmpty) {
          AppLogger.logWarning(
            'Legacy post tap skipped: missing id for index=$index',
            tag: 'legacyNewsView',
          );
          return;
        }

        final currentViews = post.views?.isNotEmpty == true ? post.views! : '0';

        try {
          AppLogger.logInfo(
            'Legacy post tapped id=$postIdValue',
            tag: 'legacyNewsView',
          );
          await ref
              .read(legacyPostPaginationControllerProvider.notifier)
              .postViews(
                postIdValue,
                currentViews,
                index,
              );
          ref.read(postId.notifier).state = postIdValue;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostViewScreen(
                index: index,
                id: postIdValue,
                layout: post.layout,
                whatsCount: post.whatsApp,
                description: post.description,
              ),
            ),
          );
        } catch (e, stackTrace) {
          developer.log('Error in post tap: $e');
          AppLogger.logError('Legacy post tap failed: $e',
              tag: 'legacyNewsView', stackTrace: stackTrace);
        }
      },
      footer: SocialBanner(
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
    );

    if (index.isEven && selectedTopic == 'political') {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 22.h,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildPoliticiansSection(politiciansState),
          ),
          card,
        ],
      );
    }

    return card;
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
      developer
          .log('NewsDashboard build method called - screen is being rendered');
      print('NewsDashboard build method called - screen is being rendered');

      final paginationState = ref.watch(legacyPostPaginationControllerProvider);
      final politiciansState = ref.watch(politiciansControllerProvider);

      AppLogger.logInfo(
        'Legacy UI state received: page=${paginationState.page}, posts=${paginationState.posts?.length ?? 0}',
        tag: 'legacyNewsView',
      );

      final politicians = (politiciansState.politicians ?? [])
          .where((entry) => (entry.type ?? '').toLowerCase() == 'politician')
          .toList();
      final selectedLandmarkRaw = ref.watch(selectedLocation);
      final selectedLandmarkLabel = _formatLandmarkLabel(selectedLandmarkRaw);

      return SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Local Guru News',
            backgroundColor: AppColors.primary,
            iconColor: AppColors.black,
            titleColor: AppColors.black,
            actions: [
              Semantics(
                label: 'Selected landmark: $selectedLandmarkLabel',
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.black,
                      ),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Text(
                          selectedLandmarkLabel,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Search News',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () async {
                          final locationProvider =
                              context.read<LocationProvider>();
                          await showLegacyFilters(
                            context: context,
                            ref: ref,
                            locationProvider: locationProvider,
                            politicians: politicians,
                          );
                        },
                        icon: const Icon(Icons.tune_rounded),
                        tooltip: 'Open filters',
                      ),
                    ],
                  ),
                ),
              ),

              // Adaptive filter surface (topics, location, people)
              LegacyFilterBar(),

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
                                  (paginationState.errorMessage?.isEmpty ??
                                      true)),
                          hasError: paginationState.refreshError,
                          errorMessage: paginationState.errorMessage,
                          onLoadMore: _loadMore,
                          onRefresh: () async {
                            AppLogger.logInfo(
                              'Legacy pull-to-refresh invoked',
                              tag: 'legacyNewsView',
                            );
                            ref
                                .refresh(legacyPostPaginationControllerProvider
                                    .notifier)
                                .resetPosts();
                            await ref
                                .read(legacyPostPaginationControllerProvider
                                    .notifier)
                                .getPosts();
                          },
                          itemBuilder: (context, index, post) {
                            AppLogger.logInfo(
                              'Legacy item builder index=$index postId=${post.id}',
                              tag: 'legacyNewsView',
                            );
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
                                final userId = ref.read(userIdProvider);
                                if (userId.isNotEmpty && userId != '0') {
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
