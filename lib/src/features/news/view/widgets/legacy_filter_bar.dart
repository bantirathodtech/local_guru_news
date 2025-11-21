import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../src.dart';

/// Sticky filter surface for the legacy news dashboard. Offers topics selection.
/// Location selection is handled via drawer menu (not in filter bar).
/// Politicians filter is available in the filter modal.
class LegacyFilterBar extends ConsumerWidget {
  const LegacyFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsState = ref.watch(topicsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TopicsStrip(topicsState: topicsState),
      ],
    );
  }
}

Future<void> showLegacyFilters({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  // Location selection is handled via drawer menu, not in filters
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final bottomPadding = MediaQuery.of(sheetContext).viewInsets.bottom;

      return Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 16 + bottomPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close filters',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _FilterSection(
                title: 'Location',
                items: ['State', 'District', 'Landmark'],
                subtitle: 'Use the side drawer to change your preferred location.',
              ),
              const SizedBox(height: 24),
              const _FilterSection(
                title: 'Roles',
                items: ['Politician'],
                subtitle:
                    'Select the “Politician” topic in the tabs to browse and choose politicians.',
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _TopicsStrip extends StatelessWidget {
  const _TopicsStrip({required this.topicsState});

  final TopicsModelProvider topicsState;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Builder(
        builder: (context) {
          try {
            if (topicsState.refreshError) {
              developer
                  .log('Topics refresh error: ${topicsState.errorMessage}');
              return Center(
                child: ErrorBody(message: topicsState.errorMessage),
              );
            }

            if (topicsState.topics == null || topicsState.topics!.isEmpty) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemCount: topicsState.topics!.length,
              itemBuilder: (context, index) {
                final topic = topicsState.topics![index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: TopicListComponent(
                    id: topic.id,
                    name: topic.name,
                    type: topic.type,
                    iconUrl: topic.icon,
                  ),
                );
              },
            );
          } catch (e) {
            developer.log('Error in topics builder: $e');
            return const Center(
              child: ErrorBody(message: 'Error loading topics'),
            );
          }
        },
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.items,
    required this.subtitle,
  });

  final String title;
  final List<String> items;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (label) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
