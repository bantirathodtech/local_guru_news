import 'package:local_guru_all/src/src.dart';

/// Manages caching and pagination for RSS feeds
/// 
/// This class handles:
/// - Caching RSS feed data to avoid re-fetching
/// - Paginating cached RSS posts
/// - Managing cache expiration
class RssCacheManager {
  static final RssCacheManager _instance = RssCacheManager._internal();
  factory RssCacheManager() => _instance;
  RssCacheManager._internal();

  // Cache storage
  Map<String, List<PostsModel>> _rssCache = {};
  Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache expiration time (5 minutes)
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// Get cached RSS posts for a feed URL
  List<PostsModel>? getCachedFeed(String url) {
    if (_rssCache.containsKey(url)) {
      final timestamp = _cacheTimestamps[url];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheExpiration) {
        return _rssCache[url];
      } else {
        // Cache expired, remove it
        _rssCache.remove(url);
        _cacheTimestamps.remove(url);
      }
    }
    return null;
  }

  /// Cache RSS posts for a feed URL
  void cacheFeed(String url, List<PostsModel> posts) {
    _rssCache[url] = posts;
    _cacheTimestamps[url] = DateTime.now();
  }

  /// Get paginated posts from cached RSS feeds
  /// 
  /// Returns posts for the specified page
  /// [page] - Page number (1-indexed)
  /// [pageSize] - Number of items per page
  /// [allCachedPosts] - All cached posts from all feeds
  List<PostsModel> getPaginatedPosts(
    List<PostsModel> allCachedPosts,
    int page,
    int pageSize,
  ) {
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= allCachedPosts.length) {
      return [];
    }

    if (endIndex > allCachedPosts.length) {
      return allCachedPosts.sublist(startIndex);
    }

    return allCachedPosts.sublist(startIndex, endIndex);
  }

  /// Clear all cached RSS feeds
  void clearCache() {
    _rssCache.clear();
    _cacheTimestamps.clear();
  }

  /// Clear expired cache entries
  void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) >= _cacheExpiration) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _rssCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Get all cached posts from all feeds (combined)
  List<PostsModel> getAllCachedPosts() {
    final allPosts = <PostsModel>[];
    _rssCache.forEach((url, posts) {
      allPosts.addAll(posts);
    });

    // Sort by time (newest first)
    allPosts.sort((a, b) {
      DateTime bTime = DateTime.tryParse(b.time ?? '') ?? DateTime.now();
      DateTime aTime = DateTime.tryParse(a.time ?? '') ?? DateTime.now();
      return bTime.compareTo(aTime);
    });

    return allPosts;
  }

  /// Check if cache needs refresh
  bool needsRefresh(String url) {
    final cached = getCachedFeed(url);
    return cached == null;
  }
}

