# State Management with Riverpod

## Overview

This document details the state management architecture using Riverpod, mapping from the current Zustand-based React state management to Flutter's Riverpod.

## Architecture Comparison

```
┌─────────────────────────────────────────────────────────────┐
│                   React Zustand Architecture                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │  React UI    │◄────►│  Zustand     │◄────►│ localStorage │ │
│  │  Components  │      │  Store       │      │ Persistence │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                       │                      │     │
│         │ useAppStore()          │ persist middleware   │     │
│         ▼                       ▼                      ▼     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Single Store (appStore.ts)                 │ │
│  │  - servers: ServerConfig[]                              │ │
│  │  - selectedServerId: string | null                      │ │
│  │  - selectedToolName: string | null                       │ │
│  │  - tools: Record<string, ToolSchema[]>                  │ │
│  │  - history: ExecutionHistory[]                          │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   Flutter Riverpod Architecture                │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │  Flutter UI  │◄────►│  Riverpod    │◄────►│  Hydrated   │ │
│  │  Widgets     │      │  Providers   │      │  Storage    │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                       │                      │     │
│         │ ref.watch(provider)   │ persist              │     │
│         ▼                       ▼                      ▼     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Multiple Providers (modular)              │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐   │ │
│  │  │ servers     │  │ selectedTool │  │ history    │   │ │
│  │  │ Provider    │  │ Provider     │  │ Provider   │   │ │
│  │  └──────────────┘  └──────────────┘  └────────────┘   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Zustand to Riverpod Mapping

### Current Zustand Store (src/stores/appStore.ts)

```typescript
interface AppStore extends AppState {
  // Server actions
  addServer: (server) => void;
  removeServer: (serverId) => void;
  updateServer: (serverId, updates) => void;
  setSelectedServer: (serverId) => void;
  
  // Tool actions
  setTools: (serverId, tools) => void;
  setSelectedTool: (toolName) => void;
  
  // Execution actions
  addToHistory: (entry) => void;
  clearHistory: () => void;
  setToolExecuting: (serverId, toolName, executing) => void;
  
  // UI actions
  setSearchQuery: (query) => void;
}
```

### Target Riverpod Structure

```dart
// lib/core/state/providers.dart

// ┌─────────────────────────────────────────────────────────────┐
// │ SERVER STATE                                                  │
// └─────────────────────────────────────────────────────────────┘

@riverpod
class Servers extends _$Servers {
  @override
  List<ServerConfig> build() {
    // Load from storage on initialization
    _loadFromStorage();
    return [];
  }

  Future<void> _loadFromStorage() async {
    final storage = ref.read(localStorageServiceProvider);
    final servers = await storage.getServerConfigs();
    state = servers.map((s) => ServerConfig.fromJson(s)).toList();
  }

  void addServer(ServerConfig server) {
    state = [...state, server];
    _saveToStorage();
  }

  void removeServer(String serverId) {
    state = state.where((s) => s.id != serverId).toList();
    _saveToStorage();
  }

  void updateServer(String serverId, Partial<ServerConfig> updates) {
    state = state.map((s) {
      if (s.id == serverId) {
        return s.copyWith(updates);
      }
      return s;
    }).toList();
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setServerConfigs(
      state.map((s) => s.toJson()).toList(),
    );
  }
}

@riverpod
class SelectedServer extends _$SelectedServer {
  @override
  String? build() => null;

  void setServer(String? serverId) {
    state = serverId;
  }
}

// ┌─────────────────────────────────────────────────────────────┐
// │ TOOL STATE                                                    │
// └─────────────────────────────────────────────────────────────┘

@riverpod
class Tools extends _$Tools {
  @override
  Map<String, List<ToolSchema>> build() => {};

  void setTools(String serverId, List<ToolSchema> tools) {
    state = {...state, serverId: tools};
  }

  void clearTools(String serverId) {
    final newState = Map<String, List<ToolSchema>>.from(state);
    newState.remove(serverId);
    state = newState;
  }

  List<ToolSchema> getToolsForServer(String serverId) {
    return state[serverId] ?? [];
  }
}

@riverpod
class SelectedTool extends _$SelectedTool {
  @override
  String? build() => null;

  void setTool(String? toolName) {
    state = toolName;
  }
}

// ┌─────────────────────────────────────────────────────────────┐
// │ EXECUTION STATE                                               │
// └─────────────────────────────────────────────────────────────┘

@riverpod
class ExecutionHistory extends _$ExecutionHistory {
  @override
  List<ExecutionEntry> build() => [];

  void addEntry(ExecutionEntry entry) {
    state = [entry, ...state].take(100).toList();
  }

  void clearHistory() {
    state = [];
  }
}

@riverpod
class ExecutingTools extends _$ExecutingTools {
  @override
  Set<String> build() => {};

  void setExecuting(String serverId, String toolName, bool executing) {
    final toolKey = '$serverId:$toolName';
    if (executing) {
      state = {...state, toolKey};
    } else {
      state = state.where((key) => key != toolKey).toSet();
    }
  }

  bool isExecuting(String serverId, String toolName) {
    return state.contains('$serverId:$toolName');
  }
}

// ┌─────────────────────────────────────────────────────────────┐
// │ UI STATE                                                       │
// └─────────────────────────────────────────────────────────────┘

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

// ┌─────────────────────────────────────────────────────────────┐
// │ THEME STATE                                                   │
// └─────────────────────────────────────────────────────────────┘

@riverpod
class ThemeMode extends _$ThemeMode {
  @override
  AppThemeMode build() => AppThemeMode.system;

  void setThemeMode(AppThemeMode mode) {
    state = mode;
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setIsDarkMode(state == AppThemeMode.dark);
  }
}
```

## Computed Providers (Derived State)

### lib/core/state/computed_providers.dart

```dart
// ┌─────────────────────────────────────────────────────────────┐
// │ COMPUTED PROVIDERS - Derived from other providers            │
// └─────────────────────────────────────────────────────────────┘

// Get currently selected server object
@riverpod
ServerConfig? currentServer(CurrentServerRef ref) {
  final servers = ref.watch(serversProvider);
  final selectedId = ref.watch(selectedServerProvider);
  return servers.firstWhere(
    (s) => s.id == selectedId,
    orElse: () => null as ServerConfig,
  );
}

// Get tools for selected server
@riverpod
List<ToolSchema> currentTools(CurrentToolsRef ref) {
  final selectedId = ref.watch(selectedServerProvider);
  final allTools = ref.watch(toolsProvider);
  return allTools[selectedId] ?? [];
}

// Filter tools based on search query
@riverpod
List<ToolSchema> filteredTools(FilteredToolsRef ref) {
  final tools = ref.watch(currentToolsProvider);
  final query = ref.watch(searchQueryProvider);
  
  if (query.isEmpty) return tools;
  
  final lowerQuery = query.toLowerCase();
  return tools.where((tool) {
    return tool.name?.toLowerCase().contains(lowerQuery) == true ||
           tool.description?.toLowerCase().contains(lowerQuery) == true;
  }).toList();
}

// Get connection status for selected server
@riverpod
bool isServerConnected(IsServerConnectedRef ref) {
  final server = ref.watch(currentServerProvider);
  return server?.connected ?? false;
}
```

## Async State Management

### lib/features/servers/presentation/providers/connection_provider.dart

```dart
// ┌─────────────────────────────────────────────────────────────┐
// │ ASYNC STATE - For API calls and operations                    │
// └─────────────────────────────────────────────────────────────┘

@riverpod
class ConnectionState extends _$ConnectionState {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> connectToServer({
    required String serverId,
    required String url,
    required String transport,
    AuthConfig? auth,
  }) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(serverRepositoryProvider);
      await repository.connectToServer(
        serverId: serverId,
        serverName: '', // Will be set from server config
        url: url,
        transport: transport,
        auth: auth,
      );
      
      // Update server state
      ref.read(serversProvider.notifier).updateServer(
        serverId,
        const ServerConfig(connected: true),
      );
    });
  }

  Future<void> disconnectFromServer(String serverId) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(serverRepositoryProvider);
      await repository.disconnectFromServer(serverId);
      
      // Update server state
      ref.read(serversProvider.notifier).updateServer(
        serverId,
        const ServerConfig(connected: false),
      );
    });
  }
}
```

## Persistence with Hydrated Riverpod

### lib/core/state/hydration.dart

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hydrated_riverpod/hydrated_riverpod.dart';

// Enable hydration for state persistence
@riverpod
Future<ProviderContainer> initializeHydratedContainer(
  InitializeHydratedContainerRef ref,
) async {
  final container = ProviderContainer();
  
  // Initialize storage
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  
  return container;
}

// Hydrated version of servers provider
@riverpod
class HydratedServers extends _$HydratedServers {
  @override
  List<ServerConfig> build() {
    // Restore from hydration
    return [];
  }

  @override
  List<ServerConfig>? fromJson(Map<String, dynamic> json) {
    final serversJson = json['servers'] as List?;
    if (serversJson == null) return null;
    return serversJson
        .map((e) => ServerConfig.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Map<String, dynamic>? toJson(List<ServerConfig> state) {
    return {
      'servers': state.map((s) => s.toJson()).toList(),
    };
  }
}
```

## Usage in Widgets

### lib/features/servers/presentation/pages/servers_page.dart

```dart
class ServersPage extends ConsumerWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state
    final servers = ref.watch(serversProvider);
    final selectedServerId = ref.watch(selectedServerProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final connectionState = ref.watch(connectionStateProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (query) {
              ref.read(searchQueryProvider.notifier).setQuery(query);
            },
          ),

          // Server list
          Expanded(
            child: servers.when(
              data: (serverList) {
                return ListView.builder(
                  itemCount: serverList.length,
                  itemBuilder: (context, index) {
                    final server = serverList[index];
                    final isSelected = server.id == selectedServerId;
                    
                    return ServerTile(
                      server: server,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedServerProvider.notifier).setServer(server.id);
                      },
                      onConnect: () {
                        ref.read(connectionStateProvider.notifier).connectToServer(
                          serverId: server.id,
                          url: server.url,
                          transport: server.transport ?? 'http',
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add server modal
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddServerModal(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## State Management Best Practices

### 1. Separation of Concerns

```
┌─────────────────────────────────────────────────────────────┐
│                     STATE LAYERING                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ UI LAYER (Widgets)                                    │   │
│  │ - Only display state                                  │   │
│  │ - Trigger actions via providers                       │   │
│  └──────────────────────────────────────────────────────┘   │
│                          ▲                                     │
│                          │                                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ PRESENTATION PROVIDERS                               │   │
│  │ - Combine multiple providers                          │   │
│  │ - Format data for UI                                  │   │
│  └──────────────────────────────────────────────────────┘   │
│                          ▲                                     │
│                          │                                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ FEATURE PROVIDERS                                    │   │
│  │ - Domain-specific state                              │   │
│  │ - Business logic                                     │   │
│  └──────────────────────────────────────────────────────┘   │
│                          ▲                                     │
│                          │                                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ DATA PROVIDERS                                       │   │
│  │ - API calls                                          │   │
│  │ - Repository access                                  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### 2. Provider Organization

```dart
// lib/core/state/providers.dart - Core app state
// lib/features/*/presentation/providers/* - Feature-specific state
// lib/core/state/computed_providers.dart - Derived state
```

### 3. State Persistence Strategy

```dart
// Simple values: SharedPreferences
// Complex objects: Hive/SQLite
// UI state: Hydrated Riverpod
// Auth tokens: Secure Storage
```

## Testing State Management

### test/core/state/providers_test.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoot_flutter/core/state/providers.dart';

void main() {
  test('ServersProvider - addServer', () {
    final container = ProviderContainer();
    
    container.read(serversProvider.notifier).addServer(
      const ServerConfig(
        id: '1',
        name: 'Test Server',
        url: 'http://test.com',
      ),
    );
    
    final servers = container.read(serversProvider);
    expect(servers.length, 1);
    expect(servers.first.name, 'Test Server');
  });

  test('SelectedServerProvider - setServer', () {
    final container = ProviderContainer();
    
    container.read(selectedServerProvider.notifier).setServer('server-123');
    
    final selectedId = container.read(selectedServerProvider);
    expect(selectedId, 'server-123');
  });
}
```

## Migration Checklist

- [ ] Create base providers (servers, tools, history)
- [ ] Create async providers for API operations
- [ ] Create computed providers for derived state
- [ ] Set up hydration for persistence
- [ ] Update all widgets to use Riverpod
- [ ] Remove any remaining React state patterns
- [ ] Add unit tests for all providers
- [ ] Test state persistence across app restarts

## Next Steps

1. Review `04-authentication-oauth.md` for OAuth implementation
2. Implement providers for each feature
3. Add state persistence with hydration
4. Create comprehensive tests for state management
