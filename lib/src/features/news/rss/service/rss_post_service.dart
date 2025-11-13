import 'package:local_guru_all/src/core/log/logging.dart';
import 'package:local_guru_all/src/src.dart';

import '../repository/feed_parser.dart';
import '../endpoints/rss_utils.dart';

/// Service responsible for loading RSS posts and exposing paginated results.
///
/// All RSS-specific logic (caching, batching, background fetching) lives here
/// so that API concerns can stay isolated inside their own service.
class RssPostService {
  RssPostService._();

  static final RssPostService instance = RssPostService._();

  static const int _pageSize = 20;

  final RssCacheManager _rssCache = RssCacheManager();

  bool _isInitialFetching = false;
  bool _isBackgroundFetching = false;

  Future<List<PostsModel>> fetchRssPostsWithPagination({
    required String topicId,
    required String topicType,
    required int page,
  }) async {
    _rssCache.clearExpiredCache();

    if (page == 1 && !_isInitialFetching) {
      _isInitialFetching = true;

      await _fetchPriorityRssFeeds();
      _fetchRemainingRssFeedsInBackground();
    }

    List<PostsModel> allCachedPosts = _rssCache.getAllCachedPosts();

    if (topicId.isNotEmpty && topicType.isNotEmpty) {
      final topicName = topicId.split('/').last;
      allCachedPosts = allCachedPosts.where((post) {
        final postTopic = post.topic?.toLowerCase() ?? '';
        final postTitle = post.title?.toLowerCase() ?? '';
        final postDesc = post.description?.toLowerCase() ?? '';
        final searchTopic = topicName.toLowerCase();

        return postTopic.contains(searchTopic) ||
            postTitle.contains(searchTopic) ||
            postDesc.contains(searchTopic);
      }).toList();
    }

    final paginatedPosts =
        _rssCache.getPaginatedPosts(allCachedPosts, page, _pageSize);

    AppLogger.logInfo(
      'RSS pagination: page=$page, pageSize=$_pageSize, returned=${paginatedPosts.length}, totalCached=${allCachedPosts.length}',
    );

    return paginatedPosts;
  }

  Future<void> _fetchPriorityRssFeeds() async {
    AppLogger.logInfo(
      'Fetching priority RSS feeds (first 5) for immediate content...',
    );

    final priorityFeeds = rssFeeds.take(5).toList();

    final futures = priorityFeeds.map((feed) async {
      try {
        final feedUrl = feed['url']!;

        if (_rssCache.needsRefresh(feedUrl)) {
          AppLogger.logInfo('Fetching priority RSS feed: ${feed["name"]}');
          final parsedPosts = await FeedParser.parseRssFromUrl(feedUrl);
          _rssCache.cacheFeed(feedUrl, parsedPosts);
          AppLogger.logInfo(
            'Cached priority RSS feed ${feed["name"]}: ${parsedPosts.length} posts',
          );
        } else {
          AppLogger.logInfo(
            'Using cached priority RSS feed: ${feed["name"]} (cache still valid)',
          );
        }
      } catch (e) {
        AppLogger.logError(
          'Error fetching priority RSS feed (${feed["url"]}): $e',
        );
      }
    }).toList();

    await Future.wait(futures);

    AppLogger.logInfo('Priority RSS feeds completed');
  }

  void _fetchRemainingRssFeedsInBackground() {
    if (_isBackgroundFetching) {
      AppLogger.logInfo('Background RSS fetching already in progress');
      return;
    }

    _isBackgroundFetching = true;

    Future.microtask(() async {
      AppLogger.logInfo('Starting background RSS feed fetching...');

      final remainingFeeds = rssFeeds.skip(5).toList();

      const batchSize = 5;
      for (int i = 0; i < remainingFeeds.length; i += batchSize) {
        final batch = remainingFeeds.skip(i).take(batchSize).toList();

        await Future.wait(
          batch.map((feed) async {
            try {
              final feedUrl = feed['url']!;

              if (_rssCache.needsRefresh(feedUrl)) {
                AppLogger.logInfo(
                  'Fetching RSS feed (background): ${feed["name"]}',
                );
                final parsedPosts = await FeedParser.parseRssFromUrl(feedUrl);
                _rssCache.cacheFeed(feedUrl, parsedPosts);
                AppLogger.logInfo(
                  'Cached RSS feed (background) ${feed["name"]}: ${parsedPosts.length} posts',
                );
              } else {
                AppLogger.logInfo(
                  'Using cached RSS feed (background): ${feed["name"]} (cache still valid)',
                );
              }
            } catch (e) {
              AppLogger.logError(
                'Error fetching RSS feed (background) (${feed["url"]}): $e',
              );
            }
          }).toList(),
        );
      }

      AppLogger.logInfo('Background RSS feed fetching completed');
      _isBackgroundFetching = false;
    });
  }
}
