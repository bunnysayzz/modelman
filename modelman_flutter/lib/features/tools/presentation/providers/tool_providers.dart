import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../data/models/tool_model.dart';

/// Notifier managing MCP tools per server.
class ToolListNotifier extends StateNotifier<Map<String, List<ToolSchema>>> {
  final ApiService _api;

  ToolListNotifier(this._api) : super({});

  /// Fetches tools for a given [serverId] from the backend.
  Future<void> loadTools(String serverId) async {
    try {
      final rawTools = await _api.listTools(serverId);
      final tools = rawTools
          .map((t) => ToolSchema.fromJson({...t, 'serverId': serverId}))
          .toList();
      state = {...state, serverId: tools};
    } catch (e) {
      // Keep existing tools on error
    }
  }

  /// Clears tools for a server (e.g. on disconnect).
  void clearTools(String serverId) {
    final newState = Map<String, List<ToolSchema>>.from(state);
    newState.remove(serverId);
    state = newState;
  }

  /// Returns a flat list of all tools across all servers.
  List<ToolSchema> get allTools =>
      state.values.expand((tools) => tools).toList();
}

/// Provider for tools organized by server ID.
final toolListProvider =
    StateNotifierProvider<ToolListNotifier, Map<String, List<ToolSchema>>>(
  (ref) {
    final api = ref.watch(apiServiceProvider);
    return ToolListNotifier(api);
  },
);

/// The currently selected tool.
final selectedToolProvider = StateProvider<ToolSchema?>((ref) => null);

/// Notifier for tool execution state.
class ToolExecutionNotifier extends StateNotifier<ToolExecutionStatus> {
  final ApiService _api;

  ToolExecutionNotifier(this._api) : super(ToolExecutionStatus.idle);

  ToolExecutionResult? _lastResult;
  ToolExecutionResult? get lastResult => _lastResult;

  Future<ToolExecutionResult> execute({
    required String serverId,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    state = ToolExecutionStatus.executing;
    final stopwatch = Stopwatch()..start();

    try {
      final result = await _api.executeTool(
        serverId: serverId,
        toolName: toolName,
        arguments: arguments,
      );
      stopwatch.stop();

      final execResult = ToolExecutionResult(
        toolName: toolName,
        serverId: serverId,
        arguments: arguments,
        result: result,
        timestamp: DateTime.now(),
        duration: stopwatch.elapsed,
      );

      _lastResult = execResult;
      state = ToolExecutionStatus.success;
      return execResult;
    } catch (e) {
      stopwatch.stop();

      final execResult = ToolExecutionResult(
        toolName: toolName,
        serverId: serverId,
        arguments: arguments,
        result: null,
        timestamp: DateTime.now(),
        duration: stopwatch.elapsed,
        error: e.toString(),
        isError: true,
      );

      _lastResult = execResult;
      state = ToolExecutionStatus.error;
      return execResult;
    }
  }

  void reset() {
    state = ToolExecutionStatus.idle;
    _lastResult = null;
  }
}

/// Provider for tool execution state.
final toolExecutionProvider =
    StateNotifierProvider<ToolExecutionNotifier, ToolExecutionStatus>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ToolExecutionNotifier(api);
});

/// Execution history (most recent first).
final executionHistoryProvider =
    StateProvider<List<ToolExecutionResult>>((ref) => []);
