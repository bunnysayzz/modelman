import 'package:flutter/material.dart';

/// Enum of all available themes, ported from the React CSS themes.
enum AppThemeType {
  arcticNight,
  ayuLight,
  ayuMirage,
  duotoneDark,
  duotoneForest,
  duotoneLight,
  duotoneSea,
  nordicSnow,
}

extension AppThemeTypeExtension on AppThemeType {
  /// Human-readable display name for the theme selector UI.
  String get displayName {
    switch (this) {
      case AppThemeType.arcticNight:
        return 'Arctic Night';
      case AppThemeType.ayuLight:
        return 'Ayu Light';
      case AppThemeType.ayuMirage:
        return 'Ayu Mirage';
      case AppThemeType.duotoneDark:
        return 'Duotone Dark';
      case AppThemeType.duotoneForest:
        return 'Duotone Forest';
      case AppThemeType.duotoneLight:
        return 'Duotone Light';
      case AppThemeType.duotoneSea:
        return 'Duotone Sea';
      case AppThemeType.nordicSnow:
        return 'Nordic Snow';
    }
  }

  /// Whether this theme uses a dark color scheme.
  bool get isDark {
    switch (this) {
      case AppThemeType.arcticNight:
      case AppThemeType.ayuMirage:
      case AppThemeType.duotoneDark:
      case AppThemeType.duotoneForest:
      case AppThemeType.duotoneSea:
        return true;
      case AppThemeType.ayuLight:
      case AppThemeType.duotoneLight:
      case AppThemeType.nordicSnow:
        return false;
    }
  }

  /// Primary accent color for theme preview widgets.
  Color get previewColor {
    switch (this) {
      case AppThemeType.arcticNight:
        return const Color(0xFF5CCFE6);
      case AppThemeType.ayuLight:
        return const Color(0xFF0784DD);
      case AppThemeType.ayuMirage:
        return const Color(0xFF73D2FF);
      case AppThemeType.duotoneDark:
        return const Color(0xFF5CCFE6);
      case AppThemeType.duotoneForest:
        return const Color(0xFF7FD962);
      case AppThemeType.duotoneLight:
        return const Color(0xFF2D7D9A);
      case AppThemeType.duotoneSea:
        return const Color(0xFF5CCFE6);
      case AppThemeType.nordicSnow:
        return const Color(0xFF81A1C1);
    }
  }
}
