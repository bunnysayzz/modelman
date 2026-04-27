import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_model.dart';
import '../../../servers/presentation/providers/server_providers.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_exception.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Full chat page with message list, streaming indicator, tool-call
/// rendering, error handling, and message input — premium UI.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  bool _isStreaming = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectedServers = ref.watch(connectedServersProvider);
    final width = MediaQuery.of(context).size.width;
    final edgePadding = width < 600 ? 10.0 : 20.0;

    return Column(
      children: [
        // ── Header ────────────────────────────────────
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: edgePadding,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withOpacity(0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.15),
                      theme.colorScheme.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome,
                    size: 20, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Chat',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (connectedServers.isNotEmpty)
                      Text(
                        '${connectedServers.length} server${connectedServers.length > 1 ? 's' : ''} connected',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Text(
                        'No servers connected',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                  ],
                ),
              ),
              if (_messages.isNotEmpty)
                IconButton(
                  onPressed: () => setState(() => _messages.clear()),
                  icon: Icon(Icons.delete_outline,
                      size: 18,
                      color: theme.colorScheme.error.withOpacity(0.7)),
                  tooltip: 'Clear chat',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.error.withOpacity(0.08),
                  ),
                ),
            ],
          ),
        ),

        // ── Connected servers chips ────────────────────
        if (connectedServers.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: edgePadding,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.03),
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.3),
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: connectedServers
                    .map(
                      (s) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              s.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

        // ── Messages area ──────────────────────────────
        Expanded(
          child: _messages.isEmpty
              ? _EmptyState(
                  onSuggestionTap: (text) {
                    _controller.text = text;
                    _sendMessage();
                  },
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: edgePadding,
                    vertical: 16,
                  ),
                  itemCount: _messages.length + (_isStreaming ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isStreaming) {
                      return const _TypingIndicator();
                    }
                    return _MessageBubble(message: _messages[index]);
                  },
                ),
        ),

        // ── Input area ─────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(edgePadding, 8, edgePadding, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.dividerColor.withOpacity(0.5),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : theme.dividerColor.withOpacity(0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: IconButton(
                      icon: Icon(Icons.attach_file_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.4)),
                      onPressed: () {},
                      tooltip: 'Attach file',
                      constraints: const BoxConstraints(
                          minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: connectedServers.isEmpty
                            ? 'Connect a server to start chatting...'
                            : 'Ask the AI to test your tools...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.35),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4, bottom: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        onPressed: _isStreaming ||
                                _controller.text.trim().isEmpty
                            ? null
                            : _sendMessage,
                        icon: _isStreaming
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : Icon(
                                Icons.send_rounded,
                                size: 20,
                                color: _controller.text.trim().isNotEmpty
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.25),
                              ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              _controller.text.trim().isNotEmpty &&
                                      !_isStreaming
                                  ? theme.colorScheme.primary
                                      .withOpacity(0.1)
                                  : Colors.transparent,
                        ),
                        constraints: const BoxConstraints(
                            minWidth: 36, minHeight: 36),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isStreaming = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.sendChatMessage(
        messages: _messages.map((m) => m.toJson()).toList(),
        options: {},
      );

      final assistantMsg = ChatMessage(
        id: _uuid.v4(),
        role: ChatRole.assistant,
        content: response['content'] as String? ??
            response['message'] as String? ??
            'No response received.',
        timestamp: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _messages.add(assistantMsg);
          _isStreaming = false;
        });
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            id: _uuid.v4(),
            role: ChatRole.error,
            content: e.message,
            timestamp: DateTime.now(),
          ));
          _isStreaming = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        final apiError = ApiException.fromError(e);
        setState(() {
          _messages.add(ChatMessage(
            id: _uuid.v4(),
            role: ChatRole.error,
            content: apiError.message,
            timestamp: DateTime.now(),
          ));
          _isStreaming = false;
        });
        _scrollToBottom();
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  EMPTY STATE — premium design
// ═══════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;

  const _EmptyState({required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon with gradient background
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.15),
                    theme.colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 36,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'AI-Powered MCP Testing',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                'Ask the AI to discover, test, and chain your MCP tools. '
                'Connect a server to get started.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.45),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Suggestion cards
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  _SuggestionCard(
                    icon: Icons.list_alt_rounded,
                    title: 'List all tools',
                    subtitle: 'Discover available tools on connected servers',
                    onTap: () =>
                        onSuggestionTap('List all available tools'),
                  ),
                  const SizedBox(height: 8),
                  _SuggestionCard(
                    icon: Icons.play_circle_outline_rounded,
                    title: 'Execute a tool',
                    subtitle: 'Run a specific tool with parameters',
                    onTap: () =>
                        onSuggestionTap('Show me how to execute a tool'),
                  ),
                  const SizedBox(height: 8),
                  _SuggestionCard(
                    icon: Icons.wifi_tethering_rounded,
                    title: 'Test connection',
                    subtitle: 'Verify server connectivity and health',
                    onTap: () => onSuggestionTap(
                        'Test the connection to my server'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hovering
              ? theme.colorScheme.primary.withOpacity(0.06)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovering
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.dividerColor.withOpacity(0.5),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon,
                        size: 18, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface
                          .withOpacity(0.25)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MESSAGE BUBBLE — supports user, assistant, and error roles
// ═══════════════════════════════════════════════════════════════

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == ChatRole.user;
    final isError = message.role == ChatRole.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: isError
                    ? LinearGradient(colors: [
                        theme.colorScheme.error.withOpacity(0.2),
                        theme.colorScheme.error.withOpacity(0.1),
                      ])
                    : LinearGradient(colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.secondary.withOpacity(0.1),
                      ]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isError ? Icons.error_outline : Icons.auto_awesome,
                size: 16,
                color: isError
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isError
                    ? theme.colorScheme.error.withOpacity(0.08)
                    : isUser
                        ? theme.colorScheme.primary.withOpacity(0.12)
                        : theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.4),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isError
                    ? Border.all(
                        color: theme.colorScheme.error.withOpacity(0.2))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isError) ...[
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 14, color: theme.colorScheme.error),
                        const SizedBox(width: 6),
                        Text(
                          'Connection Error',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  SelectableText(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isError
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.person,
                  size: 16, color: theme.colorScheme.onPrimary),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════════
//  TYPING INDICATOR
// ═══════════════════════════════════════════════════════════════

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.colorScheme.primary.withOpacity(0.2),
                theme.colorScheme.secondary.withOpacity(0.1),
              ]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.auto_awesome,
                size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withOpacity(0.4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _AnimatedDot(delay: index * 200),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final int delay;
  const _AnimatedDot({required this.delay});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.2 + _controller.value * 0.5),
          ),
        );
      },
    );
  }
}
