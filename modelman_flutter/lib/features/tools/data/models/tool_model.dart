import 'package:freezed_annotation/freezed_annotation.dart';

part 'tool_model.freezed.dart';
part 'tool_model.g.dart';

/// Schema of an MCP tool as returned by the backend.
@freezed
class ToolSchema with _$ToolSchema {
  const factory ToolSchema({
    required String name,
    String? description,
    Map<String, dynamic>? inputSchema,
    @Default('') String serverId,
  }) = _ToolSchema;

  factory ToolSchema.fromJson(Map<String, dynamic> json) =>
      _$ToolSchemaFromJson(json);
}

/// Result of executing an MCP tool.
@freezed
class ToolExecutionResult with _$ToolExecutionResult {
  const factory ToolExecutionResult({
    required String toolName,
    required String serverId,
    required Map<String, dynamic> arguments,
    required dynamic result,
    required DateTime timestamp,
    required Duration duration,
    String? error,
    @Default(false) bool isError,
  }) = _ToolExecutionResult;

  factory ToolExecutionResult.fromJson(Map<String, dynamic> json) =>
      _$ToolExecutionResultFromJson(json);
}

/// State of a tool execution request.
enum ToolExecutionStatus {
  idle,
  executing,
  success,
  error,
}
