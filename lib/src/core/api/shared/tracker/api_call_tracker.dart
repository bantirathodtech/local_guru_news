// lib/core/api/tracker/api_call_tracker.dart

/// ApiCallTracker is responsible for tracking:
///  1. Number of **active API calls** per endpoint
///  2. **Total calls made** per endpoint in the entire app session
///  3. The **last time** each endpoint was called
///
///  This is helpful for:
///    - Debugging duplicate or too frequent calls
///    - Monitoring concurrent requests
///    - Providing runtime API call statistics
class ApiCallTracker {
  // 1. Map to store current active call counts per endpoint
  static final Map<String, int> _activeCalls = {};

  // 2. Map to store total calls made per endpoint during app lifetime
  static final Map<String, int> _totalCalls = {};

  // 3. Map to store the last call time per endpoint
  static final Map<String, DateTime> _lastCallTime = {};

  /// 4. Increment counters when a call starts
  static void increment(String endpoint) {
    _activeCalls[endpoint] = (_activeCalls[endpoint] ?? 0) + 1;
    _totalCalls[endpoint] = (_totalCalls[endpoint] ?? 0) + 1;
    _lastCallTime[endpoint] = DateTime.now();
  }

  /// 5. Decrement active counter when a call completes
  static void decrement(String endpoint) {
    if (_activeCalls.containsKey(endpoint)) {
      _activeCalls[endpoint] =
          (_activeCalls[endpoint]! - 1).clamp(0, double.infinity).toInt();

      // Remove entry if count hits zero for cleaner stats
      if (_activeCalls[endpoint] == 0) {
        _activeCalls.remove(endpoint);
      }
    }
  }

  /// 6. Get the number of ongoing calls for a specific endpoint
  static int getActiveCount(String endpoint) => _activeCalls[endpoint] ?? 0;

  /// 7. Get the total number of calls ever made for a specific endpoint
  static int getTotalCount(String endpoint) => _totalCalls[endpoint] ?? 0;

  /// 8. Get the last call time for a specific endpoint
  static DateTime? getLastCallTime(String endpoint) => _lastCallTime[endpoint];

  /// 9. Check if an endpoint is currently active
  static bool isEndpointActive(String endpoint) => getActiveCount(endpoint) > 0;

  /// 10. Returns a snapshot summary of API usage for debugging/logging
  static Map<String, dynamic> getStats() {
    return {
      "activeCalls": Map.unmodifiable(_activeCalls),
      "totalCalls": Map.unmodifiable(_totalCalls),
      "lastCallTime": Map.unmodifiable(
        _lastCallTime.map(
          (key, value) => MapEntry(key, value.toIso8601String()),
        ),
      ),
    };
  }

  /// 11. Pretty print the current API tracking stats (for debugging)
  static String prettyPrintStats() {
    final buffer = StringBuffer('\n📊 API Call Tracker Stats 📊\n');
    _totalCalls.forEach((endpoint, total) {
      final active = getActiveCount(endpoint);
      final lastTime = _lastCallTime[endpoint]?.toIso8601String() ?? 'Never';
      buffer.writeln(
          '- $endpoint → Active: $active | Total: $total | LastCall: $lastTime');
    });
    return buffer.toString();
  }
}
