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

  String get _timeAgo =>
      TimeAgo.displayTimeAgoFromTimestamp(post.time ?? post.readableTime);

  String get _views => _formatCount(post.views);

  String get _comments => _formatCount(post.comments);

  String get _topic => post.topic ?? 'General';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
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
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        label: _timeAgo,
                      ),
                      if (_views.isNotEmpty)
                        _MetaChip(
                          icon: Icons.visibility_rounded,
                          label: '$_views views',
                        ),
                      if (_comments.isNotEmpty)
                        _MetaChip(
                          icon: Icons.mode_comment_outlined,
                          label: '$_comments comments',
                        ),
                      _TopicChip(topic: _topic),
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
    );
  }

  String _formatCount(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final value = int.tryParse(raw.replaceAll(',', ''));
    if (value == null) return raw;
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.topic});

  final String topic;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(topic),
      avatar: const Icon(Icons.local_offer_outlined, size: 16),
      backgroundColor: AppColors.primary.withOpacity(0.08),
      side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
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

