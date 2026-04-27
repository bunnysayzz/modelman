import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/server_model.dart';
import '../../data/repositories/server_repository.dart';

const _uuid = Uuid();

/// Notifier managing the list of configured MCP servers.
class ServerListNotifier extends StateNotifier<List<ServerConfig>> {
  final ServerRepository _repository;

  ServerListNotifier(this._repository) : super([]);

  void addServer(ServerConfig server) {
    state = [...state, server];
  }

  void removeServer(String serverId) {
    state = state.where((s) => s.id != serverId).toList();
  }

  void updateServer(ServerConfig updated) {
    state = state.map((s) => s.id == updated.id ? updated : s).toList();
  }

  Future<void> connectServer(String serverId) async {
    final index = state.indexWhere((s) => s.id == serverId);
    if (index == -1) return;

    final server = state[index];
    updateServer(server.copyWith(connected: false, error: null));

    try {
      final connected = await _repository.connect(server);
      updateServer(connected);
    } catch (e) {
      updateServer(server.copyWith(
        connected: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> disconnectServer(String serverId) async {
    try {
      await _repository.disconnect(serverId);
      final index = state.indexWhere((s) => s.id == serverId);
      if (index != -1) {
        updateServer(state[index].copyWith(connected: false));
      }
    } catch (e) {
      // Keep UI in sync even if disconnect fails
      final index = state.indexWhere((s) => s.id == serverId);
      if (index != -1) {
        updateServer(state[index].copyWith(
          connected: false,
          error: e.toString(),
        ));
      }
    }
  }

  /// Creates a new server with a generated UUID and adds it.
  ServerConfig createServer({
    required String name,
    required String url,
    String transport = '',
    AuthConfig? auth,
  }) {
    final server = ServerConfig(
      id: _uuid.v4(),
      name: name,
      url: url,
      transport: transport,
      auth: auth,
    );
    addServer(server);
    return server;
  }

  void setServers(List<ServerConfig> servers) {
    state = servers;
  }
}

/// Provider for the list of all servers.
final serverListProvider =
    StateNotifierProvider<ServerListNotifier, List<ServerConfig>>((ref) {
  final repository = ref.watch(serverRepositoryProvider);
  return ServerListNotifier(repository);
});

/// The currently selected server ID.
final selectedServerIdProvider = StateProvider<String?>((ref) => null);

/// The currently selected [ServerConfig], derived from the server list
/// and selected ID.
final selectedServerProvider = Provider<ServerConfig?>((ref) {
  final servers = ref.watch(serverListProvider);
  final selectedId = ref.watch(selectedServerIdProvider);
  if (selectedId == null) return null;
  try {
    return servers.firstWhere((s) => s.id == selectedId);
  } catch (_) {
    return null;
  }
});

/// List of currently connected servers.
final connectedServersProvider = Provider<List<ServerConfig>>((ref) {
  final servers = ref.watch(serverListProvider);
  return servers.where((s) => s.connected).toList();
});
