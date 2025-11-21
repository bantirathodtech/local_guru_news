import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Theme mode provider for managing light/dark theme
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  final Box<String> _box = Hive.box('user');

  ThemeModeNotifier() : super(_loadThemeMode()) {
    // Save theme mode whenever it changes
    addListener((themeMode) {
      _saveThemeMode(themeMode);
    });
  }

  static ThemeMode _loadThemeMode() {
    try {
      final box = Hive.box<String>('user');
      final savedMode = box.get(_themeKey, defaultValue: 'system');
      switch (savedMode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      return ThemeMode.system;
    }
  }

  void _saveThemeMode(ThemeMode mode) {
    try {
      String modeString;
      switch (mode) {
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.system:
        default:
          modeString = 'system';
      }
      _box.put(_themeKey, modeString);
    } catch (e) {
      // Silently handle errors
    }
  }

  void setLight() => state = ThemeMode.light;
  void setDark() => state = ThemeMode.dark;
  void setSystem() => state = ThemeMode.system;
  void toggle() {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
  }
}

