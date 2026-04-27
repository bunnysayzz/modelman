import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Connection status for the WebSocket client.
enum WebSocketStatus { connected, disconnected, connecting, error }

/// Manages a WebSocket connection to the backend, exposing
/// message and status streams for reactive consumption.
class WebSocketClient {
  WebSocketChannel? _channel;
  final _messageController = StreamController<String>.broadcast();
  final _statusController = StreamController<WebSocketStatus>.broadcast();

  WebSocketStatus _currentStatus = WebSocketStatus.disconnected;

  /// Stream of incoming messages from the WebSocket server.
  Stream<String> get messages => _messageController.stream;

  /// Stream of connection status changes.
  Stream<WebSocketStatus> get status => _statusController.stream;

  /// The current connection status.
  WebSocketStatus get currentStatus => _currentStatus;

  /// Opens a WebSocket connection to [url].
  void connect(String url) {
    if (_currentStatus == WebSocketStatus.connecting ||
        _currentStatus == WebSocketStatus.connected) {
      return;
    }

    _setStatus(WebSocketStatus.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (data) {
          _setStatus(WebSocketStatus.connected);
          _messageController.add(data as String);
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _setStatus(WebSocketStatus.error);
        },
        onDone: () {
          _setStatus(WebSocketStatus.disconnected);
        },
      );
    } catch (e) {
      debugPrint('WebSocket connect failed: $e');
      _setStatus(WebSocketStatus.error);
    }
  }

  /// Sends a [message] through the open WebSocket connection.
  void send(String message) {
    if (_currentStatus != WebSocketStatus.connected) {
      debugPrint('WebSocket not connected — cannot send message.');
      return;
    }
    _channel?.sink.add(message);
  }

  /// Closes the WebSocket connection gracefully.
  void disconnect() {
    _channel?.sink.close();
    _setStatus(WebSocketStatus.disconnected);
  }

  /// Releases all resources. Call when the provider is disposed.
  void dispose() {
    disconnect();
    _messageController.close();
    _statusController.close();
  }

  void _setStatus(WebSocketStatus newStatus) {
    _currentStatus = newStatus;
    if (!_statusController.isClosed) {
      _statusController.add(newStatus);
    }
  }
}

/// Provides a singleton [WebSocketClient] that is disposed when
/// no longer referenced.
final webSocketClientProvider = Provider<WebSocketClient>((ref) {
  final client = WebSocketClient();
  ref.onDispose(() => client.dispose());
  return client;
});
