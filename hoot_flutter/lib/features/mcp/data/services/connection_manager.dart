import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../servers/data/models/server_model.dart';
import '../../../servers/presentation/providers/server_providers.dart';
import '../../../tools/presentation/providers/tool_providers.dart';
import '../../../../layout/console_panel.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../main.dart';
import 'mcp_client_service.dart';

/// Manages MCP server connections, auto-reconnection, and tool discovery.
/// Now with proper error handling and snackbar notifications.
class ConnectionManager {
  final McpClientService _mcp;
  final Ref _ref;
  Timer? _healthCheckTimer;

  ConnectionManager(this._mcp, this._ref);

  /// Connects to a server, discovers tools, and updates state.
  Future<bool> connectAndDiscover(ServerConfig server) async {
    _log('Connecting to ${server.name}...');

    try {
      final connected = await _mcp.connect(server);
      _ref.read(serverListProvider.notifier).updateServer(connected);
      _log('Connected to ${server.name}', level: LogLevel.info);
      showSuccessSnackbar('Connected to ${server.name}');

      // Auto-discover tools
      try {
        final tools = await _mcp.listTools(server.id);
        _ref.read(toolListProvider.notifier).loadTools(server.id);
        _log('Discovered ${tools.length} tools on ${server.name}');
      } catch (e) {
        _log('Failed to discover tools: ${_friendlyError(e)}',
            level: LogLevel.warn);
      }

      return true;
    } catch (e) {
      final message = _friendlyError(e);
      _ref.read(serverListProvider.notifier).updateServer(
            server.copyWith(connected: false, error: message),
          );
      _log('Connection failed: $message', level: LogLevel.error);
      showErrorSnackbar('Failed to connect: $message');
      return false;
    }
  }

  /// Disconnects from a server and cleans up.
  Future<void> disconnectServer(ServerConfig server) async {
    try {
      await _mcp.disconnect(server.id);
      _ref.read(serverListProvider.notifier).updateServer(
            server.copyWith(connected: false),
          );
      _ref.read(toolListProvider.notifier).clearTools(server.id);
      _log('Disconnected from ${server.name}');
      showSuccessSnackbar('Disconnected from ${server.name}');
    } catch (e) {
      final message = _friendlyError(e);
      _log('Disconnect error: $message', level: LogLevel.warn);
      showErrorSnackbar('Disconnect error: $message');
    }
  }

  /// Auto-detect server configuration from URL.
  Future<ServerConfig?> autoDetect(String url) async {
    _log('Auto-detecting server at $url...');
    try {
      final config = await _mcp.autoDetectServer(url);
      _log('Detected: ${config.name} (${config.transport})');
      showSuccessSnackbar('Detected: ${config.name}');
      return config;
    } catch (e) {
      final message = _friendlyError(e);
      _log('Auto-detect failed: $message', level: LogLevel.error);
      showErrorSnackbar('Auto-detect failed: $message');
      return null;
    }
  }

  /// Starts periodic health checks on all connected servers.
  void startHealthChecks({Duration interval = const Duration(seconds: 30)}) {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(interval, (_) => _checkHealth());
  }

  void stopHealthChecks() {
    _healthCheckTimer?.cancel();
  }

  Future<void> _checkHealth() async {
    final servers = _ref.read(serverListProvider);
    for (final server in servers.where((s) => s.connected)) {
      try {
        final isConnected = await _mcp.getConnectionStatus(server.id);
        if (!isConnected) {
          _ref.read(serverListProvider.notifier).updateServer(
                server.copyWith(connected: false, error: 'Connection lost'),
              );
          _log('Lost connection to ${server.name}', level: LogLevel.warn);
          showErrorSnackbar('Lost connection to ${server.name}');
        }
      } catch (_) {
        // Ignore health check errors silently
      }
    }
  }

  /// Converts any error to a user-friendly message.
  String _friendlyError(Object e) {
    if (e is ApiException) return e.message;
    return ApiException.fromError(e).message;
  }

  void _log(String message, {LogLevel level = LogLevel.info}) {
    debugPrint('[ConnectionManager] $message');
    try {
      final logs = _ref.read(consoleLogsProvider);
      _ref.read(consoleLogsProvider.notifier).state = [
        ...logs,
        ConsoleLog(message: message, level: level),
      ];
    } catch (_) {
      // Console not available
    }
  }

  void dispose() {
    stopHealthChecks();
  }
}

final connectionManagerProvider = Provider<ConnectionManager>((ref) {
  final mcp = ref.watch(mcpClientServiceProvider);
  final manager = ConnectionManager(mcp, ref);
  ref.onDispose(() => manager.dispose());
  return manager;
});
