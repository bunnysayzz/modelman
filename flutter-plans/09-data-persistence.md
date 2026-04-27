# Data Persistence

## Overview

This document details the data persistence strategy for the Flutter app, mapping from React's localStorage and Zustand persist to Flutter's storage solutions.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                   Data Persistence Architecture                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │   Flutter    │      │  Storage     │      │   Backend   │ │
│  │   App        │◄────►│  Layer       │◄────►│  Database   │ │
│  │              │      │              │      │  (SQLite)   │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                       │                      │     │
│         │                       │                      │     │
│         ▼                       ▼                      ▼     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Storage Solutions                          │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐   │ │
│  │  │  Shared      │  │  Secure      │  │   Hive/     │   │ │
│  │  │  Preferences │  │  Storage     │  │   SQLite    │   │ │
│  │  │  (Simple)    │  │  (Auth)      │  │  (Complex)  │   │ │
│  │  └──────────────┘  └──────────────┘  └────────────┘   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Storage Strategy Mapping

| React Storage | Flutter Storage | Use Case |
|----------------|------------------|----------|
| localStorage | SharedPreferences | Simple key-value (theme, settings) |
| Zustand Persist | Hive/SQLite | Complex state (servers, tools, history) |
| Session Storage | In-memory | Temporary data (current session) |
| Backend SQLite | Backend SQLite (unchanged) | OAuth tokens, server configs |

## SharedPreferences Service

### lib/core/storage/shared_preferences_service.dart

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SharedPreferencesService {
  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  // Theme
  Future<String?> getThemeName() async {
    return _prefs.getString('theme_name');
  }

  Future<void> setThemeName(String themeName) async {
    await _prefs.setString('theme_name', themeName);
  }

  Future<String?> getThemeMode() async {
    return _prefs.getString('theme_mode');
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString('theme_mode', mode);
  }

  // User ID
  Future<String?> getUserId() async {
    return _prefs.getString('user_id');
  }

  Future<void> setUserId(String userId) async {
    await _prefs.setString('user_id', userId);
  }

  // Tool Filter Config
  Future<String?> getToolFilterConfig() async {
    return _prefs.getString('tool_filter_config');
  }

  Future<void> setToolFilterConfig(String config) async {
    await _prefs.setString('tool_filter_config', config);
  }

  // UI Preferences
  Future<bool?> getSidebarCollapsed() async {
    return _prefs.getBool('sidebar_collapsed');
  }

  Future<void> setSidebarCollapsed(bool collapsed) async {
    await _prefs.setBool('sidebar_collapsed', collapsed);
  }

  // Clear all simple preferences
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>((ref) {
  throw UnimplementedError('Must be initialized in main()');
});

// Initialize in main.dart
Future<SharedPreferencesService> initSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return SharedPreferencesService(prefs);
}
```

## Secure Storage Service

### lib/core/storage/secure_storage_service.dart

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Auth Token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> setAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // OAuth Tokens
  Future<String?> getOAuthToken(String serverId) async {
    return await _storage.read(key: 'oauth_token_$serverId');
  }

  Future<void> setOAuthToken(String serverId, String token) async {
    await _storage.write(key: 'oauth_token_$serverId', value: token);
  }

  Future<void> deleteOAuthToken(String serverId) async {
    await _storage.delete(key: 'oauth_token_$serverId');
  }

  // API Keys
  Future<String?> getApiKey(String serverId) async {
    return await _storage.read(key: 'api_key_$serverId');
  }

  Future<void> setApiKey(String serverId, String apiKey) async {
    await _storage.write(key: 'api_key_$serverId', value: apiKey);
  }

  Future<void> deleteApiKey(String serverId) async {
    await _storage.delete(key: 'api_key_$serverId');
  }

  // Clear all secure data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(
    const FlutterSecureStorage(
      aOptions: AndroidSecureOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    ),
  );
});
```

## Hive Database Service

### lib/core/storage/hive_service.dart

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/servers/data/models/server_model.dart';

class HiveService {
  static const String _serversBox = 'servers';
  static const String _toolsBox = 'tools';
  static const String _historyBox = 'history';
  static const String _faviconCacheBox = 'favicon_cache';

  Future<void> init() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    
    await Hive.initFlutter(appDocDir.path);
    
    // Register adapters
    Hive.registerAdapter(ServerConfigAdapter());
    Hive.registerAdapter(ToolSchemaAdapter());
    Hive.registerAdapter(AuthConfigAdapter());
    Hive.registerAdapter(ExecutionEntryAdapter());

    // Open boxes
    await Hive.openBox(_serversBox);
    await Hive.openBox(_toolsBox);
    await Hive.openBox(_historyBox);
    await Hive.openBox(_faviconCacheBox);
  }

  // Servers
  Future<List<ServerConfig>> getServers() async {
    final box = Hive.box(_serversBox);
    return box.values.toList().cast<ServerConfig>();
  }

  Future<void> saveServers(List<ServerConfig> servers) async {
    final box = Hive.box(_serversBox);
    await box.clear();
    await box.putAll(Map.fromIterable(
      servers,
      key: (s) => s.id,
      value: (s) => s,
    ));
  }

  Future<void> addServer(ServerConfig server) async {
    final box = Hive.box(_serversBox);
    await box.put(server.id, server);
  }

  Future<void> removeServer(String serverId) async {
    final box = Hive.box(_serversBox);
    await box.delete(serverId);
  }

  // Tools
  Future<Map<String, List<ToolSchema>>> getTools() async {
    final box = Hive.box(_toolsBox);
    final tools = <String, List<ToolSchema>>{};
    
    for (final key in box.keys) {
      final toolList = box.get(key) as List<ToolSchema>;
      tools[key.toString()] = toolList;
    }
    
    return tools;
  }

  Future<void> saveTools(String serverId, List<ToolSchema> tools) async {
    final box = Hive.box(_toolsBox);
    await box.put(serverId, tools);
  }

  Future<void> removeTools(String serverId) async {
    final box = Hive.box(_toolsBox);
    await box.delete(serverId);
  }

  // Execution History
  Future<List<ExecutionEntry>> getHistory() async {
    final box = Hive.box(_historyBox);
    return box.values.toList().cast<ExecutionEntry>();
  }

  Future<void> addHistoryEntry(ExecutionEntry entry) async {
    final box = Hive.box(_historyBox);
    await box.add(entry);
    
    // Keep only last 100 entries
    if (box.length > 100) {
      await box.deleteAt(0);
    }
  }

  Future<void> clearHistory() async {
    final box = Hive.box(_historyBox);
    await box.clear();
  }

  // Favicon Cache
  Future<String?> getFavicon(String serverUrl) async {
    final box = Hive.box(_faviconCacheBox);
    return box.get(serverUrl) as String?;
  }

  Future<void> setFavicon(String serverUrl, String faviconUrl) async {
    final box = Hive.box(_faviconCacheBox);
    await box.put(serverUrl, faviconUrl);
  }

  // Close all boxes
  Future<void> close() async {
    await Hive.close();
  }
}

final hiveServiceProvider = Provider<HiveService>((ref) {
  final service = HiveService();
  ref.onDispose(() => service.close());
  return service;
});
```

## Hive Type Adapters

### lib/core/storage/adapters/server_adapter.dart

```dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/servers/data/models/server_model.dart';

part 'server_adapter.g.dart';

@HiveType(typeId: 0)
class ServerConfigAdapter extends TypeAdapter<ServerConfig> {
  @override
  final int typeId = 0;

  @override
  ServerConfig read(BinaryReader reader) {
    return ServerConfig(
      id: reader.readString(),
      name: reader.readString(),
      url: reader.readString(),
      transport: reader.readString(),
      lastConnected: reader.readDateTime(),
      faviconUrl: reader.readString(),
      connected: reader.readBool(),
      error: reader.readString(),
      auth: reader.read() as AuthConfig?,
    );
  }

  @override
  void write(BinaryWriter writer, ServerConfig obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.url);
    writer.writeString(obj.transport ?? '');
    writer.writeDateTime(obj.lastConnected ?? DateTime.now());
    writer.writeString(obj.faviconUrl ?? '');
    writer.writeBool(obj.connected);
    writer.writeString(obj.error ?? '');
    writer.write(obj.auth);
  }
}
```

### lib/core/storage/adapters/tool_adapter.dart

```dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/servers/data/models/server_model.dart';

part 'tool_adapter.g.dart';

@HiveType(typeId: 1)
class ToolSchemaAdapter extends TypeAdapter<ToolSchema> {
  @override
  final int typeId = 1;

  @override
  ToolSchema read(BinaryReader reader) {
    return ToolSchema(
      name: reader.readString(),
      description: reader.readString(),
      inputSchema: reader.read() as Map<String, dynamic>?,
    );
  }

  @override
  void write(BinaryWriter writer, ToolSchema obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.description ?? '');
    writer.write(obj.inputSchema);
  }
}
```

## SQLite Database Service (Alternative)

### lib/core/storage/sqlite_service.dart

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class SQLiteService {
  static const String _databaseName = 'hoot.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Servers table
    await db.execute('''
      CREATE TABLE servers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        transport TEXT,
        last_connected INTEGER,
        favicon_url TEXT,
        connected INTEGER DEFAULT 0,
        error TEXT
      )
    ''');

    // Tools table
    await db.execute('''
      CREATE TABLE tools (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        input_schema TEXT,
        FOREIGN KEY (server_id) REFERENCES servers (id) ON DELETE CASCADE
      )
    ''');

    // Execution history table
    await db.execute('''
      CREATE TABLE execution_history (
        id TEXT PRIMARY KEY,
        server_id TEXT NOT NULL,
        tool_name TEXT NOT NULL,
        arguments TEXT NOT NULL,
        result TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (server_id) REFERENCES servers (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_tools_server_id ON tools(server_id)');
    await db.execute('CREATE INDEX idx_history_timestamp ON execution_history(timestamp)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
    if (oldVersion < 2) {
      // Add new columns or tables
    }
  }

  // CRUD Operations for Servers
  Future<List<Map<String, dynamic>>> getServers() async {
    final db = await database;
    return await db.query('servers');
  }

  Future<void> insertServer(Map<String, dynamic> server) async {
    final db = await database;
    await db.insert('servers', server, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateServer(String id, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update('servers', updates, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteServer(String id) async {
    final db = await database;
    await db.delete('servers', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Operations for Tools
  Future<List<Map<String, dynamic>>> getTools(String serverId) async {
    final db = await database;
    return await db.query('tools', where: 'server_id = ?', whereArgs: [serverId]);
  }

  Future<void> insertTool(Map<String, dynamic> tool) async {
    final db = await database;
    await db.insert('tools', tool, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteTools(String serverId) async {
    final db = await database;
    await db.delete('tools', where: 'server_id = ?', whereArgs: [serverId]);
  }

  // CRUD Operations for Execution History
  Future<List<Map<String, dynamic>>> getHistory({int limit = 100}) async {
    final db = await database;
    return await db.query(
      'execution_history',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  Future<void> insertHistoryEntry(Map<String, dynamic> entry) async {
    final db = await database;
    await db.insert('execution_history', entry);
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('execution_history');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

final sqliteServiceProvider = Provider<SQLiteService>((ref) {
  final service = SQLiteService();
  ref.onDispose(() => service.close());
  return service;
});
```

## State Persistence with Hydrated Riverpod

### lib/core/state/hydration.dart

```dart
import 'package:hydrated_riverpod/hydrated_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/servers/data/models/server_model.dart';

// Hydrated servers provider
@riverpod
class HydratedServers extends _$HydratedServers {
  @override
  List<ServerConfig> build() => [];

  void addServer(ServerConfig server) {
    state = [...state, server];
  }

  void removeServer(String serverId) {
    state = state.where((s) => s.id != serverId).toList();
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

## Storage Service Integration

### lib/core/storage/storage_service.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_preferences_service.dart';
import 'secure_storage_service.dart';
import 'hive_service.dart';

class StorageService {
  final SharedPreferencesService _sharedPrefs;
  final SecureStorageService _secureStorage;
  final HiveService _hive;

  StorageService(
    this._sharedPrefs,
    this._secureStorage,
    this._hive,
  );

  // Unified interface for all storage operations
  Future<void> saveServerConfig(ServerConfig server) async {
    await _hive.addServer(server);
  }

  Future<List<ServerConfig>> loadServerConfigs() async {
    return await _hive.getServers();
  }

  Future<void> saveAuthToken(String token) async {
    await _secureStorage.setAuthToken(token);
  }

  Future<String?> loadAuthToken() async {
    return await _secureStorage.getAuthToken();
  }

  Future<void> saveTheme(String themeName) async {
    await _sharedPrefs.setThemeName(themeName);
  }

  Future<String?> loadTheme() async {
    return await _sharedPrefs.getThemeName();
  }

  Future<void> clearAllData() async {
    await _sharedPrefs.clearAll();
    await _secureStorage.clearAll();
    await _hive.close();
    await Hive.deleteFromDisk();
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final hive = ref.watch(hiveServiceProvider);
  
  return StorageService(sharedPrefs, secureStorage, hive);
});
```

## Initialization

### lib/main.dart (Updated)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'core/storage/shared_preferences_service.dart';
import 'core/storage/hive_service.dart';
import 'core/storage/sqlite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await _initializeStorage();
  
  runApp(
    const ProviderScope(
      child: HootApp(),
    ),
  );
}

Future<void> _initializeStorage() async {
  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize SQLite if needed
  final sqliteService = SQLiteService();
  await sqliteService.database; // Trigger initialization
}
```

## Data Migration

### lib/core/storage/migration_service.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hive_service.dart';
import 'sqlite_service.dart';

class MigrationService {
  final HiveService _hive;
  final SQLiteService _sqlite;

  MigrationService(this._hive, this._sqlite);

  // Migrate from Hive to SQLite (if needed)
  Future<void> migrateHiveToSQLite() async {
    final servers = await _hive.getServers();
    
    for (final server in servers) {
      await _sqlite.insertServer(server.toJson());
    }
  }

  // Clear all data (for logout/reset)
  Future<void> clearAllData() async {
    await _hive.close();
    await Hive.deleteFromDisk();
    await _sqlite.close();
    await deleteDatabase(await getDatabasesPath() + '/hoot.db');
  }
}

final migrationServiceProvider = Provider<MigrationService>((ref) {
  final hive = ref.watch(hiveServiceProvider);
  final sqlite = ref.watch(sqliteServiceProvider);
  return MigrationService(hive, sqlite);
});
```

## Testing

### test/core/storage/hive_service_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hoot_flutter/core/storage/hive_service.dart';
import 'package:hoot_flutter/features/servers/data/models/server_model.dart';

void main() {
  group('HiveService', () {
    late HiveService hiveService;

    setUp(() async {
      await Hive.initFlutter();
      await Hive.openBox('test_servers');
      hiveService = HiveService();
    });

    tearDown(() async {
      await Hive.deleteBox('test_servers');
    });

    test('save and retrieve server', () async {
      final server = ServerConfig(
        id: 'test-1',
        name: 'Test Server',
        url: 'http://test.com',
      );

      await hiveService.addServer(server);
      final servers = await hiveService.getServers();

      expect(servers.length, 1);
      expect(servers.first.id, 'test-1');
    });
  });
}
```

## Migration Checklist

- [ ] Implement SharedPreferencesService
- [ ] Implement SecureStorageService
- [ ] Implement HiveService
- [ ] Create Hive type adapters
- [ ] Implement SQLiteService (alternative)
- [ ] Set up Hydrated Riverpod
- [ ] Create unified StorageService
- [ ] Implement storage initialization
- [ ] Add data migration service
- [ ] Test all storage operations
- [ ] Test data persistence across app restarts
- [ ] Test secure storage on iOS and Android

## Next Steps

1. Review `10-platform-specific.md` for platform-specific implementations
2. Implement data backup/restore functionality
3. Add data export/import features
4. Implement data versioning for migrations
