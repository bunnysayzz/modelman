import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tool_providers.dart';
import '../../../servers/presentation/providers/server_providers.dart';
import '../../data/models/tool_model.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/split_panel.dart';
import '../../../../shared/widgets/json_editor.dart';
import '../../../../shared/widgets/json_viewer.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../mcp/data/services/mcp_client_service.dart';

/// Full Tools page with server-grouped tool list, JSON parameter editor,
/// execution, and response viewer in a split panel.
class ToolsPage extends ConsumerWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolsByServer = ref.watch(toolListProvider);
    final connectedServers = ref.watch(connectedServersProvider);
    final selectedTool = ref.watch(selectedToolProvider);
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 800;
    final edgePadding = width < 600 ? 12.0 : 24.0;

    return Padding(
      padding: EdgeInsets.all(edgePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'MCP Tools',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              StatusBadge(
                label: '${toolsByServer.values.expand((t) => t).length} tools',
                type: StatusType.connected,
                showDot: false,
              ),
              if (connectedServers.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    for (final server in connectedServers) {
                      ref.read(toolListProvider.notifier).loadTools(server.id);
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: connectedServers.isEmpty
                ? _emptyState(theme)
                : isNarrow
                    // Stacked on narrow: tools list then detail
                    ? selectedTool == null
                        ? Card(
                            child: _ToolListPanel(
                              toolsByServer: toolsByServer,
                              connectedServers: connectedServers,
                              selectedTool: selectedTool,
                            ),
                          )
                        : _ToolExecutePanel(tool: selectedTool)
                    // Side-by-side on wide
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 2,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Card(
                                child: _ToolListPanel(
                                  toolsByServer: toolsByServer,
                                  connectedServers: connectedServers,
                                  selectedTool: selectedTool,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            flex: 5,
                            child: selectedTool == null
                                ? Card(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.build_outlined,
                                              size: 48,
                                              color: theme
                                                  .colorScheme.onSurface
                                                  .withOpacity(0.2)),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Select a tool to execute',
                                            style: TextStyle(
                                              color: theme
                                                  .colorScheme.onSurface
                                                  .withOpacity(0.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : _ToolExecutePanel(tool: selectedTool),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_outlined, size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No connected servers',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect to an MCP server to discover tools',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tool list panel ──

class _ToolListPanel extends ConsumerWidget {
  final Map<String, List<ToolSchema>> toolsByServer;
  final List connectedServers;
  final ToolSchema? selectedTool;

  const _ToolListPanel({
    required this.toolsByServer,
    required this.connectedServers,
    required this.selectedTool,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      children: connectedServers.map<Widget>((server) {
        final tools = toolsByServer[server.id] ?? [];
        return ExpansionTile(
          title: Text(server.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          leading: Icon(Icons.dns, size: 16, color: theme.colorScheme.primary),
          initiallyExpanded: true,
          childrenPadding: const EdgeInsets.only(left: 8),
          children: tools.isEmpty
              ? [
                  ListTile(
                    dense: true,
                    title: Text(
                      'No tools loaded',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () =>
                          ref.read(toolListProvider.notifier).loadTools(server.id),
                      child: const Text('Load', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ]
              : tools.map((tool) {
                  final isSelected = selectedTool?.name == tool.name &&
                      selectedTool?.serverId == tool.serverId;
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.build_circle_outlined,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6)),
                    title: Text(tool.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        )),
                    subtitle: tool.description != null
                        ? Text(
                            tool.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          )
                        : null,
                    selected: isSelected,
                    onTap: () =>
                        ref.read(selectedToolProvider.notifier).state = tool,
                  );
                }).toList(),
        );
      }).toList(),
    );
  }
}

// ── Tool execute panel with split view ──

class _ToolExecutePanel extends ConsumerStatefulWidget {
  final ToolSchema tool;

  const _ToolExecutePanel({required this.tool});

  @override
  ConsumerState<_ToolExecutePanel> createState() => _ToolExecutePanelState();
}

class _ToolExecutePanelState extends ConsumerState<_ToolExecutePanel> {
  Map<String, dynamic> _arguments = {};
  ToolExecutionResult? _result;
  bool _isExecuting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: [
          // Tool header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.build, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tool.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.tool.description != null)
                        Text(
                          widget.tool.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: _isExecuting
                      ? 'Executing...'
                      : _result != null
                          ? _result!.isError
                              ? 'Error'
                              : '${_result!.duration.inMilliseconds}ms'
                          : 'Ready',
                  type: _isExecuting
                      ? StatusType.executing
                      : _result != null
                          ? _result!.isError
                              ? StatusType.error
                              : StatusType.success
                          : StatusType.disconnected,
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _isExecuting ? null : _execute,
                  icon: _isExecuting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Execute'),
                ),
              ],
            ),
          ),

          // Split panel: params left, response right
          Expanded(
            child: SplitPanel(
              leftChild: Padding(
                padding: const EdgeInsets.all(12),
                child: JsonEditor(
                  initialValue: _arguments.isEmpty ? null : _arguments,
                  hintText: '{\n  "param": "value"\n}',
                  onChanged: (data) => _arguments = data,
                ),
              ),
              rightChild: Padding(
                padding: const EdgeInsets.all(12),
                child: _result == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_outline, size: 40,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.2)),
                            const SizedBox(height: 8),
                            Text(
                              'Execute to see response',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _result!.isError
                        ? _buildErrorView(theme)
                        : JsonViewer(data: _result!.result),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 32),
            const SizedBox(height: 8),
            Text(
              'Execution Error',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              _result!.error ?? 'Unknown error',
              style: TextStyle(
                color: theme.colorScheme.error.withOpacity(0.8),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _execute() async {
    setState(() => _isExecuting = true);

    try {
      final mcp = ref.read(mcpClientServiceProvider);
      final result = await mcp.executeTool(
        serverId: widget.tool.serverId,
        toolName: widget.tool.name,
        arguments: _arguments,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isExecuting = false;
        });

        // Add to execution history
        final history = ref.read(executionHistoryProvider);
        ref.read(executionHistoryProvider.notifier).state = [
          result,
          ...history,
        ];
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = ToolExecutionResult(
            toolName: widget.tool.name,
            serverId: widget.tool.serverId,
            arguments: _arguments,
            result: null,
            timestamp: DateTime.now(),
            duration: Duration.zero,
            error: ApiException.fromError(e).message,
            isError: true,
          );
          _isExecuting = false;
        });
      }
    }
  }
}
