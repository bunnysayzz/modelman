import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../models/server_model.dart';

/// Repository that bridges the [ApiService] with server state management.
///
/// Converts raw API responses into typed [ServerConfig] objects and
/// manages the mapping between server IDs and their configurations.
class ServerRepository {
  final ApiService _api;

  ServerRepository(this._api);

  Future<Map<String, dynamic>> autoDetect(String url) async {
    return await _api.autoDetectServer(url);
  }

  Future<ServerConfig> connect(ServerConfig server) async {
    await _api.connectToServer(
      serverId: server.id,
      serverName: server.name,
      url: server.url,
      transport: server.transport,
      auth: server.auth?.toJson(),
    );

    return server.copyWith(
      connected: true,
      error: null,
      lastConnected: DateTime.now(),
    );
  }

  Future<void> disconnect(String serverId) async {
    await _api.disconnectFromServer(serverId);
  }

  Future<bool> getStatus(String serverId) async {
    return await _api.getConnectionStatus(serverId);
  }

  Future<Map<String, dynamic>> getServerInfo(String serverId) async {
    return await _api.getServerInfo(serverId);
  }

  Future<Map<String, dynamic>?> getOAuthMetadata(String serverId) async {
    return await _api.getOAuthMetadata(serverId);
  }

  Future<String> getFavicon(String serverUrl, {String? oauthLogoUri}) async {
    return await _api.getFavicon(
      serverUrl: serverUrl,
      oauthLogoUri: oauthLogoUri,
    );
  }
}

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ServerRepository(api);
});
