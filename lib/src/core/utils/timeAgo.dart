import 'package:intl/intl.dart';

extension TimeAgo on String {
  static final List<DateFormat> _fallbackFormats = <DateFormat>[
    DateFormat("yyyy-MM-dd HH:mm:ss"),
    DateFormat("yyyy-MM-dd HH:mm:ss.SSS"),
    DateFormat("yyyy-MM-dd'T'HH:mm:ss"),
    DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'"),
    DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
    DateFormat("yyyy-MM-dd'T'HH:mm:ssZ"),
    DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ"),
    DateFormat("EEE, dd MMM yyyy HH:mm:ss Z"),
    DateFormat("EEE, dd MMM yyyy HH:mm:ss zzz"),
    DateFormat("dd MMM yyyy hh:mma"),
    DateFormat("dd MMM yyyy hh:mm a"),
    DateFormat("dd MMM yyyy, hh:mma"),
    DateFormat("dd MMM yyyy, hh:mm a"),
  ];

  static String displayTimeAgoFromTimestamp(String? timestamp) {
    if (timestamp == null) return 'Unknown time';
    final normalized = timestamp.trim();
    if (normalized.isEmpty ||
        normalized == '0000-00-00 00:00:00' ||
        normalized.toLowerCase() == 'null') {
      return 'Unknown time';
    }

    final parsed = _parseTimestamp(normalized);
    if (parsed == null) {
      return 'Unknown time';
    }

    final now = DateTime.now();
    final localDate = parsed.isUtc ? parsed.toLocal() : parsed;
    final difference = now.difference(localDate);
    if (difference.isNegative) {
      return _formatDate(localDate);
    }

    if (difference.inMinutes < 1) {
      return _formatDate(localDate);
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  static DateTime? _parseTimestamp(String timestamp) {
    final direct = DateTime.tryParse(timestamp);
    if (direct != null) {
      return direct;
    }

    for (final format in _fallbackFormats) {
      try {
        return format.parse(timestamp, true);
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  static String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}
