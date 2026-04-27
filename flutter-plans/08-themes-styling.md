# Themes & Styling System

## Overview

This document details the implementation of the theme system, mapping the 8 CSS themes from React to Flutter's ThemeData system.

## Current React Themes

```
src/themes/
├── arctic-night.css
├── ayu-light.css
├── ayu-mirage.css
├── duotone-dark.css
├── duotone-forest.css
├── duotone-light.css
├── duotone-sea.css
└── nordic-snow.css
```

## Flutter Theme Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Theme System Architecture                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │   Flutter    │      │  Theme       │      │  Material  │ │
│  │   Widgets    │◄────►│  Provider    │◄────►│  Design 3  │ │
│  │              │      │              │      │            │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                       │                      │     │
│         │                       │                      │     │
│         ▼                       ▼                      ▼     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Theme Definitions                         │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐   │ │
│  │  │  Arctic      │  │  Ayu Light   │  │  Duotone    │   │ │
│  │  │  Night       │  │              │  │  Dark       │   │ │
│  │  └──────────────┘  └──────────────┘  └────────────┘   │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐   │ │
│  │  │  Ayu Mirage  │  │  Duotone     │  │  Nordic     │   │ │
│  │  │              │  │  Forest       │  │  Snow       │   │ │
│  │  └──────────────┘  └──────────────┘  └────────────┘   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Theme Enum

### lib/core/theme/app_theme.dart

```dart
import 'package:flutter/material.dart';

enum AppTheme {
  arcticNight,
  ayuLight,
  ayuMirage,
  duotoneDark,
  duotoneForest,
  duotoneLight,
  duotoneSea,
  nordicSnow,
}

extension AppThemeExtension on AppTheme {
  String get displayName {
    switch (this) {
      case AppTheme.arcticNight:
        return 'Arctic Night';
      case AppTheme.ayuLight:
        return 'Ayu Light';
      case AppTheme.ayuMirage:
        return 'Ayu Mirage';
      case AppTheme.duotoneDark:
        return 'Duotone Dark';
      case AppTheme.duotoneForest:
        return 'Duotone Forest';
      case AppTheme.duotoneLight:
        return 'Duotone Light';
      case AppTheme.duotoneSea:
        return 'Duotone Sea';
      case AppTheme.nordicSnow:
        return 'Nordic Snow';
    }
  }

  bool get isDark {
    switch (this) {
      case AppTheme.arcticNight:
      case AppTheme.ayuMirage:
      case AppTheme.duotoneDark:
      case AppTheme.duotoneForest:
      case AppTheme.duotoneSea:
        return true;
      case AppTheme.ayuLight:
      case AppTheme.duotoneLight:
      case AppTheme.nordicSnow:
        return false;
    }
  }
}
```

## Theme Definitions

### lib/core/theme/theme_data.dart

```dart
import 'package:flutter/material.dart';

class AppThemeData {
  static ThemeData getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.arcticNight:
        return _arcticNightTheme;
      case AppTheme.ayuLight:
        return _ayuLightTheme;
      case AppTheme.ayuMirage:
        return _ayuMirageTheme;
      case AppTheme.duotoneDark:
        return _duotoneDarkTheme;
      case AppTheme.duotoneForest:
        return _duotoneForestTheme;
      case AppTheme.duotoneLight:
        return _duotoneLightTheme;
      case AppTheme.duotoneSea:
        return _duotoneSeaTheme;
      case AppTheme.nordicSnow:
        return _nordicSnowTheme;
    }
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │ ARCTIC NIGHT THEME                                            │
  // └─────────────────────────────────────────────────────────────┘
  static ThemeData get _arcticNightTheme {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFF5CCFE6),
      secondary: const Color(0xFF8B9DC5),
      surface: const Color(0xFF1A1F2E),
      background: const Color(0xFF0F141F),
      error: const Color(0xFFE57373),
      onPrimary: const Color(0xFF0F141F),
      onSecondary: const Color(0xFF0F141F),
      onSurface: const Color(0xFFE8E8E8),
      onBackground: const Color(0xFFE8E8E8),
      onError: const Color(0xFF0F141F),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
      ),
    );
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │ AYU LIGHT THEME                                               │
  // └─────────────────────────────────────────────────────────────┘
  static ThemeData get _ayuLightTheme {
    final colorScheme = ColorScheme.light(
      primary: const Color(0xFF0784DD),
      secondary: const Color(0xFFFA8D3E),
      surface: const Color(0xFFFAFAFA),
      background: const Color(0xFFFFFFFF),
      error: const Color(0xFFE57373),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF1A1F2E),
      onBackground: const Color(0xFF1A1F2E),
      onError: const Color(0xFFFFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
      ),
    );
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │ AYU MIRAGE THEME                                              │
  // └─────────────────────────────────────────────────────────────┘
  static ThemeData get _ayuMirageTheme {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFF73D2FF),
      secondary: const Color(0xFFFFA759),
      surface: const Color(0xFF1F2430),
      background: const Color(0xFF1A1E27),
      error: const Color(0xFFFF8F8F),
      onPrimary: const Color(0xFF1A1E27),
      onSecondary: const Color(0xFF1A1E27),
      onSurface: const Color(0xFFC7C7C7),
      onBackground: const Color(0xFFC7C7C7),
      onError: const Color(0xFF1A1E27),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
      ),
    );
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │ DUOTONE DARK THEME                                           │
  // └─────────────────────────────────────────────────────────────┘
  static ThemeData get _duotoneDarkTheme {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFF5CCFE6),
      secondary: const Color(0xFFC792EA),
      surface: const Color(0xFF1E1E2E),
      background: const Color(0xFF181825),
      error: const Color(0xFFE57373),
      onPrimary: const Color(0xFF181825),
      onSecondary: const Color(0xFF181825),
      onSurface: const Color(0xFFE0E0E0),
      onBackground: const Color(0xFFE0E0E0),
      onError: const Color(0xFF181825),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
      ),
    );
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │ DUOTONE FOREST THEME                                         │
  // └─────────────────────────────────────────────────────────────┘
  static ThemeData get _duotoneForestTheme {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFF7FD962),
      secondary: const Color(0xFF5CCFE6),
      surface: const Color(0xFF1E2B1E),
      background: const Color(0xFF162016),
      error: const Color(0xFFE57373),
      onPrimary: const Color(0xFF162016),
      onSecondary: const Color(0xFF162016),
      onSurface: const Color(0xFFE0E0E0),
      onBackground: const Color(0xFFE0E0E0),
      onError: const Color(0xFF162016),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
      ),
    );
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │ DUOTONE LIGHT THEME                                          │
  // └─────────────────────────────────────────────────────────────┘
  static ThemeData get _duotoneLightTheme {
    final colorScheme = ColorScheme.light(
      primary: const Color(0xFF2D7D9A),
      secondary: const Color(0xFFE57373),
      surface: const Color(0xFFFAFAFA),
      background: const Color(0xFFFFFFFF),
      error: const Color(0xFFE57373),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF1A1F2E),
      onBackground: const Color(0xFF1A1F2E),
      onError: const Color(0xFFFFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
      ),
    );
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │ DUOTONE SEA THEME                                            │
  // └─────────────────────────────────────────────────────────────┘
  static ThemeData get _duotoneSeaTheme {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFF5CCFE6),
      secondary: const Color(0xFF7FD962),
      surface: const Color(0xFF1E2B3E),
      background: const Color(0xFF16202E),
      error: const Color(0xFFE57373),
      onPrimary: const Color(0xFF16202E),
      onSecondary: const Color(0xFF16202E),
      onSurface: const Color(0xFFE0E0E0),
      onBackground: const Color(0xFFE0E0E0),
      onError: const Color(0xFF16202E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
      ),
    );
  }

  // ┌─────────────────────────────────────────────────────────────┐
  // │ NORDIC SNOW THEME                                           │
  // └─────────────────────────────────────────────────────────────┘
  static ThemeData get _nordicSnowTheme {
    final colorScheme = ColorScheme.light(
      primary: const Color(0xFF81A1C1),
      secondary: const Color(0xFF88C0D0),
      surface: const Color(0xFFECEFF4),
      background: const Color(0xFFE5E9F0),
      error: const Color(0xFFBF616A),
      onPrimary: const Color(0xFF2E3440),
      onSecondary: const Color(0xFF2E3440),
      onSurface: const Color(0xFF2E3440),
      onBackground: const Color(0xFF2E3440),
      onError: const Color(0xFF2E3440),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
      ),
    );
  }
}
```

## Theme Provider

### lib/core/theme/theme_provider.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'theme_data.dart';

// Selected Theme Provider
@riverpod
class SelectedTheme extends _$SelectedTheme {
  @override
  AppTheme build() => AppTheme.duotoneDark;

  void setTheme(AppTheme theme) {
    state = theme;
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', state.name);
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('selected_theme');
    if (themeName != null) {
      try {
        final theme = AppTheme.values.firstWhere(
          (t) => t.name == themeName,
          orElse: () => AppTheme.duotoneDark,
        );
        state = theme;
      } catch (e) {
        // Use default if loading fails
      }
    }
  }
}

// Theme Mode Provider (Light/Dark/System)
@riverpod
class ThemeModePreference extends _$ThemeModePreference {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', state.name);
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString('theme_mode');
    if (modeName != null) {
      try {
        final mode = ThemeMode.values.firstWhere(
          (m) => m.name == modeName,
          orElse: () => ThemeMode.system,
        );
        state = mode;
      } catch (e) {
        // Use default if loading fails
      }
    }
  }
}

// Current ThemeData Provider
final currentThemeProvider = Provider<ThemeData>((ref) {
  final selectedTheme = ref.watch(selectedThemeProvider);
  return AppThemeData.getThemeData(selectedTheme);
});
```

## Theme Switcher Widget

### lib/shared/widgets/theme_switcher.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(selectedThemeProvider);

    return PopupMenuButton<AppTheme>(
      icon: const Icon(Icons.palette),
      tooltip: 'Change theme',
      onSelected: (theme) {
        ref.read(selectedThemeProvider.notifier).setTheme(theme);
      },
      itemBuilder: (context) => AppTheme.values.map((theme) {
        return PopupMenuItem(
          value: theme,
          child: Row(
            children: [
              _buildThemePreview(theme),
              const SizedBox(width: 12),
              Text(theme.displayName),
              const Spacer(),
              if (theme == selectedTheme)
                const Icon(Icons.check, size: 18),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThemePreview(AppTheme theme) {
    final themeData = AppThemeData.getThemeData(theme);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: themeData.colorScheme.primary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: themeData.colorScheme.onSurface.withOpacity(0.2),
        ),
      ),
    );
  }
}
```

## Theme Preview Grid

### lib/shared/widgets/theme_selector.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(selectedThemeProvider);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: AppTheme.values.length,
      itemBuilder: (context, index) {
        final theme = AppTheme.values[index];
        final isSelected = theme == selectedTheme;

        return InkWell(
          onTap: () {
            ref.read(selectedThemeProvider.notifier).setTheme(theme);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppThemeData.getThemeData(theme).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildThemeColors(theme),
                const SizedBox(height: 8),
                Text(
                  theme.displayName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (theme.isDark)
                  Icon(
                    Icons.dark_mode,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeColors(AppTheme theme) {
    final themeData = AppThemeData.getThemeData(theme);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildColorDot(themeData.colorScheme.primary),
        const SizedBox(width: 4),
        _buildColorDot(themeData.colorScheme.secondary),
        const SizedBox(width: 4),
        _buildColorDot(themeData.colorScheme.surface),
      ],
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
```

## Custom Theme Extensions

### lib/core/theme/theme_extensions.dart

```dart
import 'package:flutter/material.dart';

@immutable
class modelmanThemeExtension extends ThemeExtension<modelmanThemeExtension> {
  final Color serverConnected;
  final Color serverDisconnected;
  final Color toolExecuting;
  final Color success;
  final Color warning;

  const modelmanThemeExtension({
    required this.serverConnected,
    required this.serverDisconnected,
    required this.toolExecuting,
    required this.success,
    required this.warning,
  });

  static const light = modelmanThemeExtension(
    serverConnected: Color(0xFF4CAF50),
    serverDisconnected: Color(0xFF9E9E9E),
    toolExecuting: Color(0xFF2196F3),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
  );

  static const dark = modelmanThemeExtension(
    serverConnected: Color(0xFF81C784),
    serverDisconnected: Color(0xFF616161),
    toolExecuting: Color(0xFF64B5F6),
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
  );

  @override
  modelmanThemeExtension copyWith({
    Color? serverConnected,
    Color? serverDisconnected,
    Color? toolExecuting,
    Color? success,
    Color? warning,
  }) {
    return modelmanThemeExtension(
      serverConnected: serverConnected ?? this.serverConnected,
      serverDisconnected: serverDisconnected ?? this.serverDisconnected,
      toolExecuting: toolExecuting ?? this.toolExecuting,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  modelmanThemeExtension lerp(ThemeExtension<modelmanThemeExtension>? other, double t) {
    if (other is! modelmanThemeExtension) {
      return this;
    }

    return modelmanThemeExtension(
      serverConnected: Color.lerp(serverConnected, other.serverConnected, t)!,
      serverDisconnected: Color.lerp(serverDisconnected, other.serverDisconnected, t)!,
      toolExecuting: Color.lerp(toolExecuting, other.toolExecuting, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
```

## Integration with Main App

### lib/main.dart (Updated)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_data.dart';
import 'core/theme/theme_extensions.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: modelmanApp(),
    ),
  );
}

class modelmanApp extends ConsumerWidget {
  const modelmanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(selectedThemeProvider);
    final themeMode = ref.watch(themeModePreferenceProvider);
    final themeData = AppThemeData.getThemeData(selectedTheme);

    return MaterialApp.router(
      title: 'modelman',
      debugShowCheckedModeBanner: false,
      theme: themeData.copyWith(
        extensions: [
          modelmanThemeExtension.light,
        ],
      ),
      darkTheme: themeData.copyWith(
        extensions: [
          modelmanThemeExtension.dark,
        ],
      ),
      themeMode: themeMode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
```

## Usage Example

### lib/features/servers/presentation/widgets/server_tile.dart (Updated)

```dart
class ServerTile extends StatelessWidget {
  final ServerConfig server;
  final bool isSelected;
  final VoidCallback onTap;

  const ServerTile({
    super.key,
    required this.server,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeExtension = Theme.of(context).extension<modelmanThemeExtension>();

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: server.connected
              ? themeExtension?.serverConnected
              : themeExtension?.serverDisconnected,
        ),
        // ... rest of widget
      ),
    );
  }
}
```

## Testing

### test/core/theme/theme_data_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:modelman_flutter/core/theme/app_theme.dart';
import 'package:modelman_flutter/core/theme/theme_data.dart';

void main() {
  group('ThemeData', () {
    test('all themes return valid ThemeData', () {
      for (final theme in AppTheme.values) {
        final themeData = AppThemeData.getThemeData(theme);
        expect(themeData, isA<ThemeData>());
        expect(themeData.colorScheme, isNotNull);
      }
    });

    test('dark themes have dark color scheme', () {
      final darkThemes = [
        AppTheme.arcticNight,
        AppTheme.ayuMirage,
        AppTheme.duotoneDark,
        AppTheme.duotoneForest,
        AppTheme.duotoneSea,
      ];

      for (final theme in darkThemes) {
        final themeData = AppThemeData.getThemeData(theme);
        expect(themeData.brightness, Brightness.dark);
      }
    });

    test('light themes have light color scheme', () {
      final lightThemes = [
        AppTheme.ayuLight,
        AppTheme.duotoneLight,
        AppTheme.nordicSnow,
      ];

      for (final theme in lightThemes) {
        final themeData = AppThemeData.getThemeData(theme);
        expect(themeData.brightness, Brightness.light);
      }
    });
  });
}
```

## Migration Checklist

- [ ] Create AppTheme enum
- [ ] Implement all 8 theme definitions
- [ ] Create theme provider
- [ ] Create ThemeSwitcher widget
- [ ] Create ThemeSelector widget
- [ ] Add custom theme extensions
- [ ] Integrate with main app
- [ ] Add theme persistence
- [ ] Test all themes on different platforms
- [ ] Ensure accessibility with each theme
- [ ] Add theme transition animations

## Next Steps

1. Review `09-data-persistence.md` for data persistence implementation
2. Add theme-specific animations
3. Implement theme preview in settings
4. Add support for custom themes
