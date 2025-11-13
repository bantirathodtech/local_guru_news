import 'package:http/http.dart' as http;
import 'package:local_guru_all/src/src.dart';
import 'package:xml/xml.dart';

class FeedParser {
  static Future<List<PostsModel>> parseRssFromUrl(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        var document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        List<PostsModel> posts = [];

        // Extract channel info
        final channelElement = document.findAllElements('channel').firstOrNull;
        String channelName =
            channelElement?.findElements('title').firstOrNull?.text.trim() ??
                'RSS Feed';
        String channelImage = channelElement
                ?.findElements('image')
                .firstOrNull
                ?.findElements('url')
                .firstOrNull
                ?.text
                .trim() ??
            '';

        for (var item in items) {
          try {
            // Extract id either from guid or link
            String id = (item.getElement('guid')?.text ?? '').trim();
            if (id.isEmpty) {
              id = (item.getElement('link')?.text ?? '').trim();
            }

            if (id.isEmpty) continue;

            // Extract title
            String title =
                _stripHtml((item.getElement('title')?.text ?? '').trim());
            if (title.isEmpty) continue;

            // Extract description and strip HTML
            String description =
                _stripHtml((item.getElement('description')?.text ?? '').trim());

            // Extract full description (same as description for RSS)
            String fullDescription = description;

            // Extract category or topic
            String topic = '';
            final categories = item.findAllElements('category');
            if (categories.isNotEmpty) {
              topic = categories.first.text.trim();
            }

            // Extract pubDate (time)
            String pubDate = (item.getElement('pubDate')?.text ?? '').trim();
            String time = _parseRssDate(pubDate);

            // Extract media/enclosure (image)
            List<String> media = [];

            // Method 1: Try to get image from enclosure tag
            final enclosure = item.getElement('enclosure');
            if (enclosure != null) {
              final type = enclosure.getAttribute('type') ?? '';
              if (type.startsWith('image/')) {
                final imageUrl = enclosure.getAttribute('url') ?? '';
                if (imageUrl.isNotEmpty) {
                  final absoluteUrl = _convertToAbsoluteUrl(imageUrl, url);
                  if (_isValidImageUrl(absoluteUrl) &&
                      !media.contains(absoluteUrl)) {
                    media.add(absoluteUrl);
                  }
                }
              }
            }

            // Method 2: Try to get image from media:content (Media RSS namespace)
            final mediaContent = item.findElements('media:content').firstOrNull;
            if (mediaContent != null) {
              final mediaUrl = mediaContent.getAttribute('url') ?? '';
              if (mediaUrl.isNotEmpty) {
                final absoluteUrl = _convertToAbsoluteUrl(mediaUrl, url);
                if (_isValidImageUrl(absoluteUrl) &&
                    !media.contains(absoluteUrl)) {
                  media.add(absoluteUrl);
                }
              }
            }

            // Method 3: Try to get image from media:thumbnail (Media RSS - commonly used)
            final mediaThumbnail =
                item.findElements('media:thumbnail').firstOrNull;
            if (mediaThumbnail != null) {
              final thumbnailUrl = mediaThumbnail.getAttribute('url') ?? '';
              if (thumbnailUrl.isNotEmpty) {
                final absoluteUrl = _convertToAbsoluteUrl(thumbnailUrl, url);
                if (_isValidImageUrl(absoluteUrl) &&
                    !media.contains(absoluteUrl)) {
                  media.add(absoluteUrl);
                }
              }
            }

            // Method 4: Try to get image from direct <image> tag in item
            final imageElement = item.getElement('image');
            if (imageElement != null) {
              final imageUrl = imageElement.text.trim();
              if (imageUrl.isNotEmpty) {
                final absoluteUrl = _convertToAbsoluteUrl(imageUrl, url);
                if (_isValidImageUrl(absoluteUrl) &&
                    !media.contains(absoluteUrl)) {
                  media.add(absoluteUrl);
                }
              }
            }

            // Method 5: Try to get image from content:encoded (WordPress feeds)
            final contentEncoded = item.getElement('content:encoded');
            if (contentEncoded != null) {
              final contentHtml = contentEncoded.text;
              final imgUrl = _extractImageFromHtml(contentHtml);
              if (imgUrl.isNotEmpty) {
                final absoluteUrl = _convertToAbsoluteUrl(imgUrl, url);
                if (_isValidImageUrl(absoluteUrl) &&
                    !media.contains(absoluteUrl)) {
                  media.add(absoluteUrl);
                }
              }
            }

            // Method 6: Try to extract image from description HTML (before stripping)
            // Get the raw description HTML BEFORE stripping
            final descriptionHtml = item.getElement('description')?.text ?? '';
            if (descriptionHtml.isNotEmpty && media.isEmpty) {
              final imgUrl = _extractImageFromHtml(descriptionHtml);
              if (imgUrl.isNotEmpty) {
                // Convert relative URLs to absolute
                final absoluteUrl = _convertToAbsoluteUrl(imgUrl, url);
                if (_isValidImageUrl(absoluteUrl)) {
                  media.add(absoluteUrl);
                }
              }
            }

            // Method 7: Try to get image from link (some feeds put featured image in link)
            // This is a fallback - usually not reliable, but worth trying
            if (media.isEmpty) {
              final link = item.getElement('link')?.text ?? '';
              // Some feeds use link as image URL (rare but possible)
              if (link.isNotEmpty && _isValidImageUrl(link)) {
                media.add(link);
              }
            }

            // Create PostsModel with all fields
            posts.add(PostsModel(
              id: id,
              title: title,
              description: description.length > 200
                  ? '${description.substring(0, 200)}...'
                  : description,
              fulldescription: fullDescription,
              layout: media.isNotEmpty ? 'Image' : 'Text',
              media: media,
              channel: channelName,
              channelImage: channelImage,
              topic: topic.isNotEmpty ? topic : 'General',
              time: time,
              views: '0',
              likes: '0',
              dislikes: '0',
              liked: '0',
              comments: '0',
              whatsApp: '0',
            ));
          } catch (e) {
            // Skip this item if there's an error parsing it
            continue;
          }
        }
        return posts;
      } else {
        return [];
      }
    } catch (e) {
      // Return empty list on any error
      return [];
    }
  }

  // Strip HTML tags from text
  static String _stripHtml(String htmlString) {
    if (htmlString.isEmpty) return '';

    // Remove HTML tags
    String text = htmlString
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#39;'), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return text;
  }

  // Extract image URL from HTML
  static String _extractImageFromHtml(String html) {
    try {
      if (html.isEmpty) return '';

      // Pattern 1: <img ... src="url" or src='url' (most common)
      final pattern1 = '<img[^>]+src=["\']([^"\']+)["\']';
      final imgRegex1 = RegExp(pattern1, caseSensitive: false);
      final match1 = imgRegex1.firstMatch(html);
      if (match1 != null && match1.group(1) != null) {
        String url = match1.group(1)!;
        // Handle relative URLs by converting to absolute if needed
        url = url.trim();
        // Remove query parameters that might break image loading
        if (url.contains('?')) {
          url = url.split('?').first;
        }
        return url;
      }

      // Pattern 2: <img ... src=url (without quotes)
      final pattern2 = '<img[^>]+src=([^\\s>]+)';
      final imgRegex2 = RegExp(pattern2, caseSensitive: false);
      final match2 = imgRegex2.firstMatch(html);
      if (match2 != null && match2.group(1) != null) {
        String url = match2.group(1)!.trim();
        if (url.contains('?')) {
          url = url.split('?').first;
        }
        return url;
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  // Convert relative URL to absolute URL
  static String _convertToAbsoluteUrl(String url, String baseUrl) {
    if (url.isEmpty) return url;

    // If already absolute, return as is
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // If protocol-relative (starts with //), add https:
    if (url.startsWith('//')) {
      return 'https:$url';
    }

    try {
      final baseUri = Uri.parse(baseUrl);
      final base = '${baseUri.scheme}://${baseUri.host}';

      // If relative path (starts with /), combine with base
      if (url.startsWith('/')) {
        return '$base$url';
      }

      // If relative path (doesn't start with /), combine with base path
      final basePath = baseUri.path;
      final basePathDir = basePath.substring(0, basePath.lastIndexOf('/') + 1);
      return '$base$basePathDir$url';
    } catch (e) {
      // If parsing fails, return original URL
      return url;
    }
  }

  // Validate if URL is a valid image URL
  static bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    // Check if it's a valid HTTP/HTTPS URL
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return false;

      // Must be http or https
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return false;
      }

      // Must have a host
      if (uri.host.isEmpty) {
        return false;
      }

      // Check if it looks like an image URL (common extensions)
      final lowerUrl = url.toLowerCase();
      final imageExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.bmp',
        '.svg'
      ];
      final hasImageExtension =
          imageExtensions.any((ext) => lowerUrl.contains(ext));

      // Also accept URLs that might be image endpoints without extension
      // (e.g., CDN URLs or API endpoints)
      // But exclude common non-image paths
      final excludePaths = ['/feed', '/rss', '/xml', '/json', '/api'];
      final hasExcludedPath =
          excludePaths.any((path) => lowerUrl.contains(path));

      if (hasExcludedPath) return false;

      return hasImageExtension ||
          lowerUrl.contains('image') ||
          lowerUrl.contains('img') ||
          lowerUrl.contains('photo') ||
          lowerUrl.contains('wp-content');
    } catch (e) {
      return false;
    }
  }

  // Parse RSS date format to ISO format
  static String _parseRssDate(String rssDate) {
    if (rssDate.isEmpty) return DateTime.now().toIso8601String();

    try {
      // Try to parse the date directly
      final date = DateTime.tryParse(rssDate);
      if (date != null) {
        return date.toIso8601String();
      }

      // Try parsing common RSS date formats manually
      // Note: For proper date parsing, you might want to use intl package
      // For now, we'll try the standard DateTime.parse which handles ISO format
      try {
        // Remove day names like "Mon, " from the start
        String cleanedDate = rssDate;
        if (cleanedDate.contains(',')) {
          cleanedDate = cleanedDate.split(',').skip(1).join(',').trim();
        }
        final date2 = DateTime.tryParse(cleanedDate);
        if (date2 != null) {
          return date2.toIso8601String();
        }
      } catch (e) {
        // Continue to fallback
      }

      // If parsing fails, return current time
      return DateTime.now().toIso8601String();
    } catch (e) {
      return DateTime.now().toIso8601String();
    }
  }
}
