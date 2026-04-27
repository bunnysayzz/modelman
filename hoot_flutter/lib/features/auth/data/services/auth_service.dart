import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/local_storage_service.dart';

/// Handles OAuth 2.1 flows: PKCE code generation, authorization URL
/// construction, code exchange, and token storage.
class AuthService {
  final ApiService _api;
  final LocalStorageService _storage;

  AuthService(this._api, this._storage);

  /// Generates a cryptographic random string for OAuth state / verifier.
  String _generateRandom(int length) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Generates a PKCE code verifier.
  String generateCodeVerifier() => _generateRandom(64);

  /// Generates a PKCE code challenge from the verifier.
  String generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Constructs the full OAuth authorization URL.
  String buildAuthorizationUrl({
    required String authorizationEndpoint,
    required String clientId,
    required String redirectUri,
    required String codeChallenge,
    required String state,
    String? scope,
  }) {
    final params = {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'state': state,
      if (scope != null) 'scope': scope,
    };

    final uri = Uri.parse(authorizationEndpoint)
        .replace(queryParameters: params);
    return uri.toString();
  }

  /// Exchanges an authorization code for tokens via the backend.
  Future<Map<String, dynamic>> exchangeCode({
    required String serverId,
    required String authorizationCode,
  }) async {
    final result = await _api.connectToServer(
      serverId: serverId,
      serverName: '',
      url: '',
      transport: '',
      authorizationCode: authorizationCode,
    );
    return result;
  }

  /// Gets the stored auth token.
  Future<String?> getToken() async {
    return await _storage.getAuthToken();
  }

  /// Stores the auth token.
  Future<void> setToken(String token) async {
    await _storage.setAuthToken(token);
  }

  /// Clears the auth token (logout).
  Future<void> clearToken() async {
    await _storage.clearAuthToken();
  }

  /// Checks if the user is authenticated.
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Gets or creates a user ID for anonymous auth.
  Future<String> ensureUserId() async {
    final existing = await _storage.getUserId();
    if (existing != null && existing.isNotEmpty) return existing;

    final newId = _generateRandom(16);
    await _storage.setUserId(newId);
    return newId;
  }

  /// Gets an auth token from the backend.
  Future<String> authenticate() async {
    final userId = await ensureUserId();
    final token = await _api.getAuthToken(userId);
    await setToken(token);
    return token;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final api = ref.watch(apiServiceProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return AuthService(api, storage);
});
