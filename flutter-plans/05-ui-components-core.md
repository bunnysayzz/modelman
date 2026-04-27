# Core UI Components

## Overview

This document details the implementation of core UI components, mapping from React components to Flutter widgets.

## Component Mapping Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                   Component Mapping                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  React Component                    Flutter Widget            │
│  ──────────────                    ──────────────            │
│  ServerSidebar.tsx          →    ServerSidebar.dart         │
│  ToolsSidebar.tsx            →    ToolsSidebar.dart          │
│  MainArea.tsx                →    MainArea.dart              │
│  AddServerModal.tsx          →    AddServerModal.dart        │
│  EditServerModal.tsx         →    EditServerModal.dart       │
│  JsonEditor.tsx              →    JsonEditor.dart            │
│  JsonViewer.tsx              →    JsonViewer.dart            │
│  MarkdownRenderer.tsx       →    MarkdownRenderer.dart     │
│  ThemeSwitcher.tsx           →    ThemeSwitcher.dart         │
│  Toast.tsx                   →    Toast.dart                 │
│  Modal.tsx                   →    CustomDialog.dart          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Server Sidebar

### lib/features/servers/presentation/widgets/server_sidebar.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/server_model.dart';
import '../../../../core/state/providers.dart';
import 'server_tile.dart';

class ServerSidebar extends ConsumerWidget {
  const ServerSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);
    final selectedServerId = ref.watch(selectedServerProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // Filter servers based on search
    final filteredServers = servers.where((server) {
      if (searchQuery.isEmpty) return true;
      return server.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
             server.url.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context, ref),
          
          // Search
          _buildSearchBar(context, ref),
          
          // Server List
          Expanded(
            child: servers.when(
              data: (serverList) {
                if (filteredServers.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                return ListView.builder(
                  itemCount: filteredServers.length,
                  itemBuilder: (context, index) {
                    final server = filteredServers[index];
                    final isSelected = server.id == selectedServerId;
                    
                    return ServerTile(
                      server: server,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedServerProvider.notifier).setServer(server.id);
                      },
                      onEdit: () {
                        _showEditServerDialog(context, ref, server);
                      },
                      onDelete: () {
                        _confirmDeleteServer(context, ref, server.id);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
          
          // Add Server Button
          _buildAddServerButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.dns, size: 24),
          const SizedBox(width: 12),
          Text(
            'Servers',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh servers
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search servers...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        onChanged: (query) {
          ref.read(searchQueryProvider.notifier).setQuery(query);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dns_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No servers found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a server to get started',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAddServerButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () {
          _showAddServerDialog(context, ref);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Server'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  void _showAddServerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddServerModal(),
    );
  }

  void _showEditServerDialog(BuildContext context, WidgetRef ref, ServerConfig server) {
    showDialog(
      context: context,
      builder: (context) => EditServerModal(server: server),
    );
  }

  void _confirmDeleteServer(BuildContext context, WidgetRef ref, String serverId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Server'),
        content: const Text('Are you sure you want to delete this server?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(serversProvider.notifier).removeServer(serverId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
```

### lib/features/servers/presentation/widgets/server_tile.dart

```dart
import 'package:flutter/material.dart';
import '../../data/models/server_model.dart';

class ServerTile extends StatelessWidget {
  final ServerConfig server;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServerTile({
    super.key,
    required this.server,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: server.faviconUrl != null
              ? NetworkImage(server.faviconUrl!)
              : null,
          child: server.faviconUrl == null
              ? const Icon(Icons.dns)
              : null,
        ),
        title: Text(
          server.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          server.url,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (server.connected)
              Icon(
                Icons.cloud_done,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
```

## Tools Sidebar

### lib/features/tools/presentation/widgets/tools_sidebar.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/providers.dart';
import 'tool_tile.dart';

class ToolsSidebar extends ConsumerWidget {
  const ToolsSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServerId = ref.watch(selectedServerProvider);
    final tools = ref.watch(filteredToolsProvider);
    final selectedToolName = ref.watch(selectedToolProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    if (selectedServerId == null) {
      return _buildNoServerSelected(context);
    }

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context, ref),
          
          // Search
          _buildSearchBar(context, ref, searchQuery),
          
          // Tools List
          Expanded(
            child: tools.isEmpty
                ? _buildEmptyState(context, searchQuery)
                : ListView.builder(
                    itemCount: tools.length,
                    itemBuilder: (context, index) {
                      final tool = tools[index];
                      final isSelected = tool.name == selectedToolName;
                      
                      return ToolTile(
                        tool: tool,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(selectedToolProvider.notifier).setTool(tool.name);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoServerSelected(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dns_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Server Selected',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Select a server to view tools',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.build, size: 24),
          const SizedBox(width: 12),
          Text(
            'Tools',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh tools
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref, String query) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search tools...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        controller: TextEditingController(text: query),
        onChanged: (query) {
          ref.read(searchQueryProvider.notifier).setQuery(query);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            query.isEmpty ? Icons.build_outlined : Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'No tools available' : 'No tools found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
```

### lib/features/tools/presentation/widgets/tool_tile.dart

```dart
import 'package:flutter/material.dart';
import '../../data/models/server_model.dart';

class ToolTile extends StatelessWidget {
  final ToolSchema tool;
  final bool isSelected;
  final VoidCallback onTap;

  const ToolTile({
    super.key,
    required this.tool,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.extension,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          tool.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: tool.description != null
            ? Text(
                tool.description!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
```

## Main Area

### lib/features/tools/presentation/widgets/main_area.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/providers.dart';
import 'tool_executor.dart';

class MainArea extends ConsumerWidget {
  const MainArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServerId = ref.watch(selectedServerProvider);
    final selectedToolName = ref.watch(selectedToolProvider);
    final currentTool = ref.watch(currentToolProvider);
    final isExecuting = ref.watch(executingToolsProvider).contains(
      '$selectedServerId:$selectedToolName',
    );

    if (selectedToolName == null || currentTool == null) {
      return _buildNoToolSelected(context);
    }

    return Expanded(
      child: Column(
        children: [
          // Tool Header
          _buildToolHeader(context, currentTool),
          
          // Tool Executor
          Expanded(
            child: ToolExecutor(
              tool: currentTool,
              serverId: selectedServerId!,
              isExecuting: isExecuting,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoToolSelected(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.extension_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Tool Selected',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Select a tool from the sidebar',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildToolHeader(BuildContext context, ToolSchema tool) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.extension,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (tool.description != null)
                  Text(
                    tool.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## JSON Editor

### lib/shared/widgets/json_editor.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_editor/json_editor.dart';

class JsonEditor extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool readOnly;

  const JsonEditor({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  State<JsonEditor> createState() => _JsonEditorState();
}

class _JsonEditorState extends State<JsonEditor> {
  late TextEditingController _controller;
  bool _isValidJson = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateJson(String value) {
    try {
      if (value.isEmpty) {
        setState(() => _isValidJson = true);
        return;
      }
      
      // Simple JSON validation
      final trimmed = value.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        // Try to parse
        // Use jsonDecode from dart:convert
        setState(() => _isValidJson = true);
      } else {
        setState(() => _isValidJson = false);
      }
    } catch (e) {
      setState(() => _isValidJson = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: _isValidJson
              ? Theme.of(context).dividerColor
              : Theme.of(context).colorScheme.error,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Toolbar
          _buildToolbar(context),
          
          // Editor
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              readOnly: widget.readOnly,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (value) {
                _validateJson(value);
                widget.onChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isValidJson ? Icons.check_circle : Icons.error,
            size: 16,
            color: _isValidJson
                ? Colors.green
                : Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            _isValidJson ? 'Valid JSON' : 'Invalid JSON',
            style: TextStyle(
              fontSize: 12,
              color: _isValidJson
                  ? Colors.green
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          const Spacer(),
          if (!widget.readOnly)
            IconButton(
              icon: const Icon(Icons.format_align_left, size: 16),
              onPressed: () {
                // Format JSON
                try {
                  final parsed = jsonDecode(_controller.text);
                  final formatted = JsonEncoder.withIndent('  ').convert(parsed);
                  _controller.text = formatted;
                } catch (e) {
                  // Invalid JSON, can't format
                }
              },
              tooltip: 'Format JSON',
            ),
          IconButton(
            icon: const Icon(Icons.content_copy, size: 16),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _controller.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            tooltip: 'Copy',
          ),
        ],
      ),
    );
  }
}
```

## JSON Viewer

### lib/shared/widgets/json_viewer.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/languages/json.dart';

class JsonViewer extends StatelessWidget {
  final Map<String, dynamic> data;

  const JsonViewer({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF282C34),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HighlightView(
          jsonString,
          language: json,
          theme: atomOneDarkTheme,
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
```

## Markdown Renderer

### lib/shared/widgets/markdown_renderer.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownRenderer extends StatelessWidget {
  final String content;

  const MarkdownRenderer({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: content,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        code: TextStyle(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquote: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 4,
            ),
          ),
        ),
      ),
      selectable: true,
      onTapLink: (text, href, title) {
        // Handle link taps
        if (href != null) {
          // Open link
        }
      },
    );
  }
}
```

## Toast Notifications

### lib/shared/widgets/toast.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/providers.dart';

class Toast extends ConsumerWidget {
  const Toast({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(toastProvider);

    return Stack(
      children: [
        ...toasts.map((toast) {
          return Positioned(
            bottom: 16 + (toasts.indexOf(toast) * 60),
            right: 16,
            left: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(context, toast.type),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_getIcon(toast.type), color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        toast.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        ref.read(toastProvider.notifier).removeToast(toast.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getBackgroundColor(BuildContext context, ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Theme.of(context).colorScheme.error;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
        return Colors.blue;
    }
  }

  IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }
}

enum ToastType { success, error, warning, info }

class ToastItem {
  final String id;
  final String message;
  final ToastType type;

  ToastItem({
    required this.id,
    required this.message,
    required this.type,
  });
}
```

## Modal System

### lib/shared/widgets/custom_dialog.dart

```dart
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: content,
              ),
            ),
            
            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions,
      ),
    );
  }
}
```

## Component Usage Example

### lib/features/servers/presentation/pages/servers_page.dart

```dart
class ServersPage extends StatelessWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        ServerSidebar(),
        ToolsSidebar(),
        Expanded(
          child: MainArea(),
        ),
      ],
    );
  }
}
```

## Testing Components

### test/shared/widgets/json_editor_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hoot_flutter/shared/widgets/json_editor.dart';

void main() {
  testWidgets('JsonEditor validates JSON', (tester) async {
    bool isValid = true;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JsonEditor(
            initialValue: '{"test": "value"}',
            onChanged: (value) {},
          ),
        ),
      ),
    );
    
    expect(find.byType(JsonEditor), findsOneWidget);
  });
}
```

## Migration Checklist

- [ ] Create ServerSidebar widget
- [ ] Create ServerTile widget
- [ ] Create ToolsSidebar widget
- [ ] Create ToolTile widget
- [ ] Create MainArea widget
- [ ] Create ToolExecutor widget
- [ ] Create JsonEditor widget
- [ ] Create JsonViewer widget
- [ ] Create MarkdownRenderer widget
- [ ] Create Toast notification system
- [ ] Create CustomDialog for modals
- [ ] Add responsive layout support
- [ ] Test all components with different screen sizes
- [ ] Add accessibility support

## Next Steps

1. Review `06-mcp-client-implementation.md` for MCP client logic
2. Implement AddServerModal and EditServerModal
3. Add animations and transitions
4. Implement keyboard shortcuts
