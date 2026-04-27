// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ToolSchemaImpl _$$ToolSchemaImplFromJson(Map<String, dynamic> json) =>
    _$ToolSchemaImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema: json['inputSchema'] as Map<String, dynamic>?,
      serverId: json['serverId'] as String? ?? '',
    );

Map<String, dynamic> _$$ToolSchemaImplToJson(_$ToolSchemaImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      if (instance.inputSchema case final value?) 'inputSchema': value,
      'serverId': instance.serverId,
    };

_$ToolExecutionResultImpl _$$ToolExecutionResultImplFromJson(
        Map<String, dynamic> json) =>
    _$ToolExecutionResultImpl(
      toolName: json['toolName'] as String,
      serverId: json['serverId'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
      result: json['result'],
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      error: json['error'] as String?,
      isError: json['isError'] as bool? ?? false,
    );

Map<String, dynamic> _$$ToolExecutionResultImplToJson(
        _$ToolExecutionResultImpl instance) =>
    <String, dynamic>{
      'toolName': instance.toolName,
      'serverId': instance.serverId,
      'arguments': instance.arguments,
      if (instance.result case final value?) 'result': value,
      'timestamp': instance.timestamp.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      if (instance.error case final value?) 'error': value,
      'isError': instance.isError,
    };
