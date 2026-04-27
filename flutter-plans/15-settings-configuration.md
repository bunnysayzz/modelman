# Settings & Configuration Management

## Overview

This document details the comprehensive settings and configuration system for the Flutter app, allowing users to customize their experience similar to Postman.

## Settings Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Settings Architecture                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │   Settings   │◄────►│  Config      │◄────►│  Storage    │ │
│  │   UI         │      │  Service     │      │  Layer      │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                       │                      │     │
│         │                       │                      │     │
│         ▼                       ▼                      ▼     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Configuration Categories                   │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐   │ │
│  │  │ General      │  │  Appearance  │  │  Network    │   │ │
│  │  └──────────────┘  └──────────────┘  └────────────┘   │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐   │ │
│  │  │ Data         │  │  Security    │  │  Advanced   │   │ │
│  │  └──────────────┘  └──────────────┘  └────────────┘   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Settings Data Model

### lib/features/settings/data/models/settings_model.dart

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    // General Settings
    @JsonKey(default: '') String userId,
    @JsonKey(default: 'en') String language,
    @JsonKey(default: false) bool enableNotifications,
    @JsonKey(default: true) bool autoReconnectServers,
    @JsonKey(default: 30) int connectionTimeout,
    @JsonKey(default: 60) int requestTimeout,
    
    // Appearance Settings
    @JsonKey(default: 'duotone_dark') String themeName,
    @JsonKey(default: 'system') String themeMode,
    @JsonKey(default: 16) double fontSize,
    @JsonKey(default: true) bool enableAnimations,
    @JsonKey(default: false) bool compactMode,
    
    // Network Settings
    @JsonKey(default: true) bool enableProxy,
    @JsonKey(default: '') String proxyUrl,
    @JsonKey(default: '') String proxyUsername,
    @JsonKey(default: '') String proxyPassword,
    @JsonKey(default: 10) int maxConcurrentRequests,
    @JsonKey(default: true) bool enableHttp2,
    
    // Data Settings
    @JsonKey(default: true) bool enableDataPersistence,
    @JsonKey(default: true) bool enableHistory,
    @JsonKey(default: 100) int maxHistoryEntries,
    @JsonKey(default: true) bool enableCache,
    @JsonKey(default: 50) int maxCacheSize, // MB
    @JsonKey(default: true) bool clearCacheOnExit,
    
    // Security Settings
    @JsonKey(default: true) bool enableAutoLock,
    @JsonKey(default: 300) int autoLockTimeout, // seconds
    @JsonKey(default: true) bool enableBiometricAuth,
    @JsonKey(default: true) bool secureStorage,
    @JsonKey(default: true) bool enableTwoFactorAuth,
    
    // Advanced Settings
    @JsonKey(default: false) bool debugMode,
    @JsonKey(default: false) bool verboseLogging,
    @JsonKey(default: 'info') String logLevel,
    @JsonKey(default: true) bool enableTelemetry,
    @JsonKey(default: true) bool enableCrashReporting,
    @JsonKey(default: '') String customBackendUrl,
    
    // Workspace Settings
    @JsonKey(default: '') String currentWorkspaceId,
    @JsonKey(default: 'My Workspace') String workspaceName,
    @JsonKey(default: true) bool syncWithCloud,
    @JsonKey(default: '') String cloudSyncUrl,
    
    // Tool Filter Settings
    @JsonKey(default: true) bool enableToolFilter,
    @JsonKey(default: '') String aiProvider,
    @JsonKey(default: '') String aiApiKey,
    @JsonKey(default: '') String aiModel,
    
    // Editor Settings
    @JsonKey(default: 'monokai') String editorTheme,
    @JsonKey(default: true) bool enableSyntaxHighlighting,
    @JsonKey(default: true) bool enableAutoComplete,
    @JsonKey(default: 4) int tabSize,
    @JsonKey(default: true) bool showLineNumbers,
    @JsonKey(default: true) bool wordWrap,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}

@freezed
class ProxyConfig with _$ProxyConfig {
  const factory ProxyConfig({
    required bool enabled,
    required String host,
    required int port,
    String? username,
    String? password,
  }) = _ProxyConfig;

  factory ProxyConfig.fromJson(Map<String, dynamic> json) =>
      _$ProxyConfigFromJson(json);
}

@freezed
class WorkspaceConfig with _$WorkspaceConfig {
  const factory WorkspaceConfig({
    required String id,
    required String name,
    @JsonKey(default: false) bool isPersonal,
    @JsonKey(default: false) bool isShared,
    List<String>? members,
    @JsonKey(default: '') String description,
  }) = _WorkspaceConfig;

  factory WorkspaceConfig.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceConfigFromJson(json);
}
```

## Settings Service

### lib/features/settings/data/services/settings_service.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsService {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // Get all settings
  AppSettings getSettings() {
    return AppSettings(
      userId: _prefs.getString('user_id') ?? '',
      language: _prefs.getString('language') ?? 'en',
      enableNotifications: _prefs.getBool('enable_notifications') ?? false,
      autoReconnectServers: _prefs.getBool('auto_reconnect_servers') ?? true,
      connectionTimeout: _prefs.getInt('connection_timeout') ?? 30,
      requestTimeout: _prefs.getInt('request_timeout') ?? 60,
      themeName: _prefs.getString('theme_name') ?? 'duotone_dark',
      themeMode: _prefs.getString('theme_mode') ?? 'system',
      fontSize: _prefs.getDouble('font_size') ?? 16,
      enableAnimations: _prefs.getBool('enable_animations') ?? true,
      compactMode: _prefs.getBool('compact_mode') ?? false,
      enableProxy: _prefs.getBool('enable_proxy') ?? false,
      proxyUrl: _prefs.getString('proxy_url') ?? '',
      proxyUsername: _prefs.getString('proxy_username') ?? '',
      proxyPassword: _prefs.getString('proxy_password') ?? '',
      maxConcurrentRequests: _prefs.getInt('max_concurrent_requests') ?? 10,
      enableHttp2: _prefs.getBool('enable_http2') ?? true,
      enableDataPersistence: _prefs.getBool('enable_data_persistence') ?? true,
      enableHistory: _prefs.getBool('enable_history') ?? true,
      maxHistoryEntries: _prefs.getInt('max_history_entries') ?? 100,
      enableCache: _prefs.getBool('enable_cache') ?? true,
      maxCacheSize: _prefs.getInt('max_cache_size') ?? 50,
      clearCacheOnExit: _prefs.getBool('clear_cache_on_exit') ?? true,
      enableAutoLock: _prefs.getBool('enable_auto_lock') ?? true,
      autoLockTimeout: _prefs.getInt('auto_lock_timeout') ?? 300,
      enableBiometricAuth: _prefs.getBool('enable_biometric_auth') ?? true,
      secureStorage: _prefs.getBool('secure_storage') ?? true,
      enableTwoFactorAuth: _prefs.getBool('enable_two_factor_auth') ?? true,
      debugMode: _prefs.getBool('debug_mode') ?? false,
      verboseLogging: _prefs.getBool('verbose_logging') ?? false,
      logLevel: _prefs.getString('log_level') ?? 'info',
      enableTelemetry: _prefs.getBool('enable_telemetry') ?? true,
      enableCrashReporting: _prefs.getBool('enable_crash_reporting') ?? true,
      customBackendUrl: _prefs.getString('custom_backend_url') ?? '',
      currentWorkspaceId: _prefs.getString('current_workspace_id') ?? '',
      workspaceName: _prefs.getString('workspace_name') ?? 'My Workspace',
      syncWithCloud: _prefs.getBool('sync_with_cloud') ?? true,
      cloudSyncUrl: _prefs.getString('cloud_sync_url') ?? '',
      enableToolFilter: _prefs.getBool('enable_tool_filter') ?? true,
      aiProvider: _prefs.getString('ai_provider') ?? '',
      aiApiKey: _prefs.getString('ai_api_key') ?? '',
      aiModel: _prefs.getString('ai_model') ?? '',
      editorTheme: _prefs.getString('editor_theme') ?? 'monokai',
      enableSyntaxHighlighting: _prefs.getBool('enable_syntax_highlighting') ?? true,
      enableAutoComplete: _prefs.getBool('enable_auto_complete') ?? true,
      tabSize: _prefs.getInt('tab_size') ?? 4,
      showLineNumbers: _prefs.getBool('show_line_numbers') ?? true,
      wordWrap: _prefs.getBool('word_wrap') ?? true,
    );
  }

  // Save all settings
  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString('user_id', settings.userId);
    await _prefs.setString('language', settings.language);
    await _prefs.setBool('enable_notifications', settings.enableNotifications);
    await _prefs.setBool('auto_reconnect_servers', settings.autoReconnectServers);
    await _prefs.setInt('connection_timeout', settings.connectionTimeout);
    await _prefs.setInt('request_timeout', settings.requestTimeout);
    await _prefs.setString('theme_name', settings.themeName);
    await _prefs.setString('theme_mode', settings.themeMode);
    await _prefs.setDouble('font_size', settings.fontSize);
    await _prefs.setBool('enable_animations', settings.enableAnimations);
    await _prefs.setBool('compact_mode', settings.compactMode);
    await _prefs.setBool('enable_proxy', settings.enableProxy);
    await _prefs.setString('proxy_url', settings.proxyUrl);
    await _prefs.setString('proxy_username', settings.proxyUsername);
    await _prefs.setString('proxy_password', settings.proxyPassword);
    await _prefs.setInt('max_concurrent_requests', settings.maxConcurrentRequests);
    await _prefs.setBool('enable_http2', settings.enableHttp2);
    await _prefs.setBool('enable_data_persistence', settings.enableDataPersistence);
    await _prefs.setBool('enable_history', settings.enableHistory);
    await _prefs.setInt('max_history_entries', settings.maxHistoryEntries);
    await _prefs.setBool('enable_cache', settings.enableCache);
    await _prefs.setInt('max_cache_size', settings.maxCacheSize);
    await _prefs.setBool('clear_cache_on_exit', settings.clearCacheOnExit);
    await _prefs.setBool('enable_auto_lock', settings.enableAutoLock);
    await _prefs.setInt('auto_lock_timeout', settings.autoLockTimeout);
    await _prefs.setBool('enable_biometric_auth', settings.enableBiometricAuth);
    await _prefs.setBool('secure_storage', settings.secureStorage);
    await _prefs.setBool('enable_two_factor_auth', settings.enableTwoFactorAuth);
    await _prefs.setBool('debug_mode', settings.debugMode);
    await _prefs.setBool('verbose_logging', settings.verboseLogging);
    await _prefs.setString('log_level', settings.logLevel);
    await _prefs.setBool('enable_telemetry', settings.enableTelemetry);
    await _prefs.setBool('enable_crash_reporting', settings.enableCrashReporting);
    await _prefs.setString('custom_backend_url', settings.customBackendUrl);
    await _prefs.setString('current_workspace_id', settings.currentWorkspaceId);
    await _prefs.setString('workspace_name', settings.workspaceName);
    await _prefs.setBool('sync_with_cloud', settings.syncWithCloud);
    await _prefs.setString('cloud_sync_url', settings.cloudSyncUrl);
    await _prefs.setBool('enable_tool_filter', settings.enableToolFilter);
    await _prefs.setString('ai_provider', settings.aiProvider);
    await _prefs.setString('ai_api_key', settings.aiApiKey);
    await _prefs.setString('ai_model', settings.aiModel);
    await _prefs.setString('editor_theme', settings.editorTheme);
    await _prefs.setBool('enable_syntax_highlighting', settings.enableSyntaxHighlighting);
    await _prefs.setBool('enable_auto_complete', settings.enableAutoComplete);
    await _prefs.setInt('tab_size', settings.tabSize);
    await _prefs.setBool('show_line_numbers', settings.showLineNumbers);
    await _prefs.setBool('word_wrap', settings.wordWrap);
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    final defaultSettings = const AppSettings();
    await saveSettings(defaultSettings);
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    return getSettings().toJson();
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    final appSettings = AppSettings.fromJson(settings);
    await saveSettings(appSettings);
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('Must be initialized in main()');
});
```

## Settings UI - Main Page

### lib/features/settings/presentation/pages/settings_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/settings_navigation.dart';
import '../widgets/settings_content.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () {
              _showResetDialog(context);
            },
            tooltip: 'Reset to Defaults',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _exportSettings(context);
            },
            tooltip: 'Export Settings',
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () {
              _importSettings(context);
            },
            tooltip: 'Import Settings',
          ),
        ],
      ),
      body: Row(
        children: [
          // Settings Navigation
          const SizedBox(
            width: 250,
            child: SettingsNavigation(),
          ),
          
          const VerticalDivider(width: 1),
          
          // Settings Content
          const Expanded(
            child: SettingsContent(),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(settingsServiceProvider).resetToDefaults();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset to defaults')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _exportSettings(BuildContext context) {
    final settings = ref.read(settingsServiceProvider).exportSettings();
    // Implement file export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings exported')),
    );
  }

  void _importSettings(BuildContext context) {
    // Implement file import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings imported')),
    );
  }
}
```

## Settings Navigation

### lib/features/settings/presentation/widgets/settings_navigation.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SettingsSection {
  general,
  appearance,
  network,
  data,
  security,
  advanced,
  workspace,
  toolFilter,
  editor,
}

class SettingsNavigation extends ConsumerWidget {
  const SettingsNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSection = ref.watch(settingsSectionProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: SettingsSection.values.map((section) {
        return _NavigationItem(
          icon: _getIconForSection(section),
          label: _getLabelForSection(section),
          isSelected: selectedSection == section,
          onTap: () {
            ref.read(settingsSectionProvider.notifier).setSection(section);
          },
        );
      }).toList(),
    );
  }

  IconData _getIconForSection(SettingsSection section) {
    switch (section) {
      case SettingsSection.general:
        return Icons.settings;
      case SettingsSection.appearance:
        return Icons.palette;
      case SettingsSection.network:
        return Icons.wifi;
      case SettingsSection.data:
        return Icons.storage;
      case SettingsSection.security:
        return Icons.security;
      case SettingsSection.advanced:
        return Icons.tune;
      case SettingsSection.workspace:
        return Icons.workspaces;
      case SettingsSection.toolFilter:
        return Icons.filter_alt;
      case SettingsSection.editor:
        return Icons.edit;
    }
  }

  String _getLabelForSection(SettingsSection section) {
    switch (section) {
      case SettingsSection.general:
        return 'General';
      case SettingsSection.appearance:
        return 'Appearance';
      case SettingsSection.network:
        return 'Network';
      case SettingsSection.data:
        return 'Data';
      case SettingsSection.security:
        return 'Security';
      case SettingsSection.advanced:
        return 'Advanced';
      case SettingsSection.workspace:
        return 'Workspace';
      case SettingsSection.toolFilter:
        return 'Tool Filter';
      case SettingsSection.editor:
        return 'Editor';
    }
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@riverpod
class SettingsSection extends _$SettingsSection {
  @override
  SettingsSection build() => SettingsSection.general;

  void setSection(SettingsSection section) {
    state = section;
  }
}
```

## Settings Content - General

### lib/features/settings/presentation/widgets/general_settings.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneralSettings extends ConsumerWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider).getSettings();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'General Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        
        // Language
        _SettingTile(
          title: 'Language',
          subtitle: settings.language,
          trailing: DropdownButton<String>(
            value: settings.language,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'es', child: Text('Spanish')),
              DropdownMenuItem(value: 'fr', child: Text('French')),
              DropdownMenuItem(value: 'de', child: Text('German')),
              DropdownMenuItem(value: 'ja', child: Text('Japanese')),
              DropdownMenuItem(value: 'zh', child: Text('Chinese')),
            ],
            onChanged: (value) {
              if (value != null) {
                _updateSetting(ref, 'language', value);
              }
            },
          ),
        ),
        
        const Divider(),
        
        // Notifications
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive notifications for important events'),
          value: settings.enableNotifications,
          onChanged: (value) {
            _updateSetting(ref, 'enable_notifications', value);
          },
        ),
        
        const Divider(),
        
        // Auto Reconnect
        SwitchListTile(
          title: const Text('Auto Reconnect Servers'),
          subtitle: const Text('Automatically reconnect to servers on app start'),
          value: settings.autoReconnectServers,
          onChanged: (value) {
            _updateSetting(ref, 'auto_reconnect_servers', value);
          },
        ),
        
        const Divider(),
        
        // Connection Timeout
        ListTile(
          title: const Text('Connection Timeout'),
          subtitle: Text('${settings.connectionTimeout} seconds'),
          trailing: Slider(
            value: settings.connectionTimeout.toDouble(),
            min: 5,
            max: 60,
            divisions: 11,
            label: '${settings.connectionTimeout}s',
            onChanged: (value) {
              _updateSetting(ref, 'connection_timeout', value.toInt());
            },
          ),
        ),
        
        const Divider(),
        
        // Request Timeout
        ListTile(
          title: const Text('Request Timeout'),
          subtitle: Text('${settings.requestTimeout} seconds'),
          trailing: Slider(
            value: settings.requestTimeout.toDouble(),
            min: 10,
            max: 120,
            divisions: 11,
            label: '${settings.requestTimeout}s',
            onChanged: (value) {
              _updateSetting(ref, 'request_timeout', value.toInt());
            },
          ),
        ),
      ],
    );
  }

  void _updateSetting(WidgetRef ref, String key, dynamic value) {
    final settings = ref.read(settingsServiceProvider).getSettings();
    // Update specific setting and save
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingTile({
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
    );
  }
}
```

## Settings Content - Network

### lib/features/settings/presentation/widgets/network_settings.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkSettings extends ConsumerWidget {
  const NetworkSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider).getSettings();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Network Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        
        // Enable Proxy
        SwitchListTile(
          title: const Text('Enable Proxy'),
          subtitle: const Text('Route all traffic through a proxy server'),
          value: settings.enableProxy,
          onChanged: (value) {
            _updateSetting(ref, 'enable_proxy', value);
          },
        ),
        
        if (settings.enableProxy) ...[
          const Divider(),
          
          // Proxy URL
          TextField(
            decoration: const InputDecoration(
              labelText: 'Proxy URL',
              hintText: 'http://proxy.example.com:8080',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: settings.proxyUrl),
            onChanged: (value) {
              _updateSetting(ref, 'proxy_url', value);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Proxy Username
          TextField(
            decoration: const InputDecoration(
              labelText: 'Proxy Username',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: settings.proxyUsername),
            onChanged: (value) {
              _updateSetting(ref, 'proxy_username', value);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Proxy Password
          TextField(
            decoration: const InputDecoration(
              labelText: 'Proxy Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            controller: TextEditingController(text: settings.proxyPassword),
            onChanged: (value) {
              _updateSetting(ref, 'proxy_password', value);
            },
          ),
        ],
        
        const Divider(),
        
        // Max Concurrent Requests
        ListTile(
          title: const Text('Max Concurrent Requests'),
          subtitle: Text('${settings.maxConcurrentRequests}'),
          trailing: Slider(
            value: settings.maxConcurrentRequests.toDouble(),
            min: 1,
            max: 50,
            divisions: 49,
            label: '${settings.maxConcurrentRequests}',
            onChanged: (value) {
              _updateSetting(ref, 'max_concurrent_requests', value.toInt());
            },
          ),
        ),
        
        const Divider(),
        
        // HTTP/2
        SwitchListTile(
          title: const Text('Enable HTTP/2'),
          subtitle: const Text('Use HTTP/2 for supported servers'),
          value: settings.enableHttp2,
          onChanged: (value) {
            _updateSetting(ref, 'enable_http2', value);
          },
        ),
        
        const SizedBox(height: 24),
        
        // Test Connection Button
        ElevatedButton.icon(
          onPressed: () {
            _testConnection(context);
          },
          icon: const Icon(Icons.network_check),
          label: const Text('Test Connection'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  void _updateSetting(WidgetRef ref, String key, dynamic value) {
    // Update setting
  }

  void _testConnection(BuildContext context) {
    // Test network connection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing connection...')),
    );
  }
}
```

## Settings Provider

### lib/features/settings/presentation/providers/settings_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/settings_service.dart';
import '../../data/models/settings_model.dart';

@riverpod
class Settings extends _$Settings {
  @override
  AppSettings build() {
    final service = ref.watch(settingsServiceProvider);
    return service.getSettings();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    final service = ref.read(settingsServiceProvider);
    await service.saveSettings(newSettings);
    state = newSettings;
  }

  Future<void> updateSetting<T>(String key, T value) async {
    final currentSettings = state;
    // Update specific field
    final updatedSettings = _updateField(currentSettings, key, value);
    await updateSettings(updatedSettings);
  }

  AppSettings _updateField(AppSettings settings, String key, dynamic value) {
    // Use code generation or manual mapping
    return settings;
  }

  Future<void> resetToDefaults() async {
    final service = ref.read(settingsServiceProvider);
    await service.resetToDefaults();
    state = service.getSettings();
  }

  Future<void> exportSettings() async {
    final service = ref.read(settingsServiceProvider);
    return service.exportSettings();
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    final service = ref.read(settingsServiceProvider);
    await service.importSettings(settings);
    state = service.getSettings();
  }
}
```

## Quick Settings Menu

### lib/shared/widgets/quick_settings_menu.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuickSettingsMenu extends ConsumerWidget {
  const QuickSettingsMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider).getSettings();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings),
      tooltip: 'Quick Settings',
      onSelected: (value) {
        switch (value) {
          case 'theme':
            _showThemeDialog(context, ref);
            break;
          case 'proxy':
            _toggleProxy(context, ref);
            break;
          case 'notifications':
            _toggleNotifications(context, ref);
            break;
          case 'full_settings':
            Navigator.pushNamed(context, '/settings');
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'theme',
          child: Row(
            children: [
              const Icon(Icons.palette, size: 18),
              const SizedBox(width: 12),
              const Text('Theme'),
              const Spacer(),
              Text(settings.themeName),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'proxy',
          child: Row(
            children: [
              const Icon(Icons.wifi, size: 18),
              const SizedBox(width: 12),
              const Text('Proxy'),
              const Spacer(),
              Switch(
                value: settings.enableProxy,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'notifications',
          child: Row(
            children: [
              const Icon(Icons.notifications, size: 18),
              const SizedBox(width: 12),
              const Text('Notifications'),
              const Spacer(),
              Switch(
                value: settings.enableNotifications,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'full_settings',
          child: Row(
            children: const [
              Icon(Icons.settings, size: 18),
              SizedBox(width: 12),
              Text('All Settings'),
            ],
          ),
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Theme options
          ],
        ),
      ),
    );
  }

  void _toggleProxy(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsServiceProvider).getSettings();
    ref.read(settingsProvider.notifier).updateSetting(
      'enable_proxy',
      !settings.enableProxy,
    );
  }

  void _toggleNotifications(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsServiceProvider).getSettings();
    ref.read(settingsProvider.notifier).updateSetting(
      'enable_notifications',
      !settings.enableNotifications,
    );
  }
}
```

## Migration Checklist

- [ ] Implement SettingsService
- [ ] Create Settings data models
- [ ] Implement Settings page with navigation
- [ ] Create all settings sections (General, Appearance, Network, etc.)
- [ ] Implement Settings provider
- [ ] Add quick settings menu
- [ ] Implement settings export/import
- [ ] Add reset to defaults
- [ ] Test settings persistence
- [ ] Ensure settings apply immediately
- [ ] Add validation for settings
- [ ] Implement workspace settings
- [ ] Add cloud sync configuration

## Next Steps

1. Review `16-crash-reporting-error-handling.md` for error handling
2. Implement settings validation
3. Add settings search functionality
4. Implement settings presets
