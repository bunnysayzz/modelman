import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

/// Comprehensive application settings model.
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    // General
    @Default('') String userId,
    @Default(true) bool autoReconnectServers,
    @Default(30) int connectionTimeout,
    @Default(60) int requestTimeout,

    // Appearance
    @Default('duotoneDark') String themeName,
    @Default(14.0) double fontSize,
    @Default(true) bool enableAnimations,
    @Default(false) bool compactMode,

    // Network
    @Default(10) int maxConcurrentRequests,

    // Data
    @Default(true) bool enableHistory,
    @Default(100) int maxHistoryEntries,
    @Default(true) bool enableCache,
    @Default(50) int maxCacheSize,

    // Editor
    @Default(true) bool enableSyntaxHighlighting,
    @Default(true) bool enableAutoComplete,
    @Default(4) int tabSize,
    @Default(true) bool showLineNumbers,
    @Default(true) bool wordWrap,

    // Tool Filter
    @Default(true) bool enableToolFilter,
    @Default('') String aiProvider,
    @Default('') String aiModel,

    // Advanced
    @Default(false) bool debugMode,
    @Default(false) bool verboseLogging,
    @Default('') String customBackendUrl,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
