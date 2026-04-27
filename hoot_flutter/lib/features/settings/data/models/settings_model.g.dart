// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      userId: json['userId'] as String? ?? '',
      autoReconnectServers: json['autoReconnectServers'] as bool? ?? true,
      connectionTimeout: (json['connectionTimeout'] as num?)?.toInt() ?? 30,
      requestTimeout: (json['requestTimeout'] as num?)?.toInt() ?? 60,
      themeName: json['themeName'] as String? ?? 'duotoneDark',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      enableAnimations: json['enableAnimations'] as bool? ?? true,
      compactMode: json['compactMode'] as bool? ?? false,
      maxConcurrentRequests:
          (json['maxConcurrentRequests'] as num?)?.toInt() ?? 10,
      enableHistory: json['enableHistory'] as bool? ?? true,
      maxHistoryEntries: (json['maxHistoryEntries'] as num?)?.toInt() ?? 100,
      enableCache: json['enableCache'] as bool? ?? true,
      maxCacheSize: (json['maxCacheSize'] as num?)?.toInt() ?? 50,
      enableSyntaxHighlighting:
          json['enableSyntaxHighlighting'] as bool? ?? true,
      enableAutoComplete: json['enableAutoComplete'] as bool? ?? true,
      tabSize: (json['tabSize'] as num?)?.toInt() ?? 4,
      showLineNumbers: json['showLineNumbers'] as bool? ?? true,
      wordWrap: json['wordWrap'] as bool? ?? true,
      enableToolFilter: json['enableToolFilter'] as bool? ?? true,
      aiProvider: json['aiProvider'] as String? ?? '',
      aiModel: json['aiModel'] as String? ?? '',
      debugMode: json['debugMode'] as bool? ?? false,
      verboseLogging: json['verboseLogging'] as bool? ?? false,
      customBackendUrl: json['customBackendUrl'] as String? ?? '',
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'autoReconnectServers': instance.autoReconnectServers,
      'connectionTimeout': instance.connectionTimeout,
      'requestTimeout': instance.requestTimeout,
      'themeName': instance.themeName,
      'fontSize': instance.fontSize,
      'enableAnimations': instance.enableAnimations,
      'compactMode': instance.compactMode,
      'maxConcurrentRequests': instance.maxConcurrentRequests,
      'enableHistory': instance.enableHistory,
      'maxHistoryEntries': instance.maxHistoryEntries,
      'enableCache': instance.enableCache,
      'maxCacheSize': instance.maxCacheSize,
      'enableSyntaxHighlighting': instance.enableSyntaxHighlighting,
      'enableAutoComplete': instance.enableAutoComplete,
      'tabSize': instance.tabSize,
      'showLineNumbers': instance.showLineNumbers,
      'wordWrap': instance.wordWrap,
      'enableToolFilter': instance.enableToolFilter,
      'aiProvider': instance.aiProvider,
      'aiModel': instance.aiModel,
      'debugMode': instance.debugMode,
      'verboseLogging': instance.verboseLogging,
      'customBackendUrl': instance.customBackendUrl,
    };
