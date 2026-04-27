import 'package:flutter/material.dart';

/// Custom theme extension for Hoot-specific semantic colors
/// (server status, tool execution, success/warning indicators).
@immutable
class HootThemeExtension extends ThemeExtension<HootThemeExtension> {
  final Color serverConnected;
  final Color serverDisconnected;
  final Color toolExecuting;
  final Color success;
  final Color warning;
  final Color codeBackground;
  final Color codeForeground;

  const HootThemeExtension({
    required this.serverConnected,
    required this.serverDisconnected,
    required this.toolExecuting,
    required this.success,
    required this.warning,
    required this.codeBackground,
    required this.codeForeground,
  });

  static const light = HootThemeExtension(
    serverConnected: Color(0xFF4CAF50),
    serverDisconnected: Color(0xFF9E9E9E),
    toolExecuting: Color(0xFF2196F3),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    codeBackground: Color(0xFFF5F5F5),
    codeForeground: Color(0xFF1A1A1A),
  );

  static const dark = HootThemeExtension(
    serverConnected: Color(0xFF81C784),
    serverDisconnected: Color(0xFF616161),
    toolExecuting: Color(0xFF64B5F6),
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    codeBackground: Color(0xFF1E1E1E),
    codeForeground: Color(0xFFD4D4D4),
  );

  @override
  HootThemeExtension copyWith({
    Color? serverConnected,
    Color? serverDisconnected,
    Color? toolExecuting,
    Color? success,
    Color? warning,
    Color? codeBackground,
    Color? codeForeground,
  }) {
    return HootThemeExtension(
      serverConnected: serverConnected ?? this.serverConnected,
      serverDisconnected: serverDisconnected ?? this.serverDisconnected,
      toolExecuting: toolExecuting ?? this.toolExecuting,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      codeBackground: codeBackground ?? this.codeBackground,
      codeForeground: codeForeground ?? this.codeForeground,
    );
  }

  @override
  HootThemeExtension lerp(
    covariant ThemeExtension<HootThemeExtension>? other,
    double t,
  ) {
    if (other is! HootThemeExtension) return this;

    return HootThemeExtension(
      serverConnected: Color.lerp(serverConnected, other.serverConnected, t)!,
      serverDisconnected:
          Color.lerp(serverDisconnected, other.serverDisconnected, t)!,
      toolExecuting: Color.lerp(toolExecuting, other.toolExecuting, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      codeBackground: Color.lerp(codeBackground, other.codeBackground, t)!,
      codeForeground: Color.lerp(codeForeground, other.codeForeground, t)!,
    );
  }
}

/// Extension on [ThemeData] for convenient access to [HootThemeExtension].
extension HootThemeDataExtension on ThemeData {
  HootThemeExtension get hoot =>
      extension<HootThemeExtension>() ?? HootThemeExtension.dark;
}
