import 'package:flutter/material.dart';

/// Custom theme extension for Modelman-specific semantic colors
/// (server status, tool execution, success/warning indicators).
@immutable
class ModelmanThemeExtension extends ThemeExtension<ModelmanThemeExtension> {
  final Color serverConnected;
  final Color serverDisconnected;
  final Color toolExecuting;
  final Color success;
  final Color warning;
  final Color codeBackground;
  final Color codeForeground;

  const ModelmanThemeExtension({
    required this.serverConnected,
    required this.serverDisconnected,
    required this.toolExecuting,
    required this.success,
    required this.warning,
    required this.codeBackground,
    required this.codeForeground,
  });

  static const light = ModelmanThemeExtension(
    serverConnected: Color(0xFF4CAF50),
    serverDisconnected: Color(0xFF9E9E9E),
    toolExecuting: Color(0xFF2196F3),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    codeBackground: Color(0xFFF5F5F5),
    codeForeground: Color(0xFF1A1A1A),
  );

  static const dark = ModelmanThemeExtension(
    serverConnected: Color(0xFF81C784),
    serverDisconnected: Color(0xFF616161),
    toolExecuting: Color(0xFF64B5F6),
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    codeBackground: Color(0xFF1E1E1E),
    codeForeground: Color(0xFFD4D4D4),
  );

  @override
  ModelmanThemeExtension copyWith({
    Color? serverConnected,
    Color? serverDisconnected,
    Color? toolExecuting,
    Color? success,
    Color? warning,
    Color? codeBackground,
    Color? codeForeground,
  }) {
    return ModelmanThemeExtension(
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
  ModelmanThemeExtension lerp(
    covariant ThemeExtension<ModelmanThemeExtension>? other,
    double t,
  ) {
    if (other is! ModelmanThemeExtension) return this;

    return ModelmanThemeExtension(
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

/// Extension on [ThemeData] for convenient access to [ModelmanThemeExtension].
extension ModelmanThemeDataExtension on ThemeData {
  ModelmanThemeExtension get modelman =>
      extension<ModelmanThemeExtension>() ?? ModelmanThemeExtension.dark;
}
