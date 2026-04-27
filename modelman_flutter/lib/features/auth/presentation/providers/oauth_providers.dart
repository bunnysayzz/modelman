import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/oauth_config.dart';
import '../../data/services/auth_service.dart';

/// OAuth flow state model.
class OAuthState {
  final bool isInitiating;
  final bool isProcessing;
  final String? authorizationUrl;
  final String? error;
  final OAuthConfig? config;

  const OAuthState({
    this.isInitiating = false,
    this.isProcessing = false,
    this.authorizationUrl,
    this.error,
    this.config,
  });

  OAuthState copyWith({
    bool? isInitiating,
    bool? isProcessing,
    String? authorizationUrl,
    String? error,
    OAuthConfig? config,
  }) {
    return OAuthState(
      isInitiating: isInitiating ?? this.isInitiating,
      isProcessing: isProcessing ?? this.isProcessing,
      authorizationUrl: authorizationUrl ?? this.authorizationUrl,
      error: error,
      config: config ?? this.config,
    );
  }
}

/// Notifier for OAuth flow management.
class OAuthNotifier extends StateNotifier<OAuthState> {
  final AuthService _auth;

  OAuthNotifier(this._auth) : super(const OAuthState());

  /// Initiates OAuth 2.1 PKCE flow.
  Future<String> initiateOAuth(OAuthConfig config) async {
    state = state.copyWith(isInitiating: true, error: null, config: config);

    try {
      // Generate PKCE code verifier and challenge
      final verifier = _auth.generateCodeVerifier();
      final challenge = _auth.generateCodeChallenge(verifier);
      final state = _auth.generateCodeVerifier();

      // Update config with state
      final updatedConfig = config.copyWith(state: state);

      // Build authorization URL
      final authUrl = _auth.buildAuthorizationUrl(
        authorizationEndpoint: updatedConfig.authorizationEndpoint,
        clientId: updatedConfig.clientId,
        redirectUri: updatedConfig.redirectUri,
        codeChallenge: challenge,
        state: state,
        scope: updatedConfig.scope,
      );

      state = state.copyWith(
        isInitiating: false,
        authorizationUrl: authUrl,
        config: updatedConfig,
      );

      return authUrl;
    } catch (e) {
      state = state.copyWith(
        isInitiating: false,
        error: 'Failed to initiate OAuth: ${e.toString()}',
      );
      throw e;
    }
  }

  /// Resets the OAuth state.
  void reset() {
    state = const OAuthState();
  }

  /// Sets processing state during token exchange.
  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  /// Sets an error state.
  void setError(String error) {
    state = state.copyWith(error: error, isProcessing: false);
  }
}

final oauthProvider = StateNotifierProvider<OAuthNotifier, OAuthState>((ref) {
  final auth = ref.watch(authServiceProvider);
  return OAuthNotifier(auth);
});
