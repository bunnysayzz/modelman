import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'theme_extensions.dart';

/// Provides full [ThemeData] for each [AppThemeType].
///
/// Each theme maps the original React CSS color tokens to Material 3
/// color schemes, card styles, app bar styles, and input decorations.
class AppThemeData {
  AppThemeData._();

  static ThemeData getThemeData(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.arcticNight:
        return _arcticNightTheme;
      case AppThemeType.ayuLight:
        return _ayuLightTheme;
      case AppThemeType.ayuMirage:
        return _ayuMirageTheme;
      case AppThemeType.duotoneDark:
        return _duotoneDarkTheme;
      case AppThemeType.duotoneForest:
        return _duotoneForestTheme;
      case AppThemeType.duotoneLight:
        return _duotoneLightTheme;
      case AppThemeType.duotoneSea:
        return _duotoneSeaTheme;
      case AppThemeType.nordicSnow:
        return _nordicSnowTheme;
    }
  }

  // ── Arctic Night ───────────────────────────────────────────
  static ThemeData get _arcticNightTheme => _buildTheme(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF5CCFE6),
          secondary: const Color(0xFF8B9DC5),
          surface: const Color(0xFF1A1F2E),
          error: const Color(0xFFE57373),
          onPrimary: const Color(0xFF0F141F),
          onSecondary: const Color(0xFF0F141F),
          onSurface: const Color(0xFFE8E8E8),
          onError: const Color(0xFF0F141F),
        ),
        scaffoldBg: const Color(0xFF0F141F),
        isDark: true,
      );

  // ── Ayu Light ──────────────────────────────────────────────
  static ThemeData get _ayuLightTheme => _buildTheme(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF0784DD),
          secondary: const Color(0xFFFA8D3E),
          surface: const Color(0xFFFAFAFA),
          error: const Color(0xFFE57373),
          onPrimary: const Color(0xFFFFFFFF),
          onSecondary: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF1A1F2E),
          onError: const Color(0xFFFFFFFF),
        ),
        scaffoldBg: const Color(0xFFFFFFFF),
        isDark: false,
      );

  // ── Ayu Mirage ─────────────────────────────────────────────
  static ThemeData get _ayuMirageTheme => _buildTheme(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF73D2FF),
          secondary: const Color(0xFFFFA759),
          surface: const Color(0xFF1F2430),
          error: const Color(0xFFFF8F8F),
          onPrimary: const Color(0xFF1A1E27),
          onSecondary: const Color(0xFF1A1E27),
          onSurface: const Color(0xFFC7C7C7),
          onError: const Color(0xFF1A1E27),
        ),
        scaffoldBg: const Color(0xFF1A1E27),
        isDark: true,
      );

  // ── Duotone Dark ───────────────────────────────────────────
  static ThemeData get _duotoneDarkTheme => _buildTheme(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF5CCFE6),
          secondary: const Color(0xFFC792EA),
          surface: const Color(0xFF1E1E2E),
          error: const Color(0xFFE57373),
          onPrimary: const Color(0xFF181825),
          onSecondary: const Color(0xFF181825),
          onSurface: const Color(0xFFE0E0E0),
          onError: const Color(0xFF181825),
        ),
        scaffoldBg: const Color(0xFF181825),
        isDark: true,
      );

  // ── Duotone Forest ─────────────────────────────────────────
  static ThemeData get _duotoneForestTheme => _buildTheme(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF7FD962),
          secondary: const Color(0xFF5CCFE6),
          surface: const Color(0xFF1E2B1E),
          error: const Color(0xFFE57373),
          onPrimary: const Color(0xFF162016),
          onSecondary: const Color(0xFF162016),
          onSurface: const Color(0xFFE0E0E0),
          onError: const Color(0xFF162016),
        ),
        scaffoldBg: const Color(0xFF162016),
        isDark: true,
      );

  // ── Duotone Light ──────────────────────────────────────────
  static ThemeData get _duotoneLightTheme => _buildTheme(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF2D7D9A),
          secondary: const Color(0xFFE57373),
          surface: const Color(0xFFFAFAFA),
          error: const Color(0xFFE57373),
          onPrimary: const Color(0xFFFFFFFF),
          onSecondary: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF1A1F2E),
          onError: const Color(0xFFFFFFFF),
        ),
        scaffoldBg: const Color(0xFFFFFFFF),
        isDark: false,
      );

  // ── Duotone Sea ────────────────────────────────────────────
  static ThemeData get _duotoneSeaTheme => _buildTheme(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF5CCFE6),
          secondary: const Color(0xFF7FD962),
          surface: const Color(0xFF1E2B3E),
          error: const Color(0xFFE57373),
          onPrimary: const Color(0xFF16202E),
          onSecondary: const Color(0xFF16202E),
          onSurface: const Color(0xFFE0E0E0),
          onError: const Color(0xFF16202E),
        ),
        scaffoldBg: const Color(0xFF16202E),
        isDark: true,
      );

  // ── Nordic Snow ────────────────────────────────────────────
  static ThemeData get _nordicSnowTheme => _buildTheme(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF81A1C1),
          secondary: const Color(0xFF88C0D0),
          surface: const Color(0xFFECEFF4),
          error: const Color(0xFFBF616A),
          onPrimary: const Color(0xFF2E3440),
          onSecondary: const Color(0xFF2E3440),
          onSurface: const Color(0xFF2E3440),
          onError: const Color(0xFF2E3440),
        ),
        scaffoldBg: const Color(0xFFE5E9F0),
        isDark: false,
      );

  // ── Builder ────────────────────────────────────────────────

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required bool isDark,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      brightness: isDark ? Brightness.dark : Brightness.light,
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: isDark ? 2 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.2),
        thickness: 1,
      ),
      extensions: [
        isDark ? ModelmanThemeExtension.dark : ModelmanThemeExtension.light,
      ],
    );
  }
}
