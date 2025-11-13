import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_guru_all/src/core/log/logging.dart';
import 'package:local_guru_all/src/features/location/viewmodel/location_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../src.dart';

/// Sticky filter surface for the legacy news dashboard. Offers three segments:
/// topics, location, and politicians. Each segment renders a tailored control
/// surface that feeds Riverpod state used by the legacy pagination controller.
class LegacyFilterBar extends ConsumerWidget {
  const LegacyFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsState = ref.watch(topicsControllerProvider);

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
  required LocationProvider locationProvider,
  required List<PoliticianModel> politicians,
}) async {
  if (locationProvider.states.isEmpty && !locationProvider.isLoading) {
    await locationProvider.loadStates();
  }

  // Ensure location selections remain in sync while the sheet is open.
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final bottomPadding = MediaQuery.of(sheetContext).viewInsets.bottom;

      return Consumer(
        builder: (_, modalRef, __) {
          final selectedPoliticianId =
              modalRef.watch(selectedPoliticianIdProvider);

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
                  const SizedBox(height: 12),
                  Text(
                    'Location',
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: locationProvider,
                    builder: (_, __) => _LocationPanel(
                      locationProvider: locationProvider,
                      onStateSelected: (value) =>
                          _onStateSelected(ref, locationProvider, value),
                      onDistrictSelected: (value) =>
                          _onDistrictSelected(ref, locationProvider, value),
                      onLandmarkSelected: (value) =>
                          _onLandmarkSelected(ref, locationProvider, value),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Politicians',
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _PoliticianStrip(
                    politicians: politicians,
                    selectedId: selectedPoliticianId,
                    onSelected: (person) {
                      _handlePoliticianSelection(ref, person);
                      AppLogger.logInfo(
                        'Filter sheet politician selected id=${person.id}',
                        tag: 'legacyNewsView',
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _onStateSelected(
  WidgetRef ref,
  LocationProvider locationProvider,
  String? stateId,
) {
  ref.read(selectedPoliticianIdProvider.notifier).state = null;

  if (stateId == null || stateId.isEmpty) {
    locationProvider.selectState(null);
    AppLogger.logInfo('Legacy state filter cleared', tag: 'legacyNewsView');
    _refreshLegacyFeed(ref);
    return;
  }

  locationProvider.selectState(stateId);
  final stateName = locationProvider.states
      .firstWhere(
        (state) => state.id == stateId,
        orElse: () => locationProvider.states.first,
      )
      .state;

  ref.read(topicId.notifier).state = 'state/$stateId';
  ref.read(topicType.notifier).state = 'state';
  ref.read(topic.notifier).state = stateName;

  AppLogger.logInfo('Legacy state selected id=$stateId name=$stateName',
      tag: 'legacyNewsView');
  _refreshLegacyFeed(ref);
}

void _onDistrictSelected(
  WidgetRef ref,
  LocationProvider locationProvider,
  String? districtId,
) {
  final stateId = locationProvider.selectedStateId;
  if (stateId == null || stateId.isEmpty) {
    AppLogger.logWarning(
      'Legacy district selection skipped: no state selected',
      tag: 'legacyNewsView',
    );
    return;
  }

  ref.read(selectedPoliticianIdProvider.notifier).state = null;

  if (districtId == null || districtId.isEmpty) {
    locationProvider.selectDistrict(stateId, null);
    AppLogger.logInfo(
      'Legacy district cleared, reverting to state filter',
      tag: 'legacyNewsView',
    );
    _onStateSelected(ref, locationProvider, stateId);
    return;
  }

  locationProvider.selectDistrict(stateId, districtId);
  final districtName = locationProvider.districts
      .firstWhere(
        (district) => district.districtId == districtId,
        orElse: () => locationProvider.districts.first,
      )
      .district;

  ref.read(topicId.notifier).state = 'district/$districtId';
  ref.read(topicType.notifier).state = 'district';
  ref.read(topic.notifier).state = districtName;

  AppLogger.logInfo(
    'Legacy district selected id=$districtId name=$districtName',
    tag: 'legacyNewsView',
  );
  _refreshLegacyFeed(ref);
}

void _onLandmarkSelected(
  WidgetRef ref,
  LocationProvider locationProvider,
  String? landmarkId,
) {
  final stateId = locationProvider.selectedStateId;
  final districtId = locationProvider.selectedDistrictId;
  if (stateId == null ||
      stateId.isEmpty ||
      districtId == null ||
      districtId.isEmpty) {
    AppLogger.logWarning(
      'Legacy landmark selection skipped: state or district missing',
      tag: 'legacyNewsView',
    );
    return;
  }

  ref.read(selectedPoliticianIdProvider.notifier).state = null;

  if (landmarkId == null || landmarkId.isEmpty) {
    locationProvider.selectLandmark(null);
    AppLogger.logInfo(
      'Legacy landmark cleared, reverting to district filter',
      tag: 'legacyNewsView',
    );
    _onDistrictSelected(ref, locationProvider, districtId);
    return;
  }

  locationProvider.selectLandmark(landmarkId);
  final landmarkName = locationProvider.landmarks
      .firstWhere(
        (landmark) => landmark.landmarkId == landmarkId,
        orElse: () => locationProvider.landmarks.first,
      )
      .landmark;

  ref.read(topicId.notifier).state = 'landmark/$landmarkId';
  ref.read(topicType.notifier).state = 'landmark';
  ref.read(topic.notifier).state = landmarkName;

  AppLogger.logInfo(
    'Legacy landmark selected id=$landmarkId name=$landmarkName',
    tag: 'legacyNewsView',
  );
  _refreshLegacyFeed(ref);
}

void _handlePoliticianSelection(WidgetRef ref, PoliticianModel person) {
  if (person.id == null || person.id!.isEmpty) {
    AppLogger.logWarning(
      'Legacy politician selection skipped: missing id',
      tag: 'legacyNewsView',
    );
    return;
  }

  ref.read(selectedPoliticianIdProvider.notifier).state = person.id;

  ref.read(topicId.notifier).state = 'politician/${person.id}';
  ref.read(topicType.notifier).state = 'politician';
  ref.read(topic.notifier).state = person.name ?? '';

  AppLogger.logInfo('Legacy politician selected id=${person.id}',
      tag: 'legacyNewsView');
  _refreshLegacyFeed(ref);
}

void _refreshLegacyFeed(WidgetRef ref) {
  ref.refresh(legacyPostPaginationControllerProvider.notifier).resetPosts();
  ref.read(legacyPostPaginationControllerProvider.notifier).getPosts();
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

class _LocationPanel extends StatelessWidget {
  const _LocationPanel({
    required this.locationProvider,
    required this.onStateSelected,
    required this.onDistrictSelected,
    required this.onLandmarkSelected,
  });

  final LocationProvider locationProvider;
  final ValueChanged<String?> onStateSelected;
  final ValueChanged<String?> onDistrictSelected;
  final ValueChanged<String?> onLandmarkSelected;

  @override
  Widget build(BuildContext context) {
    if (locationProvider.isLoading && locationProvider.states.isEmpty) {
      return const SizedBox(
        height: 96,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (locationProvider.error != null && locationProvider.states.isEmpty) {
      return SizedBox(
        height: 96,
        child: ErrorBody(message: locationProvider.error),
      );
    }

    if (locationProvider.states.isEmpty) {
      return Text(
        'Start by picking a state to see hyperlocal news.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DropdownField(
          label: 'State',
          value: (locationProvider.selectedStateId?.isNotEmpty ?? false)
              ? locationProvider.selectedStateId
              : null,
          items: locationProvider.states
              .map(
                (state) => DropdownMenuItem(
                  value: state.id,
                  child: Text(state.state),
                ),
              )
              .toList(),
          onChanged: onStateSelected,
        ),
        const SizedBox(height: 10),
        _DropdownField(
          label: 'District',
          value: (locationProvider.selectedDistrictId?.isNotEmpty ?? false)
              ? locationProvider.selectedDistrictId
              : null,
          items: locationProvider.districts
              .map(
                (district) => DropdownMenuItem(
                  value: district.districtId,
                  child: Text(district.district),
                ),
              )
              .toList(),
          onChanged: (locationProvider.selectedStateId?.isEmpty ?? true)
              ? null
              : onDistrictSelected,
        ),
        const SizedBox(height: 10),
        _DropdownField(
          label: 'Landmark',
          value: (locationProvider.selectedLandmarkId?.isNotEmpty ?? false)
              ? locationProvider.selectedLandmarkId
              : null,
          items: locationProvider.landmarks
              .map(
                (landmark) => DropdownMenuItem(
                  value: landmark.landmarkId,
                  child: Text(landmark.landmark),
                ),
              )
              .toList(),
          onChanged: (locationProvider.selectedDistrictId?.isEmpty ?? true)
              ? null
              : onLandmarkSelected,
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _PoliticianStrip extends StatelessWidget {
  const _PoliticianStrip({
    required this.politicians,
    required this.selectedId,
    required this.onSelected,
  });

  final List<PoliticianModel> politicians;
  final String? selectedId;
  final ValueChanged<PoliticianModel> onSelected;

  @override
  Widget build(BuildContext context) {
    if (politicians.isEmpty) {
      return Text(
        'No politicians available right now.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
      );
    }

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: politicians.length,
        itemBuilder: (context, index) {
          final person = politicians[index];
          final isSelected = selectedId == person.id;

          return FilterChip(
            avatar: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (person.profile?.isNotEmpty ?? false)
                  ? NetworkImage(person.profile!)
                  : null,
              child: (person.profile?.isEmpty ?? true)
                  ? Text(
                      (person.name?.isNotEmpty ?? false)
                          ? person.name!.characters.first.toUpperCase()
                          : '?',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                  : null,
            ),
            label: Text(person.name ?? 'Unknown'),
            selected: isSelected,
            selectedColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.12),
            onSelected: (value) {
              if (!value) return;
              onSelected(person);
            },
          );
        },
      ),
    );
  }
}
