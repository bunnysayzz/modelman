import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';

/// Auth state model.
class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for authentication state.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _auth;

  AuthNotifier(this._auth) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final isAuth = await _auth.isAuthenticated();
      if (isAuth) {
        final token = await _auth.getToken();
        final userId = await _auth.ensureUserId();
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          userId: userId,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Authenticate (anonymous or with existing token).
  Future<void> authenticate() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _auth.authenticate();
      final userId = await _auth.ensureUserId();
      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        userId: userId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Logout and clear token.
  Future<void> logout() async {
    await _auth.clearToken();
    state = const AuthState();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth = ref.watch(authServiceProvider);
  return AuthNotifier(auth);
});
