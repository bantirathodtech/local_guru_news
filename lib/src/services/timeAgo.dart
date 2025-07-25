extension TimeAgo on String {
  static String displayTimeAgoFromTimestamp(String? timestamp) {
    // --- START OF UPDATED CODE ---
    if (timestamp == null || timestamp.isEmpty) {
      return 'Unknown time'; // Return fallback for null or empty timestamp
    }

    // Validate timestamp length and basic format (e.g., at least 16 chars for YYYY-MM-DDTHH:MM)
    if (timestamp.length < 16 || !timestamp.contains('T')) {
      return 'Invalid time format'; // Return fallback for invalid format
    }

    try {
      // --- END OF UPDATED CODE ---
      final year = int.parse(timestamp.substring(0, 4));
      final month = int.parse(timestamp.substring(5, 7));
      final day = int.parse(timestamp.substring(8, 10));
      final hour = int.parse(timestamp.substring(11, 13));
      final minute = int.parse(timestamp.substring(14, 16));

      final DateTime videoDate = DateTime(year, month, day, hour, minute);
      final int diffInHours = DateTime.now().difference(videoDate).inHours;

      String timeAgo = '';
      String timeUnit = '';
      int timeValue = 0;

      if (diffInHours < 1) {
        final diffInMinutes = DateTime.now().difference(videoDate).inMinutes;
        timeValue = diffInMinutes;
        timeUnit = 'minute';
      } else if (diffInHours < 24) {
        timeValue = diffInHours;
        timeUnit = 'hour';
      } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
        timeValue = (diffInHours / 24).floor();
        timeUnit = 'day';
      } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
        timeValue = (diffInHours / (24 * 7)).floor();
        timeUnit = 'week';
      } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
        timeValue = (diffInHours / (24 * 30)).floor();
        timeUnit = 'month';
      } else {
        timeValue = (diffInHours / (24 * 365)).floor();
        timeUnit = 'year';
      }

      timeAgo = timeValue.toString() + ' ' + timeUnit;
      timeAgo += timeValue > 1 ? 's' : '';

      return timeAgo + ' ago';
    } catch (e) {
      // --- START OF UPDATED CODE ---
      return 'Invalid time'; // Return fallback for parsing errors
      // --- END OF UPDATED CODE ---
    }
  }
}
//Old code written by Balu
// extension TimeAgo on String {
//   static String displayTimeAgoFromTimestamp(String timestamp) {
//     final year = int.parse(timestamp.substring(0, 4));
//     final month = int.parse(timestamp.substring(5, 7));
//     final day = int.parse(timestamp.substring(8, 10));
//     final hour = int.parse(timestamp.substring(11, 13));
//     final minute = int.parse(timestamp.substring(14, 16));
//
//     final DateTime videoDate = DateTime(year, month, day, hour, minute);
//     final int diffInHours = DateTime.now().difference(videoDate).inHours;
//
//     String timeAgo = '';
//     String timeUnit = '';
//     int timeValue = 0;
//
//     if (diffInHours < 1) {
//       final diffInMinutes = DateTime.now().difference(videoDate).inMinutes;
//       timeValue = diffInMinutes;
//       timeUnit = 'minute';
//     } else if (diffInHours < 24) {
//       timeValue = diffInHours;
//       timeUnit = 'hour';
//     } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
//       timeValue = (diffInHours / 24).floor();
//       timeUnit = 'day';
//     } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
//       timeValue = (diffInHours / (24 * 7)).floor();
//       timeUnit = 'week';
//     } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
//       timeValue = (diffInHours / (24 * 30)).floor();
//       timeUnit = 'month';
//     } else {
//       timeValue = (diffInHours / (24 * 365)).floor();
//       timeUnit = 'year';
//     }
//
//     timeAgo = timeValue.toString() + ' ' + timeUnit;
//     timeAgo += timeValue > 1 ? 's' : '';
//
//     return timeAgo + ' ago';
//   }
// }
