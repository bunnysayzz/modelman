import 'package:flutter_test/flutter_test.dart';
import 'package:modelman_flutter/features/servers/data/models/server_model.dart';

/// Tests for the ServerConfig and AuthConfig models.
void main() {
  group('ServerConfig', () {
    test('creates with required fields and defaults', () {
      final server = ServerConfig(
        id: 'srv-1',
        name: 'Test Server',
        url: 'http://localhost:3000',
      );

      expect(server.id, 'srv-1');
      expect(server.name, 'Test Server');
      expect(server.url, 'http://localhost:3000');
      expect(server.transport, ''); // default
      expect(server.connected, false); // default
      expect(server.error, isNull);
      expect(server.faviconUrl, isNull);
      expect(server.lastConnected, isNull);
      expect(server.auth, isNull);
    });

    test('creates with all fields', () {
      final now = DateTime.now();
      final server = ServerConfig(
        id: 'srv-2',
        name: 'Full Server',
        url: 'https://api.example.com',
        transport: 'sse',
        connected: true,
        error: null,
        faviconUrl: 'https://example.com/icon.png',
        lastConnected: now,
        auth: AuthConfig(type: 'bearer', bearerToken: 'tok_123'),
      );

      expect(server.transport, 'sse');
      expect(server.connected, true);
      expect(server.faviconUrl, 'https://example.com/icon.png');
      expect(server.lastConnected, now);
      expect(server.auth?.type, 'bearer');
    });

    test('copyWith updates specific fields', () {
      final server = ServerConfig(
        id: 'srv-3',
        name: 'Original',
        url: 'http://localhost:3000',
      );

      final updated = server.copyWith(
        connected: true,
        error: null,
        lastConnected: DateTime(2026, 1, 1),
      );

      expect(updated.id, 'srv-3'); // unchanged
      expect(updated.name, 'Original'); // unchanged
      expect(updated.connected, true); // changed
      expect(updated.lastConnected, DateTime(2026, 1, 1)); // changed
    });

    test('copyWith can set error', () {
      final server = ServerConfig(
        id: 'srv-4',
        name: 'Failing',
        url: 'http://bad-host:9999',
      );

      final failed = server.copyWith(
        connected: false,
        error: 'Connection refused',
      );

      expect(failed.connected, false);
      expect(failed.error, 'Connection refused');
    });

    test('serializes to JSON', () {
      final server = ServerConfig(
        id: 'srv-5',
        name: 'JSON Test',
        url: 'http://localhost:3000',
        transport: 'http',
        connected: true,
      );

      final json = server.toJson();

      expect(json['id'], 'srv-5');
      expect(json['name'], 'JSON Test');
      expect(json['url'], 'http://localhost:3000');
      expect(json['transport'], 'http');
      expect(json['connected'], true);
    });

    test('deserializes from JSON', () {
      final json = {
        'id': 'srv-6',
        'name': 'From JSON',
        'url': 'http://localhost:4000',
        'transport': 'sse',
        'connected': false,
      };

      final server = ServerConfig.fromJson(json);

      expect(server.id, 'srv-6');
      expect(server.name, 'From JSON');
      expect(server.transport, 'sse');
    });
  });

  group('AuthConfig', () {
    test('creates OAuth config', () {
      final auth = AuthConfig(
        type: 'oauth',
        clientId: 'client_123',
        authorizationUrl: 'https://auth.example.com/authorize',
        tokenUrl: 'https://auth.example.com/token',
        redirectUri: 'modelman://oauth/callback',
        scopes: ['read', 'write'],
      );

      expect(auth.type, 'oauth');
      expect(auth.clientId, 'client_123');
      expect(auth.scopes, ['read', 'write']);
    });

    test('creates API key config', () {
      final auth = AuthConfig(
        type: 'api_key',
        apiKey: 'sk-abc123',
      );

      expect(auth.type, 'api_key');
      expect(auth.apiKey, 'sk-abc123');
    });

    test('creates bearer token config', () {
      final auth = AuthConfig(
        type: 'bearer',
        bearerToken: 'eyJhbGciOiJIUzI1NiJ9...',
      );

      expect(auth.type, 'bearer');
      expect(auth.bearerToken, isNotEmpty);
    });

    test('serializes to JSON', () {
      final auth = AuthConfig(
        type: 'api_key',
        apiKey: 'test-key',
      );

      final json = auth.toJson();

      expect(json['type'], 'api_key');
      expect(json['apiKey'], 'test-key');
    });
  });

  group('ServerConnectionStatus', () {
    test('has all expected values', () {
      expect(ServerConnectionStatus.values,
          contains(ServerConnectionStatus.disconnected));
      expect(ServerConnectionStatus.values,
          contains(ServerConnectionStatus.connecting));
      expect(ServerConnectionStatus.values,
          contains(ServerConnectionStatus.connected));
      expect(ServerConnectionStatus.values,
          contains(ServerConnectionStatus.error));
    });
  });
}
