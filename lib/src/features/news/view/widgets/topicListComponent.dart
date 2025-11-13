import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/log/logging.dart';
import 'package:sizer/sizer.dart';

import '../../../../src.dart';

class TopicListComponent extends ConsumerWidget {
  final String? id;
  final String? name;
  final String? type;
  final String? iconUrl;

  const TopicListComponent({
    Key? key,
    this.id,
    this.name,
    this.type,
    this.iconUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String selectedTopic = ref.watch(topic);
    final bool isSelected = selectedTopic == name;

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final resolvedType =
              type?.trim().isNotEmpty ?? false ? type!.trim() : 'topic';
          if (id != null && name != null) {
            ref.read(selectedPoliticianIdProvider.notifier).state = null;

            AppLogger.logInfo(
              'Legacy topic selected id=$id name=$name type=$resolvedType',
              tag: 'legacyNewsView',
            );
            ref.read(topicId.notifier).state = '$resolvedType/$id';
            ref.read(topic.notifier).state = name!;
            ref.read(topicType.notifier).state = resolvedType;
            ref
                .refresh(legacyPostPaginationControllerProvider.notifier)
                .resetPosts();
            ref
                .read(legacyPostPaginationControllerProvider.notifier)
                .getPosts();
          } else {
            developer.log('Invalid topic data: id=$id, name=$name');
            AppLogger.logWarning(
              'Legacy topic selection failed: missing data',
              tag: 'legacyNewsView',
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.12) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  isSelected ? primary.withOpacity(0.6) : Colors.grey.shade300,
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TopicAvatar(iconUrl: iconUrl, fallbackIcon: _iconForType(type)),
              const SizedBox(width: 8),
              Text(
                name ?? 'Unknown',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? primary : Colors.grey.shade900,
                  letterSpacing: 0.15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle_rounded, size: 16, color: primary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String? raw) {
    final key = raw?.toLowerCase().trim() ?? '';
    switch (key) {
      case 'politician':
        return Icons.campaign_outlined;
      case 'location':
      case 'landmark':
      case 'district':
      case 'state':
        return Icons.place_outlined;
      case 'channel':
        return Icons.live_tv_rounded;
      case 'rss':
      case 'news':
        return Icons.rss_feed_rounded;
      case 'topic':
        return Icons.topic_outlined;
      default:
        return Icons.label_outline;
    }
  }
}

class _TopicAvatar extends StatelessWidget {
  const _TopicAvatar({required this.iconUrl, required this.fallbackIcon});

  final String? iconUrl;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final hasIcon = iconUrl != null && iconUrl!.isNotEmpty;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        image: hasIcon
            ? DecorationImage(
                image: NetworkImage(iconUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasIcon
          ? null
          : Icon(
              fallbackIcon,
              size: 16,
              color: primary,
            ),
    );
  }
}
