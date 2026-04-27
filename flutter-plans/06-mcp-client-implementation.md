# MCP Client Implementation

## Overview

This document details the Model Context Protocol (MCP) client implementation for Flutter, mapping from the current React implementation.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                   MCP Client Architecture                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │   Flutter    │      │   Backend    │      │   MCP       │ │
│  │     App      │◄────►│   Server     │◄────►│   Server    │ │
│  │              │      │  (Express)   │      │  (HTTP/SSE) │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                                                   │
│         │                                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              MCP Client Layer                           │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐   │ │
│  │  │  Connection  │  │  Tool        │  │  Resource  │   │ │
│  │  │  Manager    │  │  Executor    │  │  Handler   │   │ │
│  │  └──────────────┘  └──────────────┘  └────────────┘   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Current React Implementation

### src/lib/mcpClient.ts

```typescript
// Current React MCP client uses backend as proxy
export async function executeTool(
  serverId: string,
  toolName: string,
  arguments: Record<string, any>
): Promise<ToolResult> {
  const response = await fetch('/api/mcp/execute', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ serverId, toolName, arguments }),
  });
  
  return response.json();
}
```

## Flutter Implementation

### lib/features/mcp/data/services/mcp_client_service.dart

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../servers/data/models/server_model.dart';

class MCPClientService {
  final ApiService _apiService;

  MCPClientService(this._apiService);

  // Auto-detect server configuration
  Future<ServerConfig> autoDetectServer(String url) async {
    final result = await _apiService.autoDetectServer(url);
    
    return ServerConfig(
      id: const Uuid().v4(),
      name: result['name'] ?? 'Auto-detected Server',
      url: url,
      transport: result['transport'] ?? 'http',
      connected: false,
    );
  }

  // Connect to MCP server
  Future<ConnectionResult> connectToServer({
    required String serverId,
    required String serverName,
    required String url,
    required String transport,
    AuthConfig? auth,
    String? authorizationCode,
  }) async {
    final result = await _apiService.connectToServer(
      serverId: serverId,
      serverName: serverName,
      url: url,
      transport: transport,
      auth: auth?.toJson(),
      authorizationCode: authorizationCode,
    );

    return ConnectionResult.fromJson(result);
  }

  // Disconnect from server
  Future<void> disconnectFromServer(String serverId) async {
    await _apiService.disconnectFromServer(serverId);
  }

  // List available tools
  Future<List<ToolSchema>> listTools(String serverId) async {
    final tools = await _apiService.listTools(serverId);
    return tools.map((t) => ToolSchema.fromJson(t)).toList();
  }

  // Execute a tool
  Future<ToolExecutionResult> executeTool({
    required String serverId,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    final result = await _apiService.executeTool(
      serverId: serverId,
      toolName: toolName,
      arguments: arguments,
    );

    return ToolExecutionResult.fromJson(result);
  }

  // Get server information
  Future<ServerInfo?> getServerInfo(String serverId) async {
    final info = await _apiService.getServerInfo(serverId);
    return info != null ? ServerInfo.fromJson(info) : null;
  }

  // Get connection status
  Future<bool> getConnectionStatus(String serverId) async {
    return await _apiService.getConnectionStatus(serverId);
  }

  // Get OAuth metadata
  Future<OAuthMetadata?> getOAuthMetadata(String serverId) async {
    final metadata = await _apiService.getOAuthMetadata(serverId);
    return metadata != null ? OAuthMetadata.fromJson(metadata) : null;
  }
}

final mcpClientServiceProvider = Provider<MCPClientService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MCPClientService(apiService);
});
```

## Connection Manager

### lib/features/mcp/data/services/connection_manager.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/providers.dart';
import 'mcp_client_service.dart';

class ConnectionManager {
  final MCPClientService _mcpClient;
  final Ref _ref;

  ConnectionManager(this._mcpClient, this._ref);

  // Connect with auto-reconnect logic
  Future<ConnectionResult> connectWithAutoReconnect({
    required String serverId,
    required String serverName,
    required String url,
    required String transport,
    AuthConfig? auth,
  }) async {
    // Check if already connected
    final status = await _mcpClient.getConnectionStatus(serverId);
    if (status) {
      return ConnectionResult(success: true);
    }

    // Attempt connection
    final result = await _mcpClient.connectToServer(
      serverId: serverId,
      serverName: serverName,
      url: url,
      transport: transport,
      auth: auth,
    );

    if (result.success) {
      // Update server state
      _ref.read(serversProvider.notifier).updateServer(
        serverId,
        const ServerConfig(connected: true),
      );

      // Load tools
      final tools = await _mcpClient.listTools(serverId);
      _ref.read(toolsProvider.notifier).setTools(serverId, tools);
    }

    return result;
  }

  // Disconnect and cleanup
  Future<void> disconnectAndCleanup(String serverId) async {
    await _mcpClient.disconnectFromServer(serverId);

    // Update server state
    _ref.read(serversProvider.notifier).updateServer(
      serverId,
      const ServerConfig(connected: false),
    );

    // Clear tools
    _ref.read(toolsProvider.notifier).clearTools(serverId);
  }

  // Ensure connection (auto-reconnect if needed)
  Future<bool> ensureConnected(String serverId) async {
    final servers = _ref.read(serversProvider);
    final server = servers.firstWhere(
      (s) => s.id == serverId,
      orElse: () => null as ServerConfig,
    );

    if (server == null) return false;

    final isConnected = await _mcpClient.getConnectionStatus(serverId);
    if (isConnected) return true;

    // Auto-reconnect using saved config
    final result = await connectWithAutoReconnect(
      serverId: server.id,
      serverName: server.name,
      url: server.url,
      transport: server.transport ?? 'http',
      auth: server.auth,
    );

    return result.success;
  }
}

final connectionManagerProvider = Provider<ConnectionManager>((ref) {
  final mcpClient = ref.watch(mcpClientServiceProvider);
  return ConnectionManager(mcpClient, ref);
});
```

## Tool Executor

### lib/features/mcp/data/services/tool_executor.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/providers.dart';
import 'mcp_client_service.dart';
import 'connection_manager.dart';

class ToolExecutor {
  final MCPClientService _mcpClient;
  final ConnectionManager _connectionManager;
  final Ref _ref;

  ToolExecutor(this._mcpClient, this._connectionManager, this._ref);

  // Execute tool with connection check
  Future<ToolExecutionResult> execute({
    required String serverId,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    // Ensure connected
    final isConnected = await _connectionManager.ensureConnected(serverId);
    if (!isConnected) {
      throw ToolExecutionException('Failed to connect to server');
    }

    // Set executing state
    _ref.read(executingToolsProvider.notifier).setExecuting(
      serverId,
      toolName,
      true,
    );

    try {
      // Execute tool
      final result = await _mcpClient.executeTool(
        serverId: serverId,
        toolName: toolName,
        arguments: arguments,
      );

      // Add to history
      _ref.read(executionHistoryProvider.notifier).addEntry(
        ExecutionEntry(
          serverId: serverId,
          toolName: toolName,
          arguments: arguments,
          result: result,
          timestamp: DateTime.now(),
        ),
      );

      return result;
    } finally {
      // Clear executing state
      _ref.read(executingToolsProvider.notifier).setExecuting(
        serverId,
        toolName,
        false,
      );
    }
  }

  // Validate tool arguments
  bool validateArguments(ToolSchema tool, Map<String, dynamic> arguments) {
    final schema = tool.inputSchema;
    if (schema == null) return true;

    // Basic validation based on JSON Schema
    // For full implementation, use a JSON Schema validator
    final properties = schema['properties'] as Map<String, dynamic>?;
    final required = schema['required'] as List<String>?;

    if (required != null) {
      for (final field in required) {
        if (!arguments.containsKey(field)) {
          return false;
        }
      }
    }

    return true;
  }

  // Get argument suggestions
  Map<String, dynamic> getArgumentSuggestions(ToolSchema tool) {
    final schema = tool.inputSchema;
    if (schema == null) return {};

    final properties = schema['properties'] as Map<String, dynamic>?;
    if (properties == null) return {};

    final suggestions = <String, dynamic>{};

    for (final entry in properties.entries) {
      final key = entry.key;
      final value = entry.value as Map<String, dynamic>;

      if (value.containsKey('default')) {
        suggestions[key] = value['default'];
      } else if (value.containsKey('example')) {
        suggestions[key] = value['example'];
      }
    }

    return suggestions;
  }
}

class ToolExecutionException implements Exception {
  final String message;
  ToolExecutionException(this.message);
}

final toolExecutorProvider = Provider<ToolExecutor>((ref) {
  final mcpClient = ref.watch(mcpClientServiceProvider);
  final connectionManager = ref.watch(connectionManagerProvider);
  return ToolExecutor(mcpClient, connectionManager, ref);
});
```

## Real-time Tool Execution

### lib/features/mcp/data/services/streaming_executor.dart

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/sse_client.dart';
import 'mcp_client_service.dart';

class StreamingExecutor {
  final MCPClientService _mcpClient;
  final SseClient _sseClient;

  StreamingExecutor(this._mcpClient, this._sseClient);

  // Execute tool with streaming results
  Stream<ToolExecutionProgress> executeWithStream({
    required String serverId,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async* {
    // Start execution
    final result = await _mcpClient.executeTool(
      serverId: serverId,
      toolName: toolName,
      arguments: arguments,
    );

    yield ToolExecutionProgress(
      status: ExecutionStatus.completed,
      result: result,
    );
  }

  // Connect to SSE endpoint for real-time updates
  Stream<Map<String, dynamic>> connectToExecutionStream(String executionId) {
    final streamUrl = '${AppConfig.backendUrl}/mcp/execute/$executionId/stream';
    _sseClient.connect(streamUrl);

    return _sseClient.events.map((event) => event);
  }

  void dispose() {
    _sseClient.disconnect();
  }
}

enum ExecutionStatus { pending, running, completed, error }

class ToolExecutionProgress {
  final ExecutionStatus status;
  final ToolExecutionResult? result;
  final String? error;

  ToolExecutionProgress({
    required this.status,
    this.result,
    this.error,
  });
}

final streamingExecutorProvider = Provider<StreamingExecutor>((ref) {
  final mcpClient = ref.watch(mcpClientServiceProvider);
  final sseClient = ref.watch(sseClientProvider);
  return StreamingExecutor(mcpClient, sseClient);
});
```

## Data Models

### lib/features/mcp/data/models/mcp_models.dart

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mcp_models.freezed.dart';
part 'mcp_models.g.dart';

@freezed
class ToolExecutionResult with _$ToolExecutionResult {
  const factory ToolExecutionResult({
    @JsonKey(default: false) bool success,
    dynamic content,
    String? error,
    @JsonKey(name: 'isError') bool? isError,
    @JsonKey(name: 'toolResult') dynamic toolResult,
  }) = _ToolExecutionResult;

  factory ToolExecutionResult.fromJson(Map<String, dynamic> json) =>
      _$ToolExecutionResultFromJson(json);
}

@freezed
class ExecutionEntry with _$ExecutionEntry {
  const factory ExecutionEntry({
    required String id,
    required String serverId,
    required String toolName,
    required Map<String, dynamic> arguments,
    required ToolExecutionResult result,
    required DateTime timestamp,
  }) = _ExecutionEntry;

  factory ExecutionEntry.fromJson(Map<String, dynamic> json) =>
      _$ExecutionEntryFromJson(json);
}

@freezed
class ServerInfo with _$ServerInfo {
  const factory ServerInfo({
    String? name,
    String? version,
    String? title,
    String? description,
    String? websiteUrl,
    List<String>? icons,
    String? instructions,
  }) = _ServerInfo;

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);
}
```

## Provider Integration

### lib/features/mcp/presentation/providers/mcp_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/mcp_client_service.dart';
import '../../data/services/connection_manager.dart';
import '../../data/services/tool_executor.dart';
import '../../data/models/mcp_models.dart';

// MCP Client Provider
final mcpClientProvider = Provider<MCPClientService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MCPClientService(apiService);
});

// Connection Manager Provider
final connectionManagerProvider = Provider<ConnectionManager>((ref) {
  final mcpClient = ref.watch(mcpClientProvider);
  return ConnectionManager(mcpClient, ref);
});

// Tool Executor Provider
final toolExecutorProvider = Provider<ToolExecutor>((ref) {
  final mcpClient = ref.watch(mcpClientProvider);
  final connectionManager = ref.watch(connectionManagerProvider);
  return ToolExecutor(mcpClient, connectionManager, ref);
});

// Current Execution Provider
@riverpod
class CurrentExecution extends _$CurrentExecution {
  @override
  AsyncValue<ToolExecutionResult?> build() => const AsyncValue.data(null);

  Future<void> executeTool({
    required String serverId,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final executor = ref.read(toolExecutorProvider);
      return await executor.execute(
        serverId: serverId,
        toolName: toolName,
        arguments: arguments,
      );
    });
  }

  void clearResult() {
    state = const AsyncValue.data(null);
  }
}
```

## Usage Example

### lib/features/tools/presentation/widgets/tool_executor.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/providers.dart';
import '../../../mcp/presentation/providers/mcp_provider.dart';
import '../../../mcp/data/models/mcp_models.dart';
import '../../../../shared/widgets/json_editor.dart';

class ToolExecutor extends ConsumerStatefulWidget {
  final ToolSchema tool;
  final String serverId;
  final bool isExecuting;

  const ToolExecutor({
    super.key,
    required this.tool,
    required this.serverId,
    required this.isExecuting,
  });

  @override
  ConsumerState<ToolExecutor> createState() => _ToolExecutorState();
}

class _ToolExecutorState extends ConsumerState<ToolExecutor> {
  final _argumentsController = TextEditingController();
  bool _isValidJson = true;

  @override
  void initState() {
    super.initState();
    // Load default arguments
    final executor = ref.read(toolExecutorProvider);
    final suggestions = executor.getArgumentSuggestions(widget.tool);
    if (suggestions.isNotEmpty) {
      _argumentsController.text = jsonEncode(suggestions);
    }
  }

  @override
  void dispose() {
    _argumentsController.dispose();
    super.dispose();
  }

  Future<void> _executeTool() async {
    try {
      final arguments = jsonDecode(_argumentsController.text) as Map<String, dynamic>;
      
      await ref.read(currentExecutionProvider.notifier).executeTool(
        serverId: widget.serverId,
        toolName: widget.tool.name,
        arguments: arguments,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final executionState = ref.watch(currentExecutionProvider);

    return Column(
      children: [
        // Arguments Editor
        Expanded(
          flex: 2,
          child: JsonEditor(
            initialValue: _argumentsController.text,
            onChanged: (value) {
              try {
                jsonDecode(value);
                setState(() => _isValidJson = true);
              } catch (e) {
                setState(() => _isValidJson = false);
              }
            },
          ),
        ),

        // Execute Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: widget.isExecuting || !_isValidJson ? null : _executeTool,
            icon: widget.isExecuting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(widget.isExecuting ? 'Executing...' : 'Execute'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),

        // Results
        Expanded(
          flex: 3,
          child: executionState.when(
            data: (result) {
              if (result == null) {
                return const Center(child: Text('Execute a tool to see results'));
              }
              
              return JsonViewer(data: {
                'success': result.success,
                'content': result.content,
                if (result.error != null) 'error': result.error,
              });
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          ),
        ),
      ],
    );
  }
}
```

## Auto-Reconnect Logic

### lib/features/mcp/data/services/auto_reconnect_service.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/providers.dart';
import 'connection_manager.dart';

class AutoReconnectService {
  final ConnectionManager _connectionManager;
  final Ref _ref;

  AutoReconnectService(this._connectionManager, this._ref);

  // Auto-reconnect to all saved servers on app start
  Future<void> reconnectAll() async {
    final servers = _ref.read(serversProvider);
    
    for (final server in servers) {
      try {
        await _connectionManager.connectWithAutoReconnect(
          serverId: server.id,
          serverName: server.name,
          url: server.url,
          transport: server.transport ?? 'http',
          auth: server.auth,
        );
      } catch (e) {
        // Log error but continue with other servers
        print('Failed to reconnect to ${server.name}: $e');
      }
    }
  }

  // Reconnect specific server
  Future<bool> reconnectServer(String serverId) async {
    final servers = _ref.read(serversProvider);
    final server = servers.firstWhere(
      (s) => s.id == serverId,
      orElse: () => null as ServerConfig,
    );

    if (server == null) return false;

    try {
      final result = await _connectionManager.connectWithAutoReconnect(
        serverId: server.id,
        serverName: server.name,
        url: server.url,
        transport: server.transport ?? 'http',
        auth: server.auth,
      );
      return result.success;
    } catch (e) {
      return false;
    }
  }
}

final autoReconnectServiceProvider = Provider<AutoReconnectService>((ref) {
  final connectionManager = ref.watch(connectionManagerProvider);
  return AutoReconnectService(connectionManager, ref);
});
```

## Testing

### test/features/mcp/mcp_client_service_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:modelman_flutter/features/mcp/data/services/mcp_client_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MCPClientService mcpClient;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    mcpClient = MCPClientService(mockApiService);
  });

  group('MCPClientService', () {
    test('autoDetectServer returns ServerConfig', () async {
      when(mockApiService.autoDetectServer(any)).thenAnswer(
        (_) async => {
          'name': 'Test Server',
          'transport': 'http',
        },
      );

      final result = await mcpClient.autoDetectServer('http://test.com');
      
      expect(result.name, 'Test Server');
      expect(result.transport, 'http');
    });

    test('executeTool returns ToolExecutionResult', () async {
      when(mockApiService.executeTool(
        serverId: anyNamed('serverId'),
        toolName: anyNamed('toolName'),
        arguments: anyNamed('arguments'),
      )).thenAnswer(
        (_) async => {
          'success': true,
          'content': {'result': 'test'},
        },
      );

      final result = await mcpClient.executeTool(
        serverId: 'server-1',
        toolName: 'test_tool',
        arguments: {'param': 'value'},
      );
      
      expect(result.success, true);
    });
  });
}
```

## Migration Checklist

- [ ] Implement MCPClientService
- [ ] Implement ConnectionManager
- [ ] Implement ToolExecutor
- [ ] Implement StreamingExecutor
- [ ] Implement AutoReconnectService
- [ ] Create data models with code generation
- [ ] Set up providers for MCP services
- [ ] Implement error handling
- [ ] Add logging for MCP operations
- [ ] Test connection flow
- [ ] Test tool execution
- [ ] Test auto-reconnect logic
- [ ] Test error scenarios

## Next Steps

1. Review `07-chat-hybrid-interface.md` for chat interface implementation
2. Implement tool argument validation with JSON Schema
3. Add streaming support for long-running tools
4. Implement tool execution history with filtering
