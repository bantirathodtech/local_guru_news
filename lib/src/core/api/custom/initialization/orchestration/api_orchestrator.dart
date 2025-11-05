// lib/core/api/orchestration/api_orchestrator.dart
import 'package:flutter/material.dart';
import 'package:local_guru_all/src/core/data/cache/cache_manager.dart';

// import '../../../../data/cache/cache_manager.dart';
import 'api_registry.dart';

enum ApiCallType {
  onScreenOpen, // When screen first loads
  onPullRefresh, // When user pulls to refresh
  onManualRefresh, // When user taps refresh button
  onAppStart, // During app initialization
  onUserAction // Triggered by specific user actions
}

class ApiOrchestrator {
  // Track API call states per call type
  static final Map<String, Map<ApiCallType, DateTime>> _lastApiCalls = {};
  static final Map<String, Map<ApiCallType, int>> _apiCallCounts = {};

  // Main method to orchestrate API calls
  static Future<void> call({
    required BuildContext context,
    required String apiIdentifier,
    required Future<void> Function() apiCall,
    required ApiCallType callType,
    bool forceRefresh = false,
    bool useCache = true,
  }) async {
    try {
      // Check if we should skip this call based on call type
      if (!_shouldMakeApiCall(apiIdentifier, callType, forceRefresh)) {
        debugPrint(
            'Skipping $apiIdentifier call of type $callType (rate limited)');
        return;
      }

      // Try cache first for appropriate call types
      if (useCache && _shouldUseCache(callType, forceRefresh)) {
        final cachedData = await _getCachedData(apiIdentifier);
        if (cachedData != null && !forceRefresh) {
          _updateCallStats(apiIdentifier, callType);
          debugPrint('Using cached data for $apiIdentifier ($callType)');
          return;
        }
      }

      // Execute the API call
      debugPrint('Making API call: $apiIdentifier ($callType)');
      await apiCall();

      // Update tracking
      _updateCallStats(apiIdentifier, callType);

      // Cache the result if appropriate
      if (useCache && _shouldCacheResult(callType)) {
        await _cacheApiResult(apiIdentifier);
      }
    } catch (e) {
      debugPrint('API Orchestrator error for $apiIdentifier ($callType): $e');

      // Fallback to cache on error for certain call types
      if ((callType == ApiCallType.onScreenOpen ||
              callType == ApiCallType.onAppStart) &&
          useCache) {
        await _fallbackToCache(apiIdentifier);
      } else {
        rethrow;
      }
    }
  }

  static bool _shouldMakeApiCall(
    String apiIdentifier,
    ApiCallType callType,
    bool forceRefresh,
  ) {
    final config = ApiRegistry.getConfig(apiIdentifier);
    final lastCall = _getLastCallTime(apiIdentifier, callType);

    // Always make these calls regardless of timing
    if (callType == ApiCallType.onAppStart ||
        callType == ApiCallType.onUserAction ||
        forceRefresh) {
      return true;
    }

    // For screen open calls, check minimum interval
    if (callType == ApiCallType.onScreenOpen && lastCall != null) {
      final timeSinceLastCall = DateTime.now().difference(lastCall);
      return timeSinceLastCall > config.minRefreshInterval;
    }

    // For refresh calls, always allow but track separately
    if (callType == ApiCallType.onPullRefresh ||
        callType == ApiCallType.onManualRefresh) {
      return true; // Always allow refresh actions
    }

    return true;
  }

  static bool _shouldUseCache(ApiCallType callType, bool forceRefresh) {
    return (callType == ApiCallType.onScreenOpen ||
            callType == ApiCallType.onAppStart) &&
        !forceRefresh;
  }

  static bool _shouldCacheResult(ApiCallType callType) {
    return callType !=
        ApiCallType.onUserAction; // Don't cache user actions by default
  }

  static Future<dynamic> _getCachedData(String apiIdentifier) async {
    final cache = CacheManager();
    await cache.initialize();
    return await cache.get(apiIdentifier);
  }

  static Future<void> _cacheApiResult(String apiIdentifier) async {
    // Implement your specific caching strategy here
    // This would cache the actual API response data
    debugPrint('Caching result for $apiIdentifier');
  }

  static Future<void> _fallbackToCache(String apiIdentifier) async {
    debugPrint('Falling back to cache for $apiIdentifier');
    // Implement fallback logic to use cached data when API fails
  }

  static void _updateCallStats(String apiIdentifier, ApiCallType callType) {
    // Initialize maps if they don't exist
    _lastApiCalls[apiIdentifier] ??= {};
    _apiCallCounts[apiIdentifier] ??= {};

    _lastApiCalls[apiIdentifier]![callType] = DateTime.now();
    _apiCallCounts[apiIdentifier]![callType] =
        (_apiCallCounts[apiIdentifier]![callType] ?? 0) + 1;
  }

  static DateTime? _getLastCallTime(
      String apiIdentifier, ApiCallType callType) {
    return _lastApiCalls[apiIdentifier]?[callType];
  }

  // Utility methods
  static DateTime? getLastCallTime(String apiIdentifier, ApiCallType callType) {
    return _getLastCallTime(apiIdentifier, callType);
  }

  static int getCallCount(String apiIdentifier, ApiCallType callType) {
    return _apiCallCounts[apiIdentifier]?[callType] ?? 0;
  }

  static int getTotalCallCount(String apiIdentifier) {
    return _apiCallCounts[apiIdentifier]
            ?.values
            .fold(0, (sum, count) => sum! + count) ??
        0;
  }

  static void clearApiHistory(String apiIdentifier, [ApiCallType? callType]) {
    if (callType == null) {
      _lastApiCalls.remove(apiIdentifier);
      _apiCallCounts.remove(apiIdentifier);
    } else {
      _lastApiCalls[apiIdentifier]?.remove(callType);
      _apiCallCounts[apiIdentifier]?.remove(callType);
    }
  }

  static void clearAllHistory() {
    _lastApiCalls.clear();
    _apiCallCounts.clear();
  }

  // Method to get API call analytics
  static Map<String, dynamic> getApiAnalytics() {
    final analytics = <String, dynamic>{};

    _apiCallCounts.forEach((apiId, callCounts) {
      analytics[apiId] = {
        'totalCalls': callCounts.values.fold(0, (sum, count) => sum + count),
        'byType':
            callCounts.map((key, value) => MapEntry(key.toString(), value)),
        'lastCalls': _lastApiCalls[apiId]
            ?.map((key, value) => MapEntry(key.toString(), value.toString())),
      };
    });

    return analytics;
  }

  // Method to check if a specific call type is rate limited
  static bool isRateLimited(String apiIdentifier, ApiCallType callType) {
    final lastCall = _getLastCallTime(apiIdentifier, callType);
    if (lastCall == null) return false;

    final config = ApiRegistry.getConfig(apiIdentifier);
    return DateTime.now().difference(lastCall) < config.minRefreshInterval;
  }
}
