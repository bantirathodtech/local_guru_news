import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:local_guru_all/src/core/api/custom/endpoints/api_endpoints.dart';
import 'package:local_guru_all/src/core/components/paginated_list/rss_cache_manager.dart';
import 'package:local_guru_all/src/src.dart';

import '../../../../../../core/log/logging.dart';
import '../../../../rss/feed_parser.dart';
import '../../../../rss/rss_utils.dart';

class PostPaginationService {
  // Page size for pagination (number of posts per page)
  static const int pageSize = 20;

  // RSS cache manager instance
  static final RssCacheManager _rssCache = RssCacheManager();

  static Future<List<PostsModel>> fetchPosts(
      String topicId, String topicType, int page, String userId) async {
    AppLogger.logInfo(
        'fetchPosts called with topicId=$topicId, page=$page, userId=$userId');

    Map<String, String> body = {
      'userId': userId,
      'page': page.toString(),
      'topicid': topicType == 'landmark'
          ? (userId != '0' ? userId : '0')
          : (topicId.isNotEmpty && topicId.contains('/'))
              ? topicId.split('/').last
              : (topicId.isNotEmpty ? topicId : '0'),
      'topicType': topicType.isNotEmpty ? topicType : 'general',
    };

    List<PostsModel> apiPosts = [];
    try {
      final response =
          await http.post(Uri.parse(ApiEndpoints.postApi), body: body);

      AppLogger.logInfo('API response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          // Trim whitespace and check if it's valid JSON
          final trimmedBody = response.body.trim();
          if (trimmedBody.isEmpty) {
            AppLogger.logInfo('API response body is empty after trimming');
          } else {
            Map<String, dynamic> result = json.decode(trimmedBody);
            List<dynamic> apiList = result['result'] ?? [];
            apiPosts = apiList.map((e) => PostsModel.fromJson(e)).toList();
            AppLogger.logInfo('Parsed API posts count: ${apiPosts.length}');
          }
        } catch (e) {
          AppLogger.logError('Error parsing API response: $e');
          // Continue execution - RSS feeds will still work
        }
      } else {
        AppLogger.logInfo(
            'API Response error or empty: status=${response.statusCode}, bodyLength=${response.body.length}');
      }
    } catch (e) {
      AppLogger.logError('Error fetching from API: $e');
      // Continue execution - RSS feeds will still work
    }

    // Fetch RSS posts with caching and pagination
    List<PostsModel> rssPosts = await _fetchRssPostsWithPagination(
        topicId, topicType, page);

    // Combine API and RSS posts
    List<PostsModel> combinedPosts = []
      ..addAll(apiPosts)
      ..addAll(rssPosts);

    // Sort combined list by post time descending
    combinedPosts.sort((a, b) {
      DateTime bTime = DateTime.tryParse(b.time ?? '') ?? DateTime.now();
      DateTime aTime = DateTime.tryParse(a.time ?? '') ?? DateTime.now();
      return bTime.compareTo(aTime);
    });

    AppLogger.logInfo(
        'Total combined posts count: ${combinedPosts.length} (API: ${apiPosts.length}, RSS: ${rssPosts.length})');

    return combinedPosts;
  }

  // Track if initial fast feeds are being fetched
  static bool _isInitialFetching = false;
  // Track if background fetching is running
  static bool _isBackgroundFetching = false;

  /// Fetch RSS posts with caching and pagination
  /// 
  /// This method:
  /// 1. Checks cache for RSS feeds
  /// 2. Fetches priority feeds first for immediate content
  /// 3. Continues fetching other feeds in background
  /// 4. Applies topic filtering
  /// 5. Returns paginated results
  static Future<List<PostsModel>> _fetchRssPostsWithPagination(
    String topicId,
    String topicType,
    int page,
  ) async {
    // Clear expired cache entries
    _rssCache.clearExpiredCache();

    // On first page, fetch priority feeds first, then continue in background
    if (page == 1 && !_isInitialFetching) {
      _isInitialFetching = true;
      
      // Fetch priority feeds first (first 5 feeds for immediate content)
      await _fetchPriorityRssFeeds();
      
      // Start background fetching for remaining feeds (non-blocking)
      _fetchRemainingRssFeedsInBackground();
    }

    // Get all cached posts (from cache + any feeds that have completed)
    List<PostsModel> allCachedPosts = _rssCache.getAllCachedPosts();

    // Apply topic filtering if needed
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

    // Get paginated posts
    final paginatedPosts =
        _rssCache.getPaginatedPosts(allCachedPosts, page, pageSize);

    AppLogger.logInfo(
        'RSS pagination: page=$page, pageSize=$pageSize, returned=${paginatedPosts.length}, totalCached=${allCachedPosts.length}');

    return paginatedPosts;
  }

  /// Fetch priority RSS feeds first (first 5 feeds for immediate content)
  /// These are fetched in parallel for faster initial load
  static Future<void> _fetchPriorityRssFeeds() async {
    AppLogger.logInfo('Fetching priority RSS feeds (first 5) for immediate content...');

    // Get first 5 feeds as priority feeds
    final priorityFeeds = rssFeeds.take(5).toList();
    
    // Fetch priority feeds in parallel
    final futures = priorityFeeds.map((feed) async {
      try {
        final feedUrl = feed['url']!;
        
        // Check if we need to fetch (cache expired or missing)
        if (_rssCache.needsRefresh(feedUrl)) {
          AppLogger.logInfo('Fetching priority RSS feed: ${feed["name"]}');
          final parsedPosts = await FeedParser.parseRssFromUrl(feedUrl);
          _rssCache.cacheFeed(feedUrl, parsedPosts);
          AppLogger.logInfo(
              'Cached priority RSS feed ${feed["name"]}: ${parsedPosts.length} posts');
        } else {
          AppLogger.logInfo(
              'Using cached priority RSS feed: ${feed["name"]} (cache still valid)');
        }
      } catch (e) {
        AppLogger.logError('Error fetching priority RSS feed (${feed["url"]}): $e');
      }
    }).toList();

    // Wait for all priority feeds to complete (parallel execution)
    await Future.wait(futures);
    
    AppLogger.logInfo('Priority RSS feeds completed');
  }

  /// Fetch remaining RSS feeds in background (non-blocking)
  /// This runs asynchronously and doesn't block the UI
  static void _fetchRemainingRssFeedsInBackground() {
    if (_isBackgroundFetching) {
      AppLogger.logInfo('Background RSS fetching already in progress');
      return;
    }

    _isBackgroundFetching = true;
    
    // Run in background without blocking
    Future.microtask(() async {
      AppLogger.logInfo('Starting background RSS feed fetching...');
      
      // Get remaining feeds (skip first 5 priority feeds)
      final remainingFeeds = rssFeeds.skip(5).toList();
      
      // Fetch remaining feeds in parallel batches of 5
      const batchSize = 5;
      for (int i = 0; i < remainingFeeds.length; i += batchSize) {
        final batch = remainingFeeds.skip(i).take(batchSize).toList();
        
        // Fetch batch in parallel
        await Future.wait(
          batch.map((feed) async {
            try {
              final feedUrl = feed['url']!;
              
              // Check if we need to fetch (cache expired or missing)
              if (_rssCache.needsRefresh(feedUrl)) {
                AppLogger.logInfo('Fetching RSS feed (background): ${feed["name"]}');
                final parsedPosts = await FeedParser.parseRssFromUrl(feedUrl);
                _rssCache.cacheFeed(feedUrl, parsedPosts);
                AppLogger.logInfo(
                    'Cached RSS feed (background) ${feed["name"]}: ${parsedPosts.length} posts');
              } else {
                AppLogger.logInfo(
                    'Using cached RSS feed (background): ${feed["name"]} (cache still valid)');
              }
            } catch (e) {
              AppLogger.logError('Error fetching RSS feed (background) (${feed["url"]}): $e');
            }
          }).toList(),
        );
      }
      
      AppLogger.logInfo('Background RSS feed fetching completed');
      _isBackgroundFetching = false;
    });
  }
}
