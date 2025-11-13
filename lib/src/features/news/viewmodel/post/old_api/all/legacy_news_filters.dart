import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Filter categories supported by the legacy news pagination flow.
enum LegacyNewsFilterCategory {
  topics,
  location,
  politicians,
}

/// Tracks the active filter category on the news dashboard.
final legacyNewsFilterCategoryProvider =
    StateProvider<LegacyNewsFilterCategory>(
  (_) => LegacyNewsFilterCategory.topics,
);

/// Stores the currently selected politician id (if any).
final selectedPoliticianIdProvider = StateProvider<String?>(
  (_) => null,
);
