# Chat & Hybrid Interface Implementation

## Overview

This document details the implementation of the chat/hybrid interface for conversational tool testing with AI assistance, mapping from the current React implementation.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                   Chat Interface Architecture                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │   Flutter    │      │   Portkey    │      │   Backend   │ │
│  │  Chat UI     │◄────►│   AI API     │◄────►│  MCP Server │ │
│  │              │      │              │      │             │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                       │                      │     │
│         │ Messages              │ LLM Response         │     │
│         │ Tool Selection        │ Tool Filtering      │     │
│         │ Execution             │ Context              │     │
│         ▼                       ▼                      ▼     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Chat State Management                     │ │
│  │  - Messages (user + AI)                                │ │
│  │  - Tool Context                                        │ │
│  │  - Execution State                                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Current React Implementation

### src/components/HybridInterface.tsx

```typescript
// Current React chat interface with AI assistance
export function HybridInterface() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState('');
  const [isStreaming, setIsStreaming] = useState(false);

  const sendMessage = async () => {
    // Add user message
    setMessages(prev => [...prev, { role: 'user', content: input }]);
    
    // Get AI response with tool filtering
    const response = await fetch('/api/chat', {
      method: 'POST',
      body: JSON.stringify({
        messages,
        context: getToolContext(),
      }),
    });
    
    // Stream AI response
    // Execute selected tools
  };
}
```

## Flutter Implementation

### lib/features/chat/data/models/chat_models.dart

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

enum MessageRole { user, assistant, system, tool }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required MessageRole role,
    required String content,
    @JsonKey(default: []) List<ToolCall>? toolCalls,
    Map<String, dynamic>? toolOutput,
    required DateTime timestamp,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class ToolCall with _$ToolCall {
  const factory ToolCall({
    required String id,
    required String name,
    required Map<String, dynamic> arguments,
    String? serverId,
  }) = _ToolCall;

  factory ToolCall.fromJson(Map<String, dynamic> json) =>
      _$ToolCallFromJson(json);
}

@freezed
class ToolFilterContext with _$ToolFilterContext {
  const factory ToolFilterContext({
    required String serverId,
    required String serverName,
    required List<String> toolNames,
    Map<String, dynamic>? metadata,
  }) = _ToolFilterContext;

  factory ToolFilterContext.fromJson(Map<String, dynamic> json) =>
      _$ToolFilterContextFromJson(json);
}
```

### lib/features/chat/data/services/portkey_client.dart

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/state/providers.dart';
import '../models/chat_models.dart';

class PortkeyClient {
  final Dio _dio;
  final Ref _ref;

  PortkeyClient(this._dio, this._ref);

  // Send message to AI with tool context
  Future<Stream<ChatMessage>> sendMessage({
    required List<ChatMessage> messages,
    required List<ToolFilterContext> toolContext,
  }) async {
    // Get tool filter suggestions
    final filteredTools = await _filterTools(messages, toolContext);

    // Send to Portkey AI
    final response = await _dio.post(
      '/api/chat/completions',
      data: {
        'messages': messages.map((m) => m.toJson()).toList(),
        'tools': filteredTools,
        'tool_filter_config': _ref.read(toolFilterConfigProvider),
      },
      options: Options(responseType: ResponseType.stream),
    );

    // Stream response
    return response.data.stream.map((data) {
      return ChatMessage.fromJson(jsonDecode(data));
    });
  }

  // Filter tools based on conversation context
  Future<List<Map<String, dynamic>>> _filterTools(
    List<ChatMessage> messages,
    List<ToolFilterContext> toolContext,
  ) async {
    final apiService = _ref.read(apiServiceProvider);
    
    // Convert tool context to server format
    final servers = toolContext.map((ctx) => {
      'serverId': ctx.serverId,
      'serverName': ctx.serverName,
      'tools': ctx.toolNames.map((name) => {'name': name}).toList(),
    }).toList();

    // Initialize tool filter if needed
    await apiService.initializeToolFilter(servers);

    // Filter tools
    final result = await apiService.filterTools(
      messages: messages.map((m) => m.toJson()).toList(),
    );

    return (result['tools'] as List)
        .map((t) => t as Map<String, dynamic>)
        .toList();
  }

  // Execute tool call from AI
  Future<ToolExecutionResult> executeToolCall(ToolCall toolCall) async {
    final executor = _ref.read(toolExecutorProvider);
    
    return await executor.execute(
      serverId: toolCall.serverId!,
      toolName: toolCall.name,
      arguments: toolCall.arguments,
    );
  }
}

final portkeyClientProvider = Provider<PortkeyClient>((ref) {
  final dio = ref.watch(dioProvider);
  return PortkeyClient(dio, ref);
});
```

### lib/features/chat/data/services/chat_service.dart

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/providers.dart';
import '../models/chat_models.dart';
import 'portkey_client.dart';

class ChatService {
  final PortkeyClient _portkeyClient;
  final Ref _ref;

  ChatService(this._portkeyClient, this._ref);

  // Send message and handle AI response
  Stream<ChatMessage> sendMessage({
    required String content,
    required List<ChatMessage> conversationHistory,
  }) async* {
    // Create user message
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    );

    yield userMessage;

    // Build tool context from connected servers
    final toolContext = _buildToolContext();

    // Add to conversation
    final messages = [...conversationHistory, userMessage];

    // Get AI response
    final aiStream = await _portkeyClient.sendMessage(
      messages: messages,
      toolContext: toolContext,
    );

    await for (final message in aiStream) {
      // Handle tool calls
      if (message.toolCalls != null && message.toolCalls!.isNotEmpty) {
        yield message;

        // Execute each tool call
        for (final toolCall in message.toolCalls!) {
          yield ChatMessage(
            id: const Uuid().v4(),
            role: MessageRole.tool,
            content: '',
            toolCalls: [toolCall],
            timestamp: DateTime.now(),
          );

          try {
            final result = await _portkeyClient.executeToolCall(toolCall);
            
            yield ChatMessage(
              id: const Uuid().v4(),
              role: MessageRole.tool,
              content: '',
              toolOutput: result.toJson(),
              timestamp: DateTime.now(),
            );
          } catch (e) {
            yield ChatMessage(
              id: const Uuid().v4(),
              role: MessageRole.tool,
              content: 'Error: $e',
              timestamp: DateTime.now(),
            );
          }
        }

        // Get AI response with tool results
        final updatedMessages = [...messages, message];
        final aiResponseStream = await _portkeyClient.sendMessage(
          messages: updatedMessages,
          toolContext: toolContext,
        );

        await for (final response in aiResponseStream) {
          yield response;
        }
      } else {
        // Regular AI message
        yield message;
      }
    }
  }

  // Build tool context from connected servers
  List<ToolFilterContext> _buildToolContext() {
    final servers = _ref.read(serversProvider);
    final tools = _ref.read(toolsProvider);

    final contexts = <ToolFilterContext>[];

    for (final server in servers) {
      if (!server.connected) continue;

      final serverTools = tools[server.id] ?? [];
      contexts.add(ToolFilterContext(
        serverId: server.id,
        serverName: server.name,
        toolNames: serverTools.map((t) => t.name).toList(),
      ));
    }

    return contexts;
  }

  // Clear conversation
  void clearConversation() {
    _ref.read(chatMessagesProvider.notifier).clearMessages();
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  final portkeyClient = ref.watch(portkeyClientProvider);
  return ChatService(portkeyClient, ref);
});
```

### lib/features/chat/presentation/providers/chat_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_models.dart';
import '../../data/services/chat_service.dart';

// Chat Messages Provider
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<ChatMessage> build() => [];

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }

  void removeMessage(String id) {
    state = state.where((m) => m.id != id).toList();
  }
}

// Chat Streaming State
@riverpod
class ChatStreaming extends _$ChatStreaming {
  @override
  bool build() => false;

  void setStreaming(bool streaming) {
    state = streaming;
  }
}

// Current Chat Session
@riverpod
class CurrentChatSession extends _$CurrentChatSession {
  @override
  AsyncValue<Stream<ChatMessage>?> build() => const AsyncValue.data(null);

  Future<void> startChat(String message) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final chatService = ref.read(chatServiceProvider);
      final history = ref.read(chatMessagesProvider);
      
      final stream = chatService.sendMessage(
        content: message,
        conversationHistory: history,
      );

      // Listen to stream and add messages
      final messages = ref.read(chatMessagesProvider.notifier);
      
      stream.listen(
        (message) {
          messages.addMessage(message);
        },
        onDone: () {
          ref.read(chatStreamingProvider.notifier).setStreaming(false);
        },
        onError: (error) {
          ref.read(chatStreamingProvider.notifier).setStreaming(false);
        },
      );

      return stream;
    });
  }

  void stopChat() {
    state = const AsyncValue.data(null);
    ref.read(chatStreamingProvider.notifier).setStreaming(false);
  }
}
```

### lib/features/chat/presentation/widgets/hybrid_interface.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import 'chat_message_bubble.dart';
import 'chat_input_field.dart';

class HybridInterface extends ConsumerWidget {
  const HybridInterface({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider);
    final isStreaming = ref.watch(chatStreamingProvider);

    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildHeader(context, ref),

          // Messages
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ChatMessageBubble(
                        message: message,
                        isStreaming: isStreaming && index == messages.length - 1,
                      );
                    },
                  ),
          ),

          // Input Field
          ChatInputField(
            onSend: (message) {
              ref.read(currentChatSessionProvider.notifier).startChat(message);
              ref.read(chatStreamingProvider.notifier).setStreaming(true);
            },
            isEnabled: !isStreaming,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
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
          const Icon(Icons.chat, size: 24),
          const SizedBox(width: 12),
          Text(
            'Chat with AI',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              ref.read(chatMessagesProvider.notifier).clearMessages();
            },
            tooltip: 'Clear conversation',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me to execute tools or help you with MCP servers',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

### lib/features/chat/presentation/widgets/chat_message_bubble.dart

```dart
import 'package:flutter/material.dart';
import '../../data/models/chat_models.dart';
import '../../../../shared/widgets/json_viewer.dart';
import '../../../../shared/widgets/markdown_renderer.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isStreaming;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isTool = message.role == MessageRole.tool;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: _getAvatarColor(context, message.role),
              child: Icon(_getAvatarIcon(message.role)),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getBubbleColor(context, message.role),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isTool && message.toolCalls != null)
                        ...message.toolCalls!.map((toolCall) => _buildToolCall(context, toolCall)),
                      if (isTool && message.toolOutput != null)
                        _buildToolOutput(context, message.toolOutput!),
                      if (!isTool)
                        MarkdownRenderer(content: message.content),
                      if (isStreaming)
                        const SizedBox(height: 8),
                      if (isStreaming)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolCall(BuildContext context, ToolCall toolCall) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.extension, size: 16),
              const SizedBox(width: 4),
              Text(
                toolCall.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (toolCall.arguments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: JsonViewer(data: toolCall.arguments),
            ),
        ],
      ),
    );
  }

  Widget _buildToolOutput(BuildContext context, Map<String, dynamic> output) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: output.containsKey('error')
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: JsonViewer(data: output),
    );
  }

  Color _getAvatarColor(BuildContext context, MessageRole role) {
    switch (role) {
      case MessageRole.assistant:
        return Theme.of(context).colorScheme.primary;
      case MessageRole.tool:
        return Theme.of(context).colorScheme.secondary;
      default:
        return Colors.grey;
    }
  }

  IconData _getAvatarIcon(MessageRole role) {
    switch (role) {
      case MessageRole.assistant:
        return Icons.smart_toy;
      case MessageRole.tool:
        return Icons.build;
      default:
        return Icons.help;
    }
  }

  Color _getBubbleColor(BuildContext context, MessageRole role) {
    switch (role) {
      case MessageRole.user:
        return Theme.of(context).colorScheme.primaryContainer;
      case MessageRole.assistant:
        return Theme.of(context).colorScheme.surfaceVariant;
      case MessageRole.tool:
        return Theme.of(context).colorScheme.secondaryContainer;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
```

### lib/features/chat/presentation/widgets/chat_input_field.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatInputField extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool isEnabled;

  const ChatInputField({
    super.key,
    required this.onSend,
    this.isEnabled = true,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _controller = TextEditingController();
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isEmpty = _controller.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final message = _controller.text.trim();
    if (message.isEmpty || !widget.isEnabled) return;

    widget.onSend(message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Mention button for tool selection
          IconButton(
            icon: const Icon(Icons.at_alternate),
            onPressed: widget.isEnabled
                ? () {
                    // Show tool selection menu
                  }
                : null,
            tooltip: 'Mention tool',
          ),
          
          // Text input
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.isEnabled,
              maxLines: null,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Send button
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isEmpty || !widget.isEnabled ? null : _handleSend,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Tool Mention Feature

### lib/features/chat/presentation/widgets/mention_input.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/providers.dart';

class MentionInput extends ConsumerWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onToolSelected;

  const MentionInput({
    super.key,
    required this.controller,
    this.onToolSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tools = ref.watch(currentToolsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Type @ to mention tools...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) {
        // Check for @ mention
        if (value.contains('@')) {
          // Show tool suggestions
        }
      },
    );
  }
}
```

## Testing

### test/features/chat/chat_service_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hoot_flutter/features/chat/data/services/chat_service.dart';

class MockPortkeyClient extends Mock implements PortkeyClient {}

void main() {
  late ChatService chatService;
  late MockPortkeyClient mockPortkeyClient;

  setUp(() {
    mockPortkeyClient = MockPortkeyClient();
    chatService = ChatService(mockPortkeyClient, MockRef());
  });

  group('ChatService', () {
    test('sendMessage returns stream of messages', () async {
      final stream = Stream.value(
        ChatMessage(
          id: '1',
          role: MessageRole.assistant,
          content: 'Test response',
          timestamp: DateTime.now(),
        ),
      );

      when(mockPortkeyClient.sendMessage(
        messages: anyNamed('messages'),
        toolContext: anyNamed('toolContext'),
      )).thenAnswer((_) async => stream);

      final messages = await chatService.sendMessage(
        content: 'Hello',
        conversationHistory: [],
      ).toList();

      expect(messages.length, 1);
      expect(messages.first.role, MessageRole.assistant);
    });
  });
}
```

## Migration Checklist

- [ ] Implement ChatMessage and ToolCall models
- [ ] Implement PortkeyClient for AI integration
- [ ] Implement ChatService for message handling
- [ ] Implement chat state providers
- [ ] Create HybridInterface widget
- [ ] Create ChatMessageBubble widget
- [ ] Create ChatInputField widget
- [ ] Implement tool mention feature
- [ ] Add streaming support for AI responses
- [ ] Implement tool execution from chat
- [ ] Add conversation persistence
- [ ] Test end-to-end chat flow
- [ ] Test tool execution from AI

## Next Steps

1. Review `08-themes-styling.md` for theme system implementation
2. Implement conversation history with pagination
3. Add support for tool output formatting
4. Implement chat export/import
