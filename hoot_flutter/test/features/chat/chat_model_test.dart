import 'package:flutter_test/flutter_test.dart';
import 'package:hoot_flutter/features/chat/data/models/chat_model.dart';

/// Tests for the ChatMessage model and ChatRole enum.
void main() {
  group('ChatRole', () {
    test('has all expected values', () {
      expect(ChatRole.values, contains(ChatRole.user));
      expect(ChatRole.values, contains(ChatRole.assistant));
      expect(ChatRole.values, contains(ChatRole.system));
      expect(ChatRole.values, contains(ChatRole.tool));
      expect(ChatRole.values, contains(ChatRole.error));
      expect(ChatRole.values.length, 5);
    });
  });

  group('ChatMessage', () {
    test('creates with required fields', () {
      final msg = ChatMessage(
        id: 'test-1',
        role: ChatRole.user,
        content: 'Hello world',
        timestamp: DateTime(2026, 1, 1),
      );

      expect(msg.id, 'test-1');
      expect(msg.role, ChatRole.user);
      expect(msg.content, 'Hello world');
      expect(msg.isStreaming, false); // default
      expect(msg.toolName, isNull);
      expect(msg.toolResult, isNull);
    });

    test('creates with optional fields', () {
      final msg = ChatMessage(
        id: 'test-2',
        role: ChatRole.tool,
        content: 'Tool result',
        timestamp: DateTime(2026, 1, 1),
        toolName: 'get_weather',
        toolResult: {'temp': 72, 'unit': 'F'},
        isStreaming: true,
      );

      expect(msg.toolName, 'get_weather');
      expect(msg.toolResult, {'temp': 72, 'unit': 'F'});
      expect(msg.isStreaming, true);
    });

    test('creates error role message', () {
      final msg = ChatMessage(
        id: 'err-1',
        role: ChatRole.error,
        content: 'Cannot connect to server',
        timestamp: DateTime(2026, 1, 1),
      );

      expect(msg.role, ChatRole.error);
      expect(msg.content, contains('Cannot connect'));
    });

    test('serializes to JSON', () {
      final msg = ChatMessage(
        id: 'json-1',
        role: ChatRole.user,
        content: 'Test message',
        timestamp: DateTime(2026, 1, 1, 12, 30),
      );

      final json = msg.toJson();

      expect(json['id'], 'json-1');
      expect(json['role'], 'user');
      expect(json['content'], 'Test message');
      expect(json['isStreaming'], false);
    });

    test('deserializes from JSON', () {
      final json = {
        'id': 'json-2',
        'role': 'assistant',
        'content': 'Response text',
        'timestamp': '2026-01-01T12:30:00.000',
        'isStreaming': false,
      };

      final msg = ChatMessage.fromJson(json);

      expect(msg.id, 'json-2');
      expect(msg.role, ChatRole.assistant);
      expect(msg.content, 'Response text');
    });

    test('copyWith preserves values', () {
      final original = ChatMessage(
        id: 'copy-1',
        role: ChatRole.user,
        content: 'Original',
        timestamp: DateTime(2026, 1, 1),
      );

      final modified = original.copyWith(content: 'Modified');

      expect(modified.id, 'copy-1'); // unchanged
      expect(modified.role, ChatRole.user); // unchanged
      expect(modified.content, 'Modified'); // changed
    });
  });

  group('ChatStatus', () {
    test('has all expected values', () {
      expect(ChatStatus.values, contains(ChatStatus.idle));
      expect(ChatStatus.values, contains(ChatStatus.sending));
      expect(ChatStatus.values, contains(ChatStatus.streaming));
      expect(ChatStatus.values, contains(ChatStatus.error));
    });
  });
}
