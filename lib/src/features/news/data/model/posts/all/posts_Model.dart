import 'dart:convert';

import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';

class PostsModel {
  String? id;
  String? title;
  String? description;
  String? fulldescription;
  String? layout;
  List<String>? media;
  String? channel;
  String? channelImage;
  List<String>? tags;
  String? topic;
  String? editor;
  String? editorProfile;
  String? views;
  String? likes;
  String? dislikes;
  String? liked;
  String? comments;
  String? whatsApp;
  String? time;
  String? readableTime;

  PostsModel({
    this.id,
    this.title,
    this.description,
    this.fulldescription,
    this.layout,
    this.media,
    this.channel,
    this.channelImage,
    this.tags,
    this.topic,
    this.editor,
    this.editorProfile,
    this.views,
    this.likes,
    this.dislikes,
    this.liked,
    this.comments,
    this.whatsApp,
    this.time,
    this.readableTime,
  });

  factory PostsModel.fromJson(Map<String, dynamic> json) {
    final media = _normalizeMediaList(
      json['media'] ??
          json['media_urls'] ??
          json['mediaUrls'] ??
          json['images'] ??
          json['image_list'] ??
          json['image'] ??
          json['thumbnail'] ??
          json['thumb'],
    );

    final channelName = _pickString(json, const [
          'channel',
          'channel_name',
          'channelName',
          'channelname',
          'source',
          'source_name',
          'sourceName',
          'channelTitle',
          'publisher',
          'publisher_name',
        ]) ??
        _asString(json['channel']) ??
        _asString(json['source']) ??
        _asString(json['publisher']);

    final channelImage = _normalizeImageUrl(
      _pickString(json, const [
        'channelImage',
        'channel_image',
        'channelimage',
        'channel_logo',
        'channelLogo',
        'channelIcon',
        'channel_icon',
        'source_image',
        'sourceImage',
        'source_logo',
        'sourceLogo',
        'publisher_image',
        'publisherImage',
        'logo',
        'icon',
        'image',
      ]),
    );

    final tags = _asStringList(
      json['tags'] ??
          json['tag_list'] ??
          json['tagList'] ??
          json['keywords'] ??
          json['keyword'],
    );

    final rawTime = _pickString(json, const [
          'pub_time',
          'publishedAt',
          'pubDate',
          'publication_time',
          'publicationtime',
          'published_time',
          'time',
          'timestamp',
          'date',
          'publish_time',
          'publishTime',
          'published_on',
          'published_on_time',
          'created_at',
          'createdOn',
          'added_date_time',
          'post_time',
        ]) ??
        _asString(json['time']) ??
        _asString(json['timestamp']);

    final rawReadableTime = _pickString(json, const [
      'readableTime',
      'readable_time',
      'display_time',
      'displayTime',
      'formatted_time',
      'formattedTime',
      'time_label',
    ]);

    final resolvedTime = rawTime ?? rawReadableTime;
    final resolvedReadableTime = rawReadableTime ?? rawTime;

    return PostsModel(
      id: _pickString(json, const ['id', 'post_id', 'postId']),
      title: _pickString(json, const ['title', 'post_title', 'heading']),
      description: _pickString(
            json,
            const ['description', 'short_description', 'summary', 'excerpt'],
          ) ??
          _asString(json['description']),
      fulldescription: _pickString(
        json,
        const [
          'fulldescription',
          'full_description',
          'fullDescription',
          'content',
          'body',
          'article',
        ],
      ),
      layout: _pickString(json, const ['layout', 'layoutType', 'type']),
      media: media,
      channel: channelName ?? _pickString(json, const ['editor', 'author']),
      channelImage: channelImage,
      tags: tags,
      topic: _pickString(json, const ['topic', 'category', 'section']),
      editor: _pickString(json, const ['editor', 'author', 'created_by']),
      editorProfile: _normalizeImageUrl(
        _pickString(
          json,
          const [
            'editor_profile',
            'editorImage',
            'author_image',
            'authorImage'
          ],
        ),
      ),
      views: _pickString(json, const ['views', 'view_count', 'viewCount']),
      likes: _pickString(json, const ['likes', 'like_count', 'likeCount']),
      liked: _pickString(json, const ['liked', 'is_liked', 'isLiked']),
      comments: _pickString(
          json, const ['comments', 'comment_count', 'commentCount']),
      dislikes: _pickString(
          json, const ['dislikes', 'dislike_count', 'dislikeCount']),
      whatsApp: _pickString(
        json,
        const ['whats_app', 'whatsApp', 'share_count', 'shareCount'],
      ),
      time: _sanitizeTimestamp(resolvedTime),
      readableTime: _sanitizeTimestamp(resolvedReadableTime) ??
          _sanitizeTimestamp(resolvedTime),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "fulldescription": fulldescription,
        "layout": layout,
        "media": media,
        "channel": channel,
        "channelImage": channelImage,
        'tags': tags,
        "topic": topic,
        "editor": editor,
        'editor_profile': editorProfile,
        "views": views,
        'likes': likes,
        'dislikes': dislikes,
        'liked': liked,
        'comments': comments,
        "whats_app": whatsApp,
        'time': time,
        'readableTime': readableTime,
      };

  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final lower = trimmed.toLowerCase();
      if (lower == 'null' || lower == 'undefined' || lower == 'na') {
        return null;
      }
      return trimmed;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    if (value is Map || value is Iterable) {
      return null;
    }
    final converted = value.toString().trim();
    return converted.isEmpty ? null : converted;
  }

  static List<String>? _asStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      if (value.isEmpty) return null;
      final results = value
          .map((e) => _extractString(e))
          .whereType<String>()
          .where((element) => element.isNotEmpty)
          .toList();
      return results.isEmpty ? null : results;
    }

    if (value is String) {
      final stringValue = _asString(value);
      if (stringValue == null || stringValue.isEmpty) return null;

      try {
        final decoded = json.decode(stringValue);
        if (decoded is List) {
          final results = decoded
              .map((e) => _extractString(e))
              .whereType<String>()
              .where((element) => element.isNotEmpty)
              .toList();
          if (results.isNotEmpty) {
            return results;
          }
        }
      } catch (_) {
        // Not JSON – fall through to delimiter parsing.
      }

      final segments = stringValue
          .split(RegExp(r'[,\|]'))
          .map((segment) => segment.trim())
          .where((segment) => segment.isNotEmpty)
          .toList();
      return segments.isEmpty ? null : segments;
    }

    final extracted = _extractString(value);
    if (extracted != null && extracted.isNotEmpty) {
      return [extracted];
    }
    return null;
  }

  static List<String>? _normalizeMediaList(dynamic value) {
    final list = _asStringList(value);
    if (list == null) return null;

    final normalized = <String>[];
    for (final item in list) {
      final normalizedItem = _normalizeImageUrl(item) ?? item;
      if (normalizedItem.isNotEmpty) {
        normalized.add(normalizedItem);
      }
    }
    return normalized.isEmpty ? null : normalized;
  }

  static String? _pickString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (!json.containsKey(key)) continue;
      final candidate = _extractString(json[key]);
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }

    final normalizedTargets = keys.map(_normalizeKey).toSet();
    for (final entry in json.entries) {
      final normalizedKey = _normalizeKey(entry.key.toString());
      if (normalizedTargets.contains(normalizedKey)) {
        final candidate = _extractString(entry.value);
        if (candidate != null && candidate.isNotEmpty) {
          return candidate;
        }
      }
    }

    return null;
  }

  static String _normalizeKey(String key) =>
      key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static String? _extractString(dynamic value) {
    final direct = _asString(value);
    if (direct != null) {
      return direct;
    }

    if (value is Map) {
      final map = value.map(
        (key, dynamic entryValue) => MapEntry(key.toString(), entryValue),
      );
      return _pickString(
        map,
        const [
          'name',
          'title',
          'label',
          'value',
          'text',
          'display_name',
          'displayName',
          'full_name',
          'fullName',
          'url',
          'link',
          'image',
          'logo',
          'icon',
          'path',
        ],
      );
    }

    if (value is Iterable) {
      for (final element in value) {
        final extracted = _extractString(element);
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }
    }

    return null;
  }

  static String? _normalizeImageUrl(String? value) {
    final candidate = _asString(value);
    if (candidate == null || candidate.isEmpty) return null;
    final trimmed = candidate.replaceAll('\\', '/');
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith(RegExp(r'https?:', caseSensitive: false))) {
      return trimmed;
    }

    if (trimmed.startsWith('//')) {
      return 'https:$trimmed';
    }

    final lower = trimmed.toLowerCase();
    final httpIndex = lower.indexOf('http');
    if (httpIndex > 0) {
      final potential = trimmed.substring(httpIndex);
      if (potential.startsWith(RegExp(r'https?:', caseSensitive: false))) {
        return potential;
      }
    }

    String sanitized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    while (sanitized.startsWith('../')) {
      sanitized = sanitized.substring(3);
    }
    while (sanitized.startsWith('./')) {
      sanitized = sanitized.substring(2);
    }
    if (sanitized.isEmpty) return null;

    if (sanitized.startsWith('localguru.in')) {
      return 'https://$sanitized';
    }

    if (_looksLikeAssetPath(sanitized) ||
        sanitized.startsWith('admin/') ||
        sanitized.startsWith('uploads/') ||
        sanitized.startsWith('storage/') ||
        sanitized.startsWith('_uploads/') ||
        sanitized.startsWith('images/')) {
      final origin = Uri.parse(ApiEndpoints.baseUrl2).origin;
      return '$origin/$sanitized';
    }

    return sanitized;
  }

  static bool _looksLikeAssetPath(String value) {
    final target = value.split('?').first.toLowerCase();
    return target.endsWith('.png') ||
        target.endsWith('.jpg') ||
        target.endsWith('.jpeg') ||
        target.endsWith('.gif') ||
        target.endsWith('.webp') ||
        target.endsWith('.svg') ||
        target.endsWith('.bmp');
  }

  static String? _sanitizeTimestamp(String? value) {
    final candidate = _asString(value);
    if (candidate == null) return null;
    final normalized = candidate.trim();
    if (normalized.isEmpty) return null;
    final lowered = normalized.toLowerCase();
    if (lowered == '0' ||
        lowered == 'null' ||
        lowered == 'undefined' ||
        lowered == 'na' ||
        lowered == 'invalid date' ||
        lowered == 'nan') {
      return null;
    }
    if (normalized == '0000-00-00 00:00:00' ||
        normalized.startsWith('0000-00-00') ||
        normalized.startsWith('01 Jan 1970') ||
        normalized.startsWith('1970-01-01')) {
      return null;
    }
    return normalized;
  }
}
