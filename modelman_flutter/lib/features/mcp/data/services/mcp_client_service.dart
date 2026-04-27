import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/api_service.dart';
import '../../../servers/data/models/server_model.dart';
import '../../../tools/data/models/tool_model.dart';

const _uuid = Uuid();

/// High-level MCP client service that wraps [ApiService] and provides
/// typed server/tool operations.
class McpClientService {
  final ApiService _api;

  McpClientService(this._api);

  /// Auto-detects the server's transport and capabilities.
  Future<ServerConfig> autoDetectServer(String url) async {
    final result = await _api.autoDetectServer(url);

    return ServerConfig(
      id: _uuid.v4(),
      name: result['name'] as String? ?? 'Auto-detected Server',
      url: url,
      transport: result['transport'] as String? ?? 'http',
    );
  }

  /// Connects to an MCP server and returns the updated config.
  Future<ServerConfig> connect(ServerConfig server) async {
    await _api.connectToServer(
      serverId: server.id,
      serverName: server.name,
      url: server.url,
      transport: server.transport,
      auth: server.auth?.toJson(),
    );

    return server.copyWith(
      connected: true,
      error: null,
      lastConnected: DateTime.now(),
    );
  }

  /// Disconnects from a server.
  Future<void> disconnect(String serverId) async {
    await _api.disconnectFromServer(serverId);
  }

  /// Lists all tools available on a connected server.
  Future<List<ToolSchema>> listTools(String serverId) async {
    final raw = await _api.listTools(serverId);
    return raw
        .map((t) => ToolSchema.fromJson({...t, 'serverId': serverId}))
        .toList();
  }

  /// Executes a tool and returns the result with timing.
  Future<ToolExecutionResult> executeTool({
    required String serverId,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await _api.executeTool(
        serverId: serverId,
        toolName: toolName,
        arguments: arguments,
      );
      stopwatch.stop();

      return ToolExecutionResult(
        toolName: toolName,
        serverId: serverId,
        arguments: arguments,
        result: result,
        timestamp: DateTime.now(),
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return ToolExecutionResult(
        toolName: toolName,
        serverId: serverId,
        arguments: arguments,
        result: null,
        timestamp: DateTime.now(),
        duration: stopwatch.elapsed,
        error: e.toString(),
        isError: true,
      );
    }
  }

  /// Gets connection status for a server.
  Future<bool> getConnectionStatus(String serverId) async {
    try {
      return await _api.getConnectionStatus(serverId);
    } catch (_) {
      return false;
    }
  }

  /// Gets server info (name, version, capabilities).
  Future<Map<String, dynamic>> getServerInfo(String serverId) async {
    return await _api.getServerInfo(serverId);
  }

  /// Fetches the server's favicon.
  Future<String?> getFavicon(String serverUrl) async {
    try {
      return await _api.getFavicon(serverUrl: serverUrl);
    } catch (_) {
      return null;
    }
  }
}

final mcpClientServiceProvider = Provider<McpClientService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return McpClientService(api);
});
