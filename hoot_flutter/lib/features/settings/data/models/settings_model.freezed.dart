// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
// General
  String get userId => throw _privateConstructorUsedError;
  bool get autoReconnectServers => throw _privateConstructorUsedError;
  int get connectionTimeout => throw _privateConstructorUsedError;
  int get requestTimeout => throw _privateConstructorUsedError; // Appearance
  String get themeName => throw _privateConstructorUsedError;
  double get fontSize => throw _privateConstructorUsedError;
  bool get enableAnimations => throw _privateConstructorUsedError;
  bool get compactMode => throw _privateConstructorUsedError; // Network
  int get maxConcurrentRequests => throw _privateConstructorUsedError; // Data
  bool get enableHistory => throw _privateConstructorUsedError;
  int get maxHistoryEntries => throw _privateConstructorUsedError;
  bool get enableCache => throw _privateConstructorUsedError;
  int get maxCacheSize => throw _privateConstructorUsedError; // Editor
  bool get enableSyntaxHighlighting => throw _privateConstructorUsedError;
  bool get enableAutoComplete => throw _privateConstructorUsedError;
  int get tabSize => throw _privateConstructorUsedError;
  bool get showLineNumbers => throw _privateConstructorUsedError;
  bool get wordWrap => throw _privateConstructorUsedError; // Tool Filter
  bool get enableToolFilter => throw _privateConstructorUsedError;
  String get aiProvider => throw _privateConstructorUsedError;
  String get aiModel => throw _privateConstructorUsedError; // Advanced
  bool get debugMode => throw _privateConstructorUsedError;
  bool get verboseLogging => throw _privateConstructorUsedError;
  String get customBackendUrl => throw _privateConstructorUsedError;

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
          AppSettings value, $Res Function(AppSettings) then) =
      _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call(
      {String userId,
      bool autoReconnectServers,
      int connectionTimeout,
      int requestTimeout,
      String themeName,
      double fontSize,
      bool enableAnimations,
      bool compactMode,
      int maxConcurrentRequests,
      bool enableHistory,
      int maxHistoryEntries,
      bool enableCache,
      int maxCacheSize,
      bool enableSyntaxHighlighting,
      bool enableAutoComplete,
      int tabSize,
      bool showLineNumbers,
      bool wordWrap,
      bool enableToolFilter,
      String aiProvider,
      String aiModel,
      bool debugMode,
      bool verboseLogging,
      String customBackendUrl});
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? autoReconnectServers = null,
    Object? connectionTimeout = null,
    Object? requestTimeout = null,
    Object? themeName = null,
    Object? fontSize = null,
    Object? enableAnimations = null,
    Object? compactMode = null,
    Object? maxConcurrentRequests = null,
    Object? enableHistory = null,
    Object? maxHistoryEntries = null,
    Object? enableCache = null,
    Object? maxCacheSize = null,
    Object? enableSyntaxHighlighting = null,
    Object? enableAutoComplete = null,
    Object? tabSize = null,
    Object? showLineNumbers = null,
    Object? wordWrap = null,
    Object? enableToolFilter = null,
    Object? aiProvider = null,
    Object? aiModel = null,
    Object? debugMode = null,
    Object? verboseLogging = null,
    Object? customBackendUrl = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      autoReconnectServers: null == autoReconnectServers
          ? _value.autoReconnectServers
          : autoReconnectServers // ignore: cast_nullable_to_non_nullable
              as bool,
      connectionTimeout: null == connectionTimeout
          ? _value.connectionTimeout
          : connectionTimeout // ignore: cast_nullable_to_non_nullable
              as int,
      requestTimeout: null == requestTimeout
          ? _value.requestTimeout
          : requestTimeout // ignore: cast_nullable_to_non_nullable
              as int,
      themeName: null == themeName
          ? _value.themeName
          : themeName // ignore: cast_nullable_to_non_nullable
              as String,
      fontSize: null == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      enableAnimations: null == enableAnimations
          ? _value.enableAnimations
          : enableAnimations // ignore: cast_nullable_to_non_nullable
              as bool,
      compactMode: null == compactMode
          ? _value.compactMode
          : compactMode // ignore: cast_nullable_to_non_nullable
              as bool,
      maxConcurrentRequests: null == maxConcurrentRequests
          ? _value.maxConcurrentRequests
          : maxConcurrentRequests // ignore: cast_nullable_to_non_nullable
              as int,
      enableHistory: null == enableHistory
          ? _value.enableHistory
          : enableHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      maxHistoryEntries: null == maxHistoryEntries
          ? _value.maxHistoryEntries
          : maxHistoryEntries // ignore: cast_nullable_to_non_nullable
              as int,
      enableCache: null == enableCache
          ? _value.enableCache
          : enableCache // ignore: cast_nullable_to_non_nullable
              as bool,
      maxCacheSize: null == maxCacheSize
          ? _value.maxCacheSize
          : maxCacheSize // ignore: cast_nullable_to_non_nullable
              as int,
      enableSyntaxHighlighting: null == enableSyntaxHighlighting
          ? _value.enableSyntaxHighlighting
          : enableSyntaxHighlighting // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAutoComplete: null == enableAutoComplete
          ? _value.enableAutoComplete
          : enableAutoComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      tabSize: null == tabSize
          ? _value.tabSize
          : tabSize // ignore: cast_nullable_to_non_nullable
              as int,
      showLineNumbers: null == showLineNumbers
          ? _value.showLineNumbers
          : showLineNumbers // ignore: cast_nullable_to_non_nullable
              as bool,
      wordWrap: null == wordWrap
          ? _value.wordWrap
          : wordWrap // ignore: cast_nullable_to_non_nullable
              as bool,
      enableToolFilter: null == enableToolFilter
          ? _value.enableToolFilter
          : enableToolFilter // ignore: cast_nullable_to_non_nullable
              as bool,
      aiProvider: null == aiProvider
          ? _value.aiProvider
          : aiProvider // ignore: cast_nullable_to_non_nullable
              as String,
      aiModel: null == aiModel
          ? _value.aiModel
          : aiModel // ignore: cast_nullable_to_non_nullable
              as String,
      debugMode: null == debugMode
          ? _value.debugMode
          : debugMode // ignore: cast_nullable_to_non_nullable
              as bool,
      verboseLogging: null == verboseLogging
          ? _value.verboseLogging
          : verboseLogging // ignore: cast_nullable_to_non_nullable
              as bool,
      customBackendUrl: null == customBackendUrl
          ? _value.customBackendUrl
          : customBackendUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
          _$AppSettingsImpl value, $Res Function(_$AppSettingsImpl) then) =
      __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      bool autoReconnectServers,
      int connectionTimeout,
      int requestTimeout,
      String themeName,
      double fontSize,
      bool enableAnimations,
      bool compactMode,
      int maxConcurrentRequests,
      bool enableHistory,
      int maxHistoryEntries,
      bool enableCache,
      int maxCacheSize,
      bool enableSyntaxHighlighting,
      bool enableAutoComplete,
      int tabSize,
      bool showLineNumbers,
      bool wordWrap,
      bool enableToolFilter,
      String aiProvider,
      String aiModel,
      bool debugMode,
      bool verboseLogging,
      String customBackendUrl});
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
      _$AppSettingsImpl _value, $Res Function(_$AppSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? autoReconnectServers = null,
    Object? connectionTimeout = null,
    Object? requestTimeout = null,
    Object? themeName = null,
    Object? fontSize = null,
    Object? enableAnimations = null,
    Object? compactMode = null,
    Object? maxConcurrentRequests = null,
    Object? enableHistory = null,
    Object? maxHistoryEntries = null,
    Object? enableCache = null,
    Object? maxCacheSize = null,
    Object? enableSyntaxHighlighting = null,
    Object? enableAutoComplete = null,
    Object? tabSize = null,
    Object? showLineNumbers = null,
    Object? wordWrap = null,
    Object? enableToolFilter = null,
    Object? aiProvider = null,
    Object? aiModel = null,
    Object? debugMode = null,
    Object? verboseLogging = null,
    Object? customBackendUrl = null,
  }) {
    return _then(_$AppSettingsImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      autoReconnectServers: null == autoReconnectServers
          ? _value.autoReconnectServers
          : autoReconnectServers // ignore: cast_nullable_to_non_nullable
              as bool,
      connectionTimeout: null == connectionTimeout
          ? _value.connectionTimeout
          : connectionTimeout // ignore: cast_nullable_to_non_nullable
              as int,
      requestTimeout: null == requestTimeout
          ? _value.requestTimeout
          : requestTimeout // ignore: cast_nullable_to_non_nullable
              as int,
      themeName: null == themeName
          ? _value.themeName
          : themeName // ignore: cast_nullable_to_non_nullable
              as String,
      fontSize: null == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      enableAnimations: null == enableAnimations
          ? _value.enableAnimations
          : enableAnimations // ignore: cast_nullable_to_non_nullable
              as bool,
      compactMode: null == compactMode
          ? _value.compactMode
          : compactMode // ignore: cast_nullable_to_non_nullable
              as bool,
      maxConcurrentRequests: null == maxConcurrentRequests
          ? _value.maxConcurrentRequests
          : maxConcurrentRequests // ignore: cast_nullable_to_non_nullable
              as int,
      enableHistory: null == enableHistory
          ? _value.enableHistory
          : enableHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      maxHistoryEntries: null == maxHistoryEntries
          ? _value.maxHistoryEntries
          : maxHistoryEntries // ignore: cast_nullable_to_non_nullable
              as int,
      enableCache: null == enableCache
          ? _value.enableCache
          : enableCache // ignore: cast_nullable_to_non_nullable
              as bool,
      maxCacheSize: null == maxCacheSize
          ? _value.maxCacheSize
          : maxCacheSize // ignore: cast_nullable_to_non_nullable
              as int,
      enableSyntaxHighlighting: null == enableSyntaxHighlighting
          ? _value.enableSyntaxHighlighting
          : enableSyntaxHighlighting // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAutoComplete: null == enableAutoComplete
          ? _value.enableAutoComplete
          : enableAutoComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      tabSize: null == tabSize
          ? _value.tabSize
          : tabSize // ignore: cast_nullable_to_non_nullable
              as int,
      showLineNumbers: null == showLineNumbers
          ? _value.showLineNumbers
          : showLineNumbers // ignore: cast_nullable_to_non_nullable
              as bool,
      wordWrap: null == wordWrap
          ? _value.wordWrap
          : wordWrap // ignore: cast_nullable_to_non_nullable
              as bool,
      enableToolFilter: null == enableToolFilter
          ? _value.enableToolFilter
          : enableToolFilter // ignore: cast_nullable_to_non_nullable
              as bool,
      aiProvider: null == aiProvider
          ? _value.aiProvider
          : aiProvider // ignore: cast_nullable_to_non_nullable
              as String,
      aiModel: null == aiModel
          ? _value.aiModel
          : aiModel // ignore: cast_nullable_to_non_nullable
              as String,
      debugMode: null == debugMode
          ? _value.debugMode
          : debugMode // ignore: cast_nullable_to_non_nullable
              as bool,
      verboseLogging: null == verboseLogging
          ? _value.verboseLogging
          : verboseLogging // ignore: cast_nullable_to_non_nullable
              as bool,
      customBackendUrl: null == customBackendUrl
          ? _value.customBackendUrl
          : customBackendUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl(
      {this.userId = '',
      this.autoReconnectServers = true,
      this.connectionTimeout = 30,
      this.requestTimeout = 60,
      this.themeName = 'duotoneDark',
      this.fontSize = 14.0,
      this.enableAnimations = true,
      this.compactMode = false,
      this.maxConcurrentRequests = 10,
      this.enableHistory = true,
      this.maxHistoryEntries = 100,
      this.enableCache = true,
      this.maxCacheSize = 50,
      this.enableSyntaxHighlighting = true,
      this.enableAutoComplete = true,
      this.tabSize = 4,
      this.showLineNumbers = true,
      this.wordWrap = true,
      this.enableToolFilter = true,
      this.aiProvider = '',
      this.aiModel = '',
      this.debugMode = false,
      this.verboseLogging = false,
      this.customBackendUrl = ''});

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

// General
  @override
  @JsonKey()
  final String userId;
  @override
  @JsonKey()
  final bool autoReconnectServers;
  @override
  @JsonKey()
  final int connectionTimeout;
  @override
  @JsonKey()
  final int requestTimeout;
// Appearance
  @override
  @JsonKey()
  final String themeName;
  @override
  @JsonKey()
  final double fontSize;
  @override
  @JsonKey()
  final bool enableAnimations;
  @override
  @JsonKey()
  final bool compactMode;
// Network
  @override
  @JsonKey()
  final int maxConcurrentRequests;
// Data
  @override
  @JsonKey()
  final bool enableHistory;
  @override
  @JsonKey()
  final int maxHistoryEntries;
  @override
  @JsonKey()
  final bool enableCache;
  @override
  @JsonKey()
  final int maxCacheSize;
// Editor
  @override
  @JsonKey()
  final bool enableSyntaxHighlighting;
  @override
  @JsonKey()
  final bool enableAutoComplete;
  @override
  @JsonKey()
  final int tabSize;
  @override
  @JsonKey()
  final bool showLineNumbers;
  @override
  @JsonKey()
  final bool wordWrap;
// Tool Filter
  @override
  @JsonKey()
  final bool enableToolFilter;
  @override
  @JsonKey()
  final String aiProvider;
  @override
  @JsonKey()
  final String aiModel;
// Advanced
  @override
  @JsonKey()
  final bool debugMode;
  @override
  @JsonKey()
  final bool verboseLogging;
  @override
  @JsonKey()
  final String customBackendUrl;

  @override
  String toString() {
    return 'AppSettings(userId: $userId, autoReconnectServers: $autoReconnectServers, connectionTimeout: $connectionTimeout, requestTimeout: $requestTimeout, themeName: $themeName, fontSize: $fontSize, enableAnimations: $enableAnimations, compactMode: $compactMode, maxConcurrentRequests: $maxConcurrentRequests, enableHistory: $enableHistory, maxHistoryEntries: $maxHistoryEntries, enableCache: $enableCache, maxCacheSize: $maxCacheSize, enableSyntaxHighlighting: $enableSyntaxHighlighting, enableAutoComplete: $enableAutoComplete, tabSize: $tabSize, showLineNumbers: $showLineNumbers, wordWrap: $wordWrap, enableToolFilter: $enableToolFilter, aiProvider: $aiProvider, aiModel: $aiModel, debugMode: $debugMode, verboseLogging: $verboseLogging, customBackendUrl: $customBackendUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.autoReconnectServers, autoReconnectServers) ||
                other.autoReconnectServers == autoReconnectServers) &&
            (identical(other.connectionTimeout, connectionTimeout) ||
                other.connectionTimeout == connectionTimeout) &&
            (identical(other.requestTimeout, requestTimeout) ||
                other.requestTimeout == requestTimeout) &&
            (identical(other.themeName, themeName) ||
                other.themeName == themeName) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.enableAnimations, enableAnimations) ||
                other.enableAnimations == enableAnimations) &&
            (identical(other.compactMode, compactMode) ||
                other.compactMode == compactMode) &&
            (identical(other.maxConcurrentRequests, maxConcurrentRequests) ||
                other.maxConcurrentRequests == maxConcurrentRequests) &&
            (identical(other.enableHistory, enableHistory) ||
                other.enableHistory == enableHistory) &&
            (identical(other.maxHistoryEntries, maxHistoryEntries) ||
                other.maxHistoryEntries == maxHistoryEntries) &&
            (identical(other.enableCache, enableCache) ||
                other.enableCache == enableCache) &&
            (identical(other.maxCacheSize, maxCacheSize) ||
                other.maxCacheSize == maxCacheSize) &&
            (identical(
                    other.enableSyntaxHighlighting, enableSyntaxHighlighting) ||
                other.enableSyntaxHighlighting == enableSyntaxHighlighting) &&
            (identical(other.enableAutoComplete, enableAutoComplete) ||
                other.enableAutoComplete == enableAutoComplete) &&
            (identical(other.tabSize, tabSize) || other.tabSize == tabSize) &&
            (identical(other.showLineNumbers, showLineNumbers) ||
                other.showLineNumbers == showLineNumbers) &&
            (identical(other.wordWrap, wordWrap) ||
                other.wordWrap == wordWrap) &&
            (identical(other.enableToolFilter, enableToolFilter) ||
                other.enableToolFilter == enableToolFilter) &&
            (identical(other.aiProvider, aiProvider) ||
                other.aiProvider == aiProvider) &&
            (identical(other.aiModel, aiModel) || other.aiModel == aiModel) &&
            (identical(other.debugMode, debugMode) ||
                other.debugMode == debugMode) &&
            (identical(other.verboseLogging, verboseLogging) ||
                other.verboseLogging == verboseLogging) &&
            (identical(other.customBackendUrl, customBackendUrl) ||
                other.customBackendUrl == customBackendUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        userId,
        autoReconnectServers,
        connectionTimeout,
        requestTimeout,
        themeName,
        fontSize,
        enableAnimations,
        compactMode,
        maxConcurrentRequests,
        enableHistory,
        maxHistoryEntries,
        enableCache,
        maxCacheSize,
        enableSyntaxHighlighting,
        enableAutoComplete,
        tabSize,
        showLineNumbers,
        wordWrap,
        enableToolFilter,
        aiProvider,
        aiModel,
        debugMode,
        verboseLogging,
        customBackendUrl
      ]);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(
      this,
    );
  }
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings(
      {final String userId,
      final bool autoReconnectServers,
      final int connectionTimeout,
      final int requestTimeout,
      final String themeName,
      final double fontSize,
      final bool enableAnimations,
      final bool compactMode,
      final int maxConcurrentRequests,
      final bool enableHistory,
      final int maxHistoryEntries,
      final bool enableCache,
      final int maxCacheSize,
      final bool enableSyntaxHighlighting,
      final bool enableAutoComplete,
      final int tabSize,
      final bool showLineNumbers,
      final bool wordWrap,
      final bool enableToolFilter,
      final String aiProvider,
      final String aiModel,
      final bool debugMode,
      final bool verboseLogging,
      final String customBackendUrl}) = _$AppSettingsImpl;

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

// General
  @override
  String get userId;
  @override
  bool get autoReconnectServers;
  @override
  int get connectionTimeout;
  @override
  int get requestTimeout; // Appearance
  @override
  String get themeName;
  @override
  double get fontSize;
  @override
  bool get enableAnimations;
  @override
  bool get compactMode; // Network
  @override
  int get maxConcurrentRequests; // Data
  @override
  bool get enableHistory;
  @override
  int get maxHistoryEntries;
  @override
  bool get enableCache;
  @override
  int get maxCacheSize; // Editor
  @override
  bool get enableSyntaxHighlighting;
  @override
  bool get enableAutoComplete;
  @override
  int get tabSize;
  @override
  bool get showLineNumbers;
  @override
  bool get wordWrap; // Tool Filter
  @override
  bool get enableToolFilter;
  @override
  String get aiProvider;
  @override
  String get aiModel; // Advanced
  @override
  bool get debugMode;
  @override
  bool get verboseLogging;
  @override
  String get customBackendUrl;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
