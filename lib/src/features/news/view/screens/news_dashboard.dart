import 'dart:developer' as developer;

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_guru_all/src/core/components/appBar/app_bar.dart';
import 'package:local_guru_all/src/core/log/logging.dart';
import 'package:local_guru_all/src/features/news/data/model/politician/politicians_Model.dart';
import 'package:local_guru_all/src/src.dart';
import 'package:sizer/sizer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/legacy_filter_bar.dart';
import '../widgets/news_feed_card.dart';
import 'package:local_guru_all/src/features/location/viewmodel/location_provider.dart';
import 'package:local_guru_all/src/features/location/data/model/state_model.dart';
import 'package:local_guru_all/src/features/location/data/model/district_model.dart';
import 'package:local_guru_all/src/features/location/data/model/landmark_model.dart';
import 'package:provider/provider.dart' as provider;

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

    // Ensure posts are loaded when screen initializes (one-time only)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use initializePosts() which has proper guards
      ref
          .read(legacyPostPaginationControllerProvider.notifier)
          .initializePosts();
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

  void _onPoliticianSelected(PoliticianModel person) {
    if (person.id == null || person.id!.isEmpty) {
      AppLogger.logWarning(
        'Politician selection skipped: missing id',
        tag: 'legacyNewsView',
      );
      return;
    }

    ref.read(selectedPoliticianIdProvider.notifier).state = person.id;
    ref.read(topicId.notifier).state = 'politician/${person.id}';
    ref.read(topicType.notifier).state = 'politician';
    // Don't change the topic name when selecting a politician
    // This keeps the topic chip (e.g., "politician") visually selected
    // The TopicListComponent checks topicType to determine if politician topic is selected

    AppLogger.logInfo(
      'Quick politician selected id=${person.id}',
      tag: 'legacyNewsView',
    );
    ref.read(legacyPostPaginationControllerProvider.notifier).resetPosts();
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
      final selectedPoliticianId = ref.watch(selectedPoliticianIdProvider);
      final currentTopicType = ref.watch(topicType);

      AppLogger.logInfo(
        'Legacy UI state received: page=${paginationState.page}, posts=${paginationState.posts?.length ?? 0}',
        tag: 'legacyNewsView',
      );

      // PoliticiansService already filters for type == 'politician', so no need to filter again
      final politicians = politiciansState.politicians ?? [];
      final isPoliticianTopic =
          currentTopicType.toLowerCase() == 'politician';

      final shouldAutoSelectFirstPolitician = isPoliticianTopic &&
          (selectedPoliticianId?.isEmpty ?? true) &&
          politicians.isNotEmpty &&
          !politiciansState.isLoading;

      if (shouldAutoSelectFirstPolitician) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _onPoliticianSelected(politicians.first);
        });
      }

      
      developer.log(
        'NewsDashboard: Politicians count: ${politicians.length}, '
        'State politicians: ${politiciansState.politicians?.length ?? 0}, '
        'Error: ${politiciansState.errorMessage ?? "none"}',
      );
      
      // REMOVED: API call from build method - this was causing continuous API calls
      // Politicians are now fetched once in initState with _politiciansFetched flag
      final selectedLandmarkRaw = ref.watch(selectedLocation);
      final selectedLandmarkLabel = _formatLandmarkLabel(selectedLandmarkRaw);
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return SafeArea(
        child: Scaffold(
          backgroundColor: isDark
              ? Colors.grey.shade900
              : theme.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: 'Localguru',
            backgroundColor: isDark
                ? Colors.grey.shade900
                : AppColors.primary,
            iconColor: isDark ? Colors.white : AppColors.black,
            titleColor: isDark ? Colors.white : AppColors.black,
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
                        color: isDark ? Colors.white : AppColors.black,
                      ),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Text(
                          selectedLandmarkLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.black,
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
              // Search bar
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 5, left: 10, right: 10),
                child: Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;
                    return Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
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
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Search News',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade600,
                                  fontSize: 16.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Adaptive filter surface (topics, location, people)
              LegacyFilterBar(),
              if (isPoliticianTopic)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: _PoliticianTopicPanel(
                    state: politiciansState,
                    selectedId: selectedPoliticianId,
                    onSelect: _onPoliticianSelected,
                    onLoadMore: () => ref
                        .read(politiciansControllerProvider.notifier)
                        .loadMorePoliticians(),
                    onRetry: () => ref
                        .read(politiciansControllerProvider.notifier)
                        .loadInitialPoliticians(
                          search: politiciansState.searchQuery,
                        ),
                  ),
                ),
              if (currentTopicType.toLowerCase() == 'location')
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: _LocationTopicPanel(
                    onLocationChanged: () {
                      // Reset posts when location selection changes
                      ref
                          .read(legacyPostPaginationControllerProvider.notifier)
                          .resetPosts();
                    },
                  ),
                ),

              // Posts list expanded to use remaining vertical space
              Expanded(
                child: Container(
                  color: isDark
                      ? Colors.grey.shade900
                      : theme.scaffoldBackgroundColor,
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
                              return const ImprovedNewsShimmer();
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 8);
                            },
                            itemCount: 4,
                          ),
                          errorWidget: ErrorWidgetImproved(
                            message: paginationState.errorMessage ?? 'Failed to load news',
                            onRetry: () {
                              ref.invalidate(legacyPostPaginationControllerProvider);
                            },
                          ),
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                        );
                      } catch (e) {
                        developer.log('Error in posts builder: $e');
                        return ErrorWidgetImproved(
                          message: 'Error loading posts. Please try again.',
                          onRetry: () {
                            ref.invalidate(legacyPostPaginationControllerProvider);
                          },
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
                                      .read(topicsProvider.notifier)
                                      .addTopic(
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

class _PoliticianTopicPanel extends StatelessWidget {
  const _PoliticianTopicPanel({
    required this.state,
    required this.selectedId,
    required this.onSelect,
    required this.onLoadMore,
    required this.onRetry,
  });

  final PoliticiansModelProvider state;
  final String? selectedId;
  final ValueChanged<PoliticianModel> onSelect;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final hasData = state.politicians != null && state.politicians!.isNotEmpty;

    return SizedBox(
      height: 70,
      width: double.infinity,
      child: _buildContent(context, hasData),
    );
  }

  Widget _buildContent(BuildContext context, bool hasData) {
    if (state.isLoading && !hasData) {
      return const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if ((state.politicians?.isEmpty ?? true) &&
        (state.errorMessage?.isNotEmpty ?? false)) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Unable to load politicians. Please try again.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    final people = state.politicians ?? [];
    if (people.isEmpty) {
      return Text(
        'No politicians available right now.',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.grey),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: people.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= people.length) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              avatar: const Icon(Icons.more_horiz, size: 18),
              label: const Text('More'),
              onSelected: (_) => onLoadMore(),
              selectedColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ),
            ),
          );
        }

        final person = people[index];
        final isSelected = selectedId == person.id;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: FilterChip(
            avatar: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (person.profile?.isNotEmpty ?? false)
                  ? NetworkImage(person.profile!)
                  : null,
              child: (person.profile?.isEmpty ?? true)
                  ? Text(
                      (person.name?.isNotEmpty ?? false)
                          ? person.name!.characters.first.toUpperCase()
                          : '?',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                  : null,
            ),
            label: Text(person.name ?? 'Unknown'),
            selected: isSelected,
            selectedColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.12),
            onSelected: (value) {
              if (!value) return;
              onSelect(person);
            },
          ),
        );
      },
    );
  }
}

class _LocationTopicPanel extends ConsumerStatefulWidget {
  const _LocationTopicPanel({required this.onLocationChanged});

  final VoidCallback onLocationChanged;

  @override
  ConsumerState<_LocationTopicPanel> createState() =>
      _LocationTopicPanelState();
}

class _LocationTopicPanelState extends ConsumerState<_LocationTopicPanel> {
  bool _hasAutoSelectedTelangana = false;

  @override
  void initState() {
    super.initState();
    // Load states when panel is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        provider.Provider.of<LocationProvider>(context, listen: false).loadStates();
      }
    });
  }

  void _autoSelectTelanganaIfNeeded() {
    final currentTopicType = ref.read(topicType);
    final selectedStateId = ref.read(selectedNewsStateIdProvider);
    final locationProvider = provider.Provider.of<LocationProvider>(context, listen: false);
    
    // Auto-select Telangana only once when location topic is selected and no state is selected yet
    if (!_hasAutoSelectedTelangana &&
        currentTopicType.toLowerCase() == 'location' &&
        (selectedStateId == null || selectedStateId.isEmpty) &&
        locationProvider.states.isNotEmpty &&
        !locationProvider.isLoading) {
      _hasAutoSelectedTelangana = true;
      
      // Find Telangana state (ID: "1")
      try {
        final telanganaState = locationProvider.states.firstWhere(
          (state) => state.id == '1',
          orElse: () => locationProvider.states.first, // Fallback to first state if Telangana not found
        );
        _onStateSelected(telanganaState);
      } catch (e) {
        // If no states available, do nothing
      }
    }
  }

  void _onStateSelected(StateModel? state) {
    if (state == null) {
      // Clear all selections
      ref.read(selectedNewsStateIdProvider.notifier).state = null;
      ref.read(selectedNewsStateNameProvider.notifier).state = null;
      ref.read(selectedNewsDistrictIdProvider.notifier).state = null;
      ref.read(selectedNewsDistrictNameProvider.notifier).state = null;
      ref.read(selectedNewsLandmarkIdProvider.notifier).state = null;
      ref.read(selectedNewsLandmarkNameProvider.notifier).state = null;
      widget.onLocationChanged();
      return;
    }

    ref.read(selectedNewsStateIdProvider.notifier).state = state.id;
    ref.read(selectedNewsStateNameProvider.notifier).state = state.state;
    // Clear district and landmark when state changes
    ref.read(selectedNewsDistrictIdProvider.notifier).state = null;
    ref.read(selectedNewsDistrictNameProvider.notifier).state = null;
    ref.read(selectedNewsLandmarkIdProvider.notifier).state = null;
    ref.read(selectedNewsLandmarkNameProvider.notifier).state = null;

    // Load districts for selected state
    provider.Provider.of<LocationProvider>(context, listen: false).selectState(state.id);
    widget.onLocationChanged();
  }

  void _onDistrictSelected(DistrictModel? district) {
    if (district == null) {
      ref.read(selectedNewsDistrictIdProvider.notifier).state = null;
      ref.read(selectedNewsDistrictNameProvider.notifier).state = null;
      ref.read(selectedNewsLandmarkIdProvider.notifier).state = null;
      ref.read(selectedNewsLandmarkNameProvider.notifier).state = null;
      widget.onLocationChanged();
      return;
    }

    ref.read(selectedNewsDistrictIdProvider.notifier).state = district.districtId;
    // Use English name for API compatibility
    ref.read(selectedNewsDistrictNameProvider.notifier).state = 
        district.districtEnglish.isNotEmpty ? district.districtEnglish : district.district;
    // Clear landmark when district changes
    ref.read(selectedNewsLandmarkIdProvider.notifier).state = null;
    ref.read(selectedNewsLandmarkNameProvider.notifier).state = null;

    final stateId = ref.read(selectedNewsStateIdProvider);
    if (stateId != null) {
      provider.Provider.of<LocationProvider>(context, listen: false)
          .selectDistrict(stateId, district.districtId);
    }
    widget.onLocationChanged();
  }

  void _onLandmarkSelected(LandmarkModel? landmark) {
    if (landmark == null) {
      ref.read(selectedNewsLandmarkIdProvider.notifier).state = null;
      ref.read(selectedNewsLandmarkNameProvider.notifier).state = null;
      widget.onLocationChanged();
      return;
    }

    ref.read(selectedNewsLandmarkIdProvider.notifier).state = landmark.landmarkId;
    // Use English name for API compatibility
    ref.read(selectedNewsLandmarkNameProvider.notifier).state = 
        landmark.landmarkEnglish.isNotEmpty ? landmark.landmarkEnglish : landmark.landmark;
    provider.Provider.of<LocationProvider>(context, listen: false).selectLandmark(landmark.landmarkId);
    widget.onLocationChanged();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = provider.Provider.of<LocationProvider>(context);
    final selectedStateId = ref.watch(selectedNewsStateIdProvider);
    final selectedDistrictId = ref.watch(selectedNewsDistrictIdProvider);
    final selectedLandmarkId = ref.watch(selectedNewsLandmarkIdProvider);

    // Auto-select Telangana when states are loaded and no state is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _autoSelectTelanganaIfNeeded();
      }
    });

    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Row(
        children: [
          // State Dropdown
          Expanded(
            child: _LocationDropdown<StateModel>(
              label: 'State',
              items: locationProvider.states,
              selectedId: selectedStateId,
              getItemId: (item) => item.id,
              getItemName: (item) => item.state,
              onChanged: _onStateSelected,
              isLoading: locationProvider.isLoading && locationProvider.states.isEmpty,
            ),
          ),
          const SizedBox(width: 8),
          // District Dropdown
          Expanded(
            child: _LocationDropdown<DistrictModel>(
              label: 'District',
              items: locationProvider.districts,
              selectedId: selectedDistrictId,
              getItemId: (item) => item.districtId,
              getItemName: (item) => item.district,
              onChanged: _onDistrictSelected,
              isLoading: locationProvider.isLoading && selectedStateId != null,
              enabled: selectedStateId != null,
            ),
          ),
          const SizedBox(width: 8),
          // Landmark Dropdown
          Expanded(
            child: _LocationDropdown<LandmarkModel>(
              label: 'Landmark',
              items: locationProvider.landmarks,
              selectedId: selectedLandmarkId,
              getItemId: (item) => item.landmarkId,
              getItemName: (item) => item.landmark,
              onChanged: _onLandmarkSelected,
              isLoading: locationProvider.isLoading && selectedDistrictId != null,
              enabled: selectedDistrictId != null,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationDropdown<T> extends StatelessWidget {
  const _LocationDropdown({
    required this.label,
    required this.items,
    required this.selectedId,
    required this.getItemId,
    required this.getItemName,
    required this.onChanged,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final List<T> items;
  final String? selectedId;
  final String Function(T) getItemId;
  final String Function(T) getItemName;
  final ValueChanged<T?> onChanged;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    T? selectedItem;
    if (selectedId != null && items.isNotEmpty) {
      try {
        selectedItem = items.firstWhere(
          (item) => getItemId(item) == selectedId,
        );
      } catch (_) {
        selectedItem = null;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled
              ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: selectedItem,
          isExpanded: true,
          isDense: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hint: Text(
            'Select $label',
            style: TextStyle(
              color: enabled
                  ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
              fontSize: 14,
            ),
          ),
          items: [
            // "None" option to clear selection
            DropdownMenuItem<T?>(
              value: null,
              child: Text(
                'Select $label',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            ...items.map((item) {
              final isSelected = getItemId(item) == selectedId;
              return DropdownMenuItem<T?>(
                value: item,
                child: Text(
                  getItemName(item),
                  style: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.grey.shade300 : Colors.grey.shade900),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ],
          onChanged: enabled ? (value) => onChanged(value) : null,
          dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
          icon: Icon(
            Icons.arrow_drop_down,
            color: enabled
                ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
          ),
        ),
      ),
    );
  }
}
