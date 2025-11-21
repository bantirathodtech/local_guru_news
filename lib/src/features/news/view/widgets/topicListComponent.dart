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
    final String selectedTopicType = ref.watch(topicType);
    // Check if this chip is selected by name OR by type (for politician/location topics)
    final bool isSelectedByName = selectedTopic == name;
    final normalizedType = type?.toLowerCase() ?? '';
    final normalizedName = (name ?? '').toLowerCase();
    final isPoliticianChip = normalizedType == 'politician' || normalizedName == 'politician';
    final isLocationChip = normalizedType == 'location' || normalizedName == 'location';
    final bool isSelectedByType = 
        (isPoliticianChip && selectedTopicType.toLowerCase() == 'politician') ||
        (isLocationChip && selectedTopicType.toLowerCase() == 'location');
    final bool isSelected = isSelectedByName || isSelectedByType;

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final resolvedType =
              type?.trim().isNotEmpty ?? false ? type!.trim() : 'topic';
          final normalizedResolvedType = resolvedType.toLowerCase();
          final normalizedName = (name ?? '').trim().toLowerCase();
          final isPoliticianTopic =
              normalizedResolvedType == 'politician' ||
                  normalizedName == 'politician';
          final isLocationTopic =
              normalizedResolvedType == 'location' ||
                  normalizedName == 'location';
          final effectiveType = isPoliticianTopic
              ? 'politician'
              : (isLocationTopic ? 'location' : resolvedType);
          final effectiveId = id ?? (isPoliticianTopic ? 'politician' : (isLocationTopic ? 'location' : id));
          if (id != null && name != null) {
            ref.read(selectedPoliticianIdProvider.notifier).state = null;
            // Clear location selections when switching topics (unless selecting location topic)
            if (effectiveType.toLowerCase() != 'location') {
              ref.read(selectedNewsStateIdProvider.notifier).state = null;
              ref.read(selectedNewsStateNameProvider.notifier).state = null;
              ref.read(selectedNewsDistrictIdProvider.notifier).state = null;
              ref.read(selectedNewsDistrictNameProvider.notifier).state = null;
              ref.read(selectedNewsLandmarkIdProvider.notifier).state = null;
              ref.read(selectedNewsLandmarkNameProvider.notifier).state = null;
            }
            AppLogger.logInfo(
              'Legacy topic selected id=$id name=$name type=$effectiveType',
              tag: 'legacyNewsView',
            );
            ref.read(topicId.notifier).state = '$effectiveType/$effectiveId';
            ref.read(topic.notifier).state = name!;
            ref.read(topicType.notifier).state = effectiveType;

            if (isPoliticianTopic || isLocationTopic) {
              ref
                  .read(legacyPostPaginationControllerProvider.notifier)
                  .clearPosts();
            } else {
              ref
                  .refresh(legacyPostPaginationControllerProvider.notifier)
                  .resetPosts();
              ref
                  .read(legacyPostPaginationControllerProvider.notifier)
                  .getPosts();
            }
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
            color: isSelected
                ? primary.withOpacity(0.12)
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? primary.withOpacity(0.6)
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TopicAvatar(
                iconUrl: iconUrl,
                fallbackIcon: _iconForType(type),
                isSelected: isSelected,
              ),
              const SizedBox(width: 8),
              Text(
                name ?? 'Unknown',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? primary
                      : (isDark ? Colors.grey.shade300 : Colors.grey.shade900),
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
      case 'editor':
        return Icons.edit_note_rounded;
      case 'latest':
        return Icons.new_releases_rounded;
      case 'topic':
        return Icons.topic_outlined;
      default:
        return Icons.label_outline;
    }
  }
}

class _TopicAvatar extends StatelessWidget {
  const _TopicAvatar({
    required this.iconUrl,
    required this.fallbackIcon,
    this.isSelected = false,
  });

  final String? iconUrl;
  final IconData fallbackIcon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final hasIcon = iconUrl != null && iconUrl!.isNotEmpty;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? (isSelected ? primary.withOpacity(0.2) : Colors.grey.shade700)
            : (isSelected ? primary.withOpacity(0.1) : Colors.grey.shade200),
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
              color: isSelected
                  ? primary
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
    );
  }
}
