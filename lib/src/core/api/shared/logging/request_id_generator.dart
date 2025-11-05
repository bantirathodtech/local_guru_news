// lib/core/api/logging/request_id_generator.dart
class RequestIdGenerator {
  static final Map<String, int> _endpointCounters = {};

  /// 1. Generate human-readable request ID of format HHmmssSSS-counter
  /// 2. Combines current time and count of calls for the endpoint at that time
  /// 3. Example: "143015123-1" means 2:30:15.123 PM, first call at that time
  static String generate(String endpoint) {
    final now = DateTime.now();

    // 4. Format time as HHmmssSSS
    final timePart = "${now.hour.toString().padLeft(2, '0')}"
        "${now.minute.toString().padLeft(2, '0')}"
        "${now.second.toString().padLeft(2, '0')}"
        "${now.millisecond.toString().padLeft(3, '0')}";

    // 5. Use key with endpoint + time to track per-millisecond request count
    final key = "$endpoint-$timePart";

    // 6. Increment counter or start at 1
    _endpointCounters[key] = (_endpointCounters[key] ?? 0) + 1;

    // 7. Compose final request ID combining time and count
    final countPart = _endpointCounters[key];

    return "$timePart-$countPart";
  }
}
