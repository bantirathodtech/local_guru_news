import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:local_guru_all/src/core/constants/app_colors.dart';
import 'package:local_guru_all/src/core/utils/timeAgo.dart';
import 'package:local_guru_all/src/features/news/data/model/posts/all/posts_Model.dart';

class NewsFeedCard extends StatelessWidget {
  const NewsFeedCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.footer,
    this.thumbnailUrl,
  });

  final PostsModel post;
  final VoidCallback onTap;
  final Widget footer;
  final String? thumbnailUrl;

  bool get _isVideoLayout {
    final layout = post.layout?.toLowerCase() ?? '';
    return layout.contains('video') || layout.contains('youtube');
  }

  String get _formattedDate {
    if (post.readableTime != null && post.readableTime!.isNotEmpty) {
      return post.readableTime!;
    }
    if (post.time != null && post.time!.isNotEmpty) {
      return TimeAgo.displayTimeAgoFromTimestamp(post.time!);
    }
    return '';
  }

  String get _views => post.views ?? '0';

  String get _likes => post.likes ?? '0';

  String _formatCount(String count) {
    final parsed = int.tryParse(count) ?? 0;
    if (parsed >= 1000000) {
      return '${(parsed / 1000000).toStringAsFixed(1)}M';
    } else if (parsed >= 1000) {
      return '${(parsed / 1000).toStringAsFixed(1)}K';
    }
    return parsed.toString();
  }

  String? get _topic {
    final topic = post.topic;
    // Return null if topic is null, empty, or "General" to hide the chip
    if (topic == null || topic.isEmpty || topic.toLowerCase() == 'general') {
      return null;
    }
    return topic;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white : Colors.black,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((thumbnailUrl != null && thumbnailUrl!.isNotEmpty) ||
                (post.media != null && post.media!.isNotEmpty))
              _MediaPreview(
                imageUrl: thumbnailUrl ?? post.media?.first.toString(),
                isVideo: _isVideoLayout,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChannelRow(
                    channelName: post.channel,
                    channelImage: post.channelImage,
                    editorName: post.editor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.title ?? 'Untitled story',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if ((post.description?.isNotEmpty ?? false))
                    Text(
                      post.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 14),
                  // Views and Date Row
                  Row(
                    children: [
                      if (_likes.isNotEmpty && _likes != '0')
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 16,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_formatCount(_likes)} likes',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: theme.brightness == Brightness.dark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                            ),
                          ],
                        ),
                      if (_likes.isNotEmpty &&
                          _likes != '0' &&
                          _views.isNotEmpty &&
                          _views != '0')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      if (_views.isNotEmpty && _views != '0')
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              size: 16,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$_views views',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      if (_views.isNotEmpty && _views != '0' && _formattedDate.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      if (_formattedDate.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formattedDate,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      if (_topic != null) ...[
                        const Spacer(),
                        _TopicChip(topic: _topic!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: footer,
            ),
          ],
        ),
      ),
      ),
    );
  }

}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({
    required this.imageUrl,
    required this.isVideo,
  });

  final String? imageUrl;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            FancyShimmerImage(
              imageUrl: imageUrl!,
              boxFit: BoxFit.cover,
              shimmerBaseColor: Colors.grey.shade200,
              shimmerHighlightColor: Colors.grey.shade100,
              errorWidget: Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image_outlined),
              ),
            )
          else
            Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported_outlined),
            ),
          if (isVideo)
            const Positioned(
              top: 12,
              right: 12,
              child: _Badge(label: 'VIDEO'),
            ),
        ],
      ),
    );
  }
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({
    this.channelName,
    this.channelImage,
    this.editorName,
  });

  final String? channelName;
  final String? channelImage;
  final String? editorName;

  @override
  Widget build(BuildContext context) {
    final resolvedName = channelName?.isNotEmpty == true
        ? channelName!
        : (editorName?.isNotEmpty == true ? editorName! : 'Unknown source');

    return Row(
      children: [
        // Left side: Channel image and name
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withOpacity(0.12),
          backgroundImage: (channelImage != null && channelImage!.isNotEmpty)
              ? NetworkImage(channelImage!)
              : null,
          child: (channelImage == null || channelImage!.isEmpty)
              ? Text(
                  resolvedName.characters.first.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resolvedName,
                style: Theme.of(context).textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (editorName != null && editorName!.isNotEmpty)
                Text(
                  editorName!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.topic});

  final String topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Chip(
      label: Text(topic),
      avatar: Icon(
        Icons.local_offer_outlined,
        size: 16,
        color: isDark ? primary : AppColors.primary,
      ),
      backgroundColor: isDark
          ? primary.withOpacity(0.15)
          : AppColors.primary.withOpacity(0.08),
      side: BorderSide(
        color: isDark
            ? primary.withOpacity(0.4)
            : AppColors.primary.withOpacity(0.2),
      ),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? primary : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}

