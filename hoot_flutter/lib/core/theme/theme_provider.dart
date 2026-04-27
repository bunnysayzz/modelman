import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'theme_data.dart';

/// Notifier that manages the currently selected [AppThemeType].
///
/// Persists the choice via [LocalStorageService] and exposes it as
/// a [StateNotifier] for the widget tree.
class SelectedThemeNotifier extends StateNotifier<AppThemeType> {
  SelectedThemeNotifier() : super(AppThemeType.duotoneDark);

  void setTheme(AppThemeType theme) {
    state = theme;
  }

  /// Tries to restore a theme from its [name].
  void setThemeByName(String name) {
    try {
      final theme = AppThemeType.values.firstWhere(
        (t) => t.name == name,
        orElse: () => AppThemeType.duotoneDark,
      );
      state = theme;
    } catch (_) {
      // Keep current theme on error
    }
  }
}

/// The currently selected theme type.
final selectedThemeProvider =
    StateNotifierProvider<SelectedThemeNotifier, AppThemeType>(
  (ref) => SelectedThemeNotifier(),
);

/// The resolved [ThemeData] for the selected theme.
///
/// Widgets should use `ref.watch(currentThemeDataProvider)` to get
/// the active ThemeData and react to changes.
final currentThemeDataProvider = Provider<ThemeData>((ref) {
  final selectedTheme = ref.watch(selectedThemeProvider);
  return AppThemeData.getThemeData(selectedTheme);
});

/// Whether the current theme is dark.
final isDarkThemeProvider = Provider<bool>((ref) {
  final selectedTheme = ref.watch(selectedThemeProvider);
  return selectedTheme.isDark;
});

/// The Flutter [ThemeMode] derived from the selected theme.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final isDark = ref.watch(isDarkThemeProvider);
  return isDark ? ThemeMode.dark : ThemeMode.light;
});
