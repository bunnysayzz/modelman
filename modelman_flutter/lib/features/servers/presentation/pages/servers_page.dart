import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/server_model.dart';
import '../providers/server_providers.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../mcp/data/services/connection_manager.dart';
import '../../../auth/data/models/oauth_config.dart';
import '../../../auth/data/services/oauth_launcher_service.dart';

/// Full servers management page — responsive layout.
class ServersPage extends ConsumerWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serverListProvider);
    final selectedId = ref.watch(selectedServerIdProvider);
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 800;
    final edgePadding = width < 600 ? 12.0 : 24.0;

    return Padding(
      padding: EdgeInsets.all(edgePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row — wraps on narrow
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'MCP Servers',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              StatusBadge(
                label: '${servers.where((s) => s.connected).length} connected',
                type: servers.any((s) => s.connected)
                    ? StatusType.connected
                    : StatusType.disconnected,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _showAddServerDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Server'),
            ),
          ),
          const SizedBox(height: 16),

          // Server list
          if (servers.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dns_outlined, size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No servers configured',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add an MCP server to get started',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => _showAddServerDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Your First Server'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: isNarrow
                  // Single column on narrow screens
                  ? ListView.separated(
                      itemCount: servers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        return _ServerCard(
                          server: servers[index],
                          isSelected: servers[index].id == selectedId,
                          onTap: () {
                            ref.read(selectedServerIdProvider.notifier).state =
                                servers[index].id;
                          },
                          onConnect: () => ref
                              .read(connectionManagerProvider)
                              .connectAndDiscover(servers[index]),
                          onDisconnect: () => ref
                              .read(connectionManagerProvider)
                              .disconnectServer(servers[index]),
                          onDelete: () => ref
                              .read(serverListProvider.notifier)
                              .removeServer(servers[index].id),
                        );
                      },
                    )
                  // Two-panel on wide screens
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Server list — flexible width
                        Flexible(
                          flex: 2,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: ListView.separated(
                              itemCount: servers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                return _ServerCard(
                                  server: servers[index],
                                  isSelected: servers[index].id == selectedId,
                                  onTap: () {
                                    ref
                                        .read(selectedServerIdProvider.notifier)
                                        .state = servers[index].id;
                                  },
                                  onConnect: () => ref
                                      .read(connectionManagerProvider)
                                      .connectAndDiscover(servers[index]),
                                  onDisconnect: () => ref
                                      .read(connectionManagerProvider)
                                      .disconnectServer(servers[index]),
                                  onDelete: () => ref
                                      .read(serverListProvider.notifier)
                                      .removeServer(servers[index].id),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          flex: 3,
                          child: _buildDetailPanel(
                              context, ref, servers, selectedId),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(BuildContext context, WidgetRef ref,
      List<ServerConfig> servers, String? selectedId) {
    final theme = Theme.of(context);

    if (selectedId == null) {
      return Card(
        child: Center(
          child: Text(
            'Select a server to view details',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ),
      );
    }

    final server = servers.firstWhere(
      (s) => s.id == selectedId,
      orElse: () => servers.first,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  server.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                StatusBadge(
                  label: server.connected ? 'Connected' : 'Disconnected',
                  type: server.connected
                      ? StatusType.connected
                      : StatusType.disconnected,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('URL', server.url, theme),
            _detailRow('Transport', server.transport, theme),
            if (server.lastConnected != null)
              _detailRow(
                  'Last Connected', server.lastConnected.toString(), theme),
            if (server.error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  server.error!,
                  style: TextStyle(
                      color: theme.colorScheme.error, fontSize: 13),
                ),
              ),
            ],
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (server.connected)
                  OutlinedButton(
                    onPressed: () => ref
                        .read(connectionManagerProvider)
                        .disconnectServer(server),
                    child: const Text('Disconnect'),
                  )
                else if (server.auth?.type == 'oauth')
                  FilledButton.icon(
                    onPressed: () async {
                      // Initiate OAuth flow
                      if (server.auth != null && server.auth!.type == 'oauth') {
                        final oauthConfig = OAuthConfig(
                          authorizationEndpoint: server.auth!.authorizationUrl ?? '',
                          tokenEndpoint: server.auth!.tokenUrl ?? '',
                          clientId: server.auth!.clientId ?? '',
                          clientSecret: server.auth!.clientSecret,
                          redirectUri: server.auth!.redirectUri ?? 'modelman://oauth/callback',
                          scope: server.auth!.scopes?.join(' '),
                        );
                        await ref.read(oauthLauncherServiceProvider).initiateOAuth(
                          oauthConfig,
                          server.id,
                        );
                      }
                    },
                    icon: const Icon(Icons.lock_open, size: 18),
                    label: const Text('Authorize'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => ref
                        .read(connectionManagerProvider)
                        .connectAndDiscover(server),
                    icon: const Icon(Icons.power, size: 18),
                    label: const Text('Connect'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddServerDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    String transport = 'http';
    String authType = 'none';
    bool isAutoDetecting = false;
    
    // OAuth fields
    final clientIdController = TextEditingController();
    final clientSecretController = TextEditingController();
    final authorizationUrlController = TextEditingController();
    final tokenUrlController = TextEditingController();
    final redirectUriController = TextEditingController(text: 'modelman://oauth/callback');
    final scopeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final dialogWidth = MediaQuery.of(ctx).size.width;
          return AlertDialog(
            title: const Text('Add MCP Server'),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogWidth < 500 ? dialogWidth * 0.9 : 460,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        labelText: 'Server URL',
                        hintText: 'https://mcp-server.example.com',
                        suffixIcon: isAutoDetecting
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : TextButton(
                                onPressed: () async {
                                  final url = urlController.text.trim();
                                  if (url.isEmpty) return;
                                  setDialogState(() => isAutoDetecting = true);
                                  final config = await ref
                                      .read(connectionManagerProvider)
                                      .autoDetect(url);
                                  setDialogState(() => isAutoDetecting = false);
                                  if (config != null) {
                                    nameController.text = config.name;
                                    setDialogState(
                                        () => transport = config.transport);
                                    // Set OAuth fields if detected
                                    if (config.auth != null && config.auth!.type == 'oauth') {
                                      setDialogState(() => authType = 'oauth');
                                      if (config.auth!.clientId != null) {
                                        clientIdController.text = config.auth!.clientId!;
                                      }
                                      if (config.auth!.authorizationUrl != null) {
                                        authorizationUrlController.text = config.auth!.authorizationUrl!;
                                      }
                                      if (config.auth!.tokenUrl != null) {
                                        tokenUrlController.text = config.auth!.tokenUrl!;
                                      }
                                      if (config.auth!.redirectUri != null) {
                                        redirectUriController.text = config.auth!.redirectUri!;
                                      }
                                      if (config.auth!.scopes != null) {
                                        scopeController.text = config.auth!.scopes!.join(' ');
                                      }
                                    }
                                  }
                                },
                                child: const Text('Detect'),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Server Name',
                        hintText: 'My MCP Server',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: transport,
                      decoration:
                          const InputDecoration(labelText: 'Transport'),
                      items: const [
                        DropdownMenuItem(value: 'http', child: Text('HTTP')),
                        DropdownMenuItem(value: 'sse', child: Text('SSE')),
                        DropdownMenuItem(
                            value: 'websocket', child: Text('WebSocket')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => transport = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: authType,
                      decoration:
                          const InputDecoration(labelText: 'Authentication'),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('None')),
                        DropdownMenuItem(value: 'api_key', child: Text('API Key')),
                        DropdownMenuItem(value: 'oauth', child: Text('OAuth 2.1')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => authType = v);
                      },
                    ),
                    // OAuth fields
                    if (authType == 'oauth') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: clientIdController,
                        decoration: const InputDecoration(
                          labelText: 'Client ID',
                          hintText: 'your-client-id',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: clientSecretController,
                        decoration: const InputDecoration(
                          labelText: 'Client Secret',
                          hintText: 'your-client-secret',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: authorizationUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Authorization URL',
                          hintText: 'https://auth.example.com/authorize',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: tokenUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Token URL',
                          hintText: 'https://auth.example.com/token',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: redirectUriController,
                        decoration: const InputDecoration(
                          labelText: 'Redirect URI',
                          hintText: 'modelman://oauth/callback',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: scopeController,
                        decoration: const InputDecoration(
                          labelText: 'Scopes',
                          hintText: 'read write',
                        ),
                      ),
                    ],
                    // API Key field
                    if (authType == 'api_key') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: TextEditingController(),
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          hintText: 'your-api-key',
                        ),
                        obscureText: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final url = urlController.text.trim();
                  if (name.isNotEmpty && url.isNotEmpty) {
                    // Build auth config
                    AuthConfig? authConfig;
                    if (authType == 'oauth') {
                      authConfig = AuthConfig(
                        type: 'oauth',
                        clientId: clientIdController.text.trim(),
                        clientSecret: clientSecretController.text.trim(),
                        authorizationUrl: authorizationUrlController.text.trim(),
                        tokenUrl: tokenUrlController.text.trim(),
                        redirectUri: redirectUriController.text.trim(),
                        scopes: scopeController.text.trim().split(' '),
                      );
                    } else if (authType == 'api_key') {
                      authConfig = AuthConfig(
                        type: 'api_key',
                        apiKey: 'your-api-key', // TODO: Add API key field
                      );
                    }
                    
                    ref.read(serverListProvider.notifier).createServer(
                          name: name,
                          url: url,
                          transport: transport,
                          auth: authConfig,
                        );
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Add Server'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ServerCard extends StatefulWidget {
  final ServerConfig server;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onDelete;

  const _ServerCard({
    required this.server,
    required this.isSelected,
    required this.onTap,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
  });

  @override
  State<_ServerCard> createState() => _ServerCardState();
}

class _ServerCardState extends State<_ServerCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modelman = theme.modelman;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Card(
        elevation: widget.isSelected ? 3 : _hovering ? 2 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: widget.isSelected
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.server.connected
                        ? modelman.serverConnected
                        : modelman.serverDisconnected,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.server.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.server.url,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color:
                              theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_hovering || widget.isSelected) ...[
                  if (widget.server.connected)
                    IconButton(
                      icon: Icon(Icons.power_off,
                          size: 18,
                          color: Colors.orange.withOpacity(0.8)),
                      onPressed: widget.onDisconnect,
                      tooltip: 'Disconnect',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                          minWidth: 32, minHeight: 32),
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.power,
                          size: 18, color: theme.colorScheme.primary),
                      onPressed: widget.onConnect,
                      tooltip: 'Connect',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                          minWidth: 32, minHeight: 32),
                    ),
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 18,
                        color: theme.colorScheme.error.withOpacity(0.7)),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
