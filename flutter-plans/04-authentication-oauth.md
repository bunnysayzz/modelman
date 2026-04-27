# Authentication & OAuth Implementation

## Overview

This document details the authentication and OAuth 2.1 implementation for Flutter, mapping from the current React implementation.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                   Authentication Flow                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │   Flutter    │      │  OAuth 2.1   │      │   Backend   │ │
│  │     App      │      │   Provider   │      │   Server    │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                       │                      │     │
│         │ 1. Initiate OAuth     │                      │     │
│         ├──────────────────────►│                      │     │
│         │                       │                      │     │
│         │ 2. Redirect to auth   │                      │     │
│         │◄──────────────────────┤                      │     │
│         │                       │                      │     │
│         │ 3. User authorizes    │                      │     │
│         ├──────────────────────►│                      │     │
│         │                       │                      │     │
│         │ 4. Callback with code │                      │     │
│         │◄──────────────────────┤                      │     │
│         │                       │                      │     │
│         │ 5. Exchange for token │                      │     │
│         ├──────────────────────────────────────────────►│     │
│         │                       │                      │     │
│         │ 6. Receive JWT        │                      │     │
│         │◄──────────────────────────────────────────────┤     │
│         │                       │                      │     │
│         │ 7. Store token securely                      │     │
│         ▼                       │                      │     │
│  ┌──────────────┐              │                      │     │
│  │  Secure      │              │                      │     │
│  │  Storage     │              │                      │     │
│  └──────────────┘              │                      │     │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Current React Implementation

### src/lib/oauthProvider.ts

```typescript
// Current React OAuth flow using window.location and callbacks
export function initiateOAuthFlow(config: OAuthConfig): Promise<string> {
  // Generate state and verifier
  const state = generateState();
  const verifier = generateCodeVerifier();
  
  // Store verifier
  sessionStorage.setItem(`oauth_verifier_${serverId}`, verifier);
  
  // Construct authorization URL
  const authUrl = constructAuthUrl(config, verifier, state);
  
  // Redirect
  window.location.href = authUrl;
  
  return Promise.resolve(state);
}

export function handleOAuthCallback(
  code: string,
  state: string
): Promise<OAuthToken> {
  // Retrieve verifier
  const verifier = sessionStorage.getItem(`oauth_verifier_${serverId}`);
  
  // Exchange code for token
  return exchangeCodeForToken(code, verifier);
}
```

## Flutter Implementation

### lib/features/auth/data/repositories/oauth_repository.dart

```dart
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class OAuthRepository {
  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _secureStorage;

  OAuthRepository(this._appAuth, this._secureStorage);

  // Generate random state for CSRF protection
  String _generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Generate code verifier (PKCE)
  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  // Generate code challenge from verifier
  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }

  // Initiate OAuth 2.1 flow
  Future<AuthorizationResponse> initiateOAuthFlow({
    required String authorizationEndpoint,
    required String tokenEndpoint,
    required String clientId,
    String? redirectUrl,
    List<String>? scopes,
  }) async {
    final state = _generateState();
    final verifier = _generateCodeVerifier();
    final challenge = _generateCodeChallenge(verifier);

    // Store verifier for later token exchange
    await _secureStorage.write(
      key: 'oauth_verifier',
      value: verifier,
    );
    await _secureStorage.write(
      key: 'oauth_state',
      value: state,
    );

    // Configure authorization request
    final authorizationRequest = AuthorizationRequest(
      clientId: clientId,
      redirectUrl: redirectUrl ?? 'modelman://oauth/callback',
      discoveryUrl: '',
      scopes: scopes ?? ['openid', 'profile'],
      additionalParameters: {
        'state': state,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
        'response_type': 'code',
      },
    );

    // Initiate flow
    try {
      final result = await _appAuth.authorize(authorizationRequest);
      return result;
    } catch (e) {
      throw OAuthException('Authorization failed: $e');
    }
  }

  // Exchange authorization code for token
  Future<TokenResponse> exchangeCodeForToken({
    required String authorizationEndpoint,
    required String tokenEndpoint,
    required String clientId,
    required String authorizationCode,
    String? redirectUrl,
  }) async {
    final verifier = await _secureStorage.read(key: 'oauth_verifier');
    if (verifier == null) {
      throw OAuthException('Code verifier not found');
    }

    final tokenRequest = TokenRequest(
      clientId: clientId,
      redirectUrl: redirectUrl ?? 'modelman://oauth/callback',
      authorizationCode: authorizationCode,
      codeVerifier: verifier,
      discoveryUrl: '',
      scopes: ['openid', 'profile'],
    );

    try {
      final result = await _appAuth.token(tokenRequest);
      
      // Clear verifier after use
      await _secureStorage.delete(key: 'oauth_verifier');
      
      return result;
    } catch (e) {
      throw OAuthException('Token exchange failed: $e');
    }
  }

  // Refresh token
  Future<TokenResponse> refreshToken({
    required String tokenEndpoint,
    required String clientId,
    required String refreshToken,
  }) async {
    final tokenRequest = TokenRequest(
      clientId: clientId,
      redirectUrl: 'modelman://oauth/callback',
      refreshToken: refreshToken,
      discoveryUrl: '',
      scopes: ['openid', 'profile'],
    );

    try {
      final result = await _appAuth.token(tokenRequest);
      return result;
    } catch (e) {
      throw OAuthException('Token refresh failed: $e');
    }
  }

  // Clear OAuth data
  Future<void> clearOAuthData() async {
    await _secureStorage.delete(key: 'oauth_verifier');
    await _secureStorage.delete(key: 'oauth_state');
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }
}

class OAuthException implements Exception {
  final String message;
  OAuthException(this.message);
}

final oauthRepositoryProvider = Provider<OAuthRepository>((ref) {
  return OAuthRepository(
    FlutterAppAuth(),
    const FlutterSecureStorage(),
  );
});
```

## Backend Token Management

### lib/features/auth/data/repositories/auth_repository.dart

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/local_storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorage;

  AuthRepository(this._apiService, this._localStorage);

  // Generate or retrieve user ID
  Future<String> getUserId() async {
    String? userId = await _localStorage.getUserId();
    
    if (userId == null) {
      userId = const Uuid().v4();
      await _localStorage.setUserId(userId);
    }
    
    return userId;
  }

  // Get session token from backend
  Future<AuthToken> getSessionToken() async {
    final userId = await getUserId();
    final token = await _apiService.getAuthToken(userId);
    
    await _localStorage.setAuthToken(token);
    
    return AuthToken(
      token: token,
      userId: userId,
      tokenType: 'jwt',
    );
  }

  // Refresh session token
  Future<AuthToken> refreshSessionToken() async {
    return await getSessionToken();
  }

  // Clear auth data
  Future<void> clearAuth() async {
    await _localStorage.clearAuthToken();
  }
}

class AuthToken {
  final String token;
  final String userId;
  final String tokenType;

  AuthToken({
    required this.token,
    required this.userId,
    required this.tokenType,
  });
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return AuthRepository(apiService, localStorage);
});
```

## OAuth Callback Handler

### lib/features/auth/presentation/pages/oauth_callback_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/oauth_repository.dart';

class OAuthCallbackPage extends ConsumerStatefulWidget {
  final Map<String, String> params;

  const OAuthCallbackPage({super.key, required this.params});

  @override
  ConsumerState<OAuthCallbackPage> createState() => _OAuthCallbackPageState();
}

class _OAuthCallbackPageState extends ConsumerState<OAuthCallbackPage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    final code = widget.params['code'];
    final state = widget.params['state'];
    final serverId = widget.params['server_id'];

    if (code == null) {
      setState(() {
        _isLoading = false;
        _error = 'No authorization code received';
      });
      return;
    }

    try {
      // Exchange code for token
      final oauthRepo = ref.read(oauthRepositoryProvider);
      
      // You'll need to store OAuth config before redirecting
      // and retrieve it here
      final tokenResponse = await oauthRepo.exchangeCodeForToken(
        authorizationEndpoint: '', // Retrieve from storage
        tokenEndpoint: '',
        clientId: '',
        authorizationCode: code,
      );

      // Store token securely
      // Navigate back to servers page
      if (mounted) {
        context.go('/servers');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'OAuth callback failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/servers'),
                        child: const Text('Go Back'),
                      ),
                    ],
                  )
                : const SizedBox(),
      ),
    );
  }
}
```

## Deep Link Configuration

### Android Configuration

#### android/app/src/main/AndroidManifest.xml

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">
    
    <!-- OAuth Deep Link -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="modelman"
            android:host="oauth"
            android:path="/callback" />
    </intent-filter>
</activity>
```

### iOS Configuration

#### ios/Runner/Info.plist

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.portkeyai.modelman</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>modelman</string>
        </array>
    </dict>
</array>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## OAuth Configuration UI

### lib/features/servers/presentation/widgets/oauth_config_form.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/oauth_repository.dart';

class OAuthConfigForm extends ConsumerStatefulWidget {
  final String serverId;
  final String serverUrl;

  const OAuthConfigForm({
    super.key,
    required this.serverId,
    required this.serverUrl,
  });

  @override
  ConsumerState<OAuthConfigForm> createState() => _OAuthConfigFormState();
}

class _OAuthConfigFormState extends ConsumerState<OAuthConfigForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OAuth Configuration'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Client ID',
                hintText: 'Enter OAuth client ID',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Client ID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Client Secret (if required)',
                hintText: 'Enter OAuth client secret',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Scopes',
                hintText: 'e.g., openid profile email',
              ),
              initialValue: 'openid profile',
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _initiateOAuth,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Connect with OAuth'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initiateOAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final oauthRepo = ref.read(oauthRepositoryProvider);
      
      // You'll need to get OAuth metadata from the server first
      // to get the authorization and token endpoints
      
      final result = await oauthRepo.initiateOAuthFlow(
        authorizationEndpoint: '', // From server metadata
        tokenEndpoint: '',
        clientId: '', // From form
        scopes: ['openid', 'profile'],
      );

      // The OAuth flow will redirect to the callback
      // Handle the callback in OAuthCallbackPage
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'OAuth initiation failed: $e';
      });
    }
  }
}
```

## JWT Token Handling

### lib/features/auth/data/services/jwt_service.dart

```dart
import 'package:jose/jose.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JwtService {
  // Decode JWT token (without verification - verification done by backend)
  Map<String, dynamic> decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid JWT token');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = base64Url.decode(normalized);
    final jsonString = String.fromCharCodes(decoded);
    
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  // Check if token is expired
  bool isTokenExpired(String token) {
    try {
      final payload = decodeToken(token);
      final exp = payload['exp'] as int?;
      if (exp == null) return false;
      
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }

  // Get user ID from token
  String? getUserIdFromToken(String token) {
    try {
      final payload = decodeToken(token);
      return payload['sub'] as String?;
    } catch (e) {
      return null;
    }
  }

  // Get token expiry time
  DateTime? getTokenExpiry(String token) {
    try {
      final payload = decodeToken(token);
      final exp = payload['exp'] as int?;
      if (exp == null) return null;
      
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      return null;
    }
  }
}

final jwtServiceProvider = Provider<JwtService>((ref) {
  return JwtService();
});
```

## Authentication Provider

### lib/features/auth/presentation/providers/auth_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

class AuthNotifier extends StateNotifier<AsyncValue<AuthToken?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null)) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Check if we have a stored token
    final token = await _repository._localStorage.getAuthToken();
    if (token != null) {
      // Validate token
      final jwt = ref.read(jwtServiceProvider);
      if (!jwt.isTokenExpired(token)) {
        state = AsyncValue.data(AuthToken(
          token: token,
          userId: jwt.getUserIdFromToken(token) ?? '',
          tokenType: 'jwt',
        ));
      } else {
        // Token expired, refresh
        await refreshSession();
      }
    } else {
      // No token, get new one
      await getSession();
    }
  }

  Future<void> getSession() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getSessionToken());
  }

  Future<void> refreshSession() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.refreshSessionToken());
  }

  Future<void> logout() async {
    await _repository.clearAuth();
    state = const AsyncValue.data(null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthToken?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
```

## Integration with API Client

### lib/core/network/dio_client.dart (Updated)

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final authState = ref.read(authProvider);
    final token = authState.value?.token;

    if (token != null) {
      // Check if token is expired
      final jwt = ref.read(jwtServiceProvider);
      if (jwt.isTokenExpired(token)) {
        // Refresh token
        await ref.read(authProvider.notifier).refreshSession();
        final newToken = ref.read(authProvider).value?.token;
        if (newToken != null) {
          options.headers[ApiConstants.authHeader] = newToken;
        }
      } else {
        options.headers[ApiConstants.authHeader] = token;
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token invalid, refresh and retry
      await ref.read(authProvider.notifier).refreshSession();
      
      // Retry the request
      final opts = err.requestOptions;
      final token = ref.read(authProvider).value?.token;
      if (token != null) {
        opts.headers[ApiConstants.authHeader] = token;
        try {
          final response = await Dio().fetch(opts);
          handler.resolve(response);
          return;
        } catch (e) {
          // Refresh failed, logout
          await ref.read(authProvider.notifier).logout();
        }
      }
    }
    handler.next(err);
  }
}
```

## Testing

### test/features/auth/oauth_repository_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:modelman_flutter/features/auth/data/repositories/oauth_repository.dart';

class MockFlutterAppAuth extends Mock implements FlutterAppAuth {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late OAuthRepository repository;
  late MockFlutterAppAuth mockAppAuth;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockAppAuth = MockFlutterAppAuth();
    mockStorage = MockFlutterSecureStorage();
    repository = OAuthRepository(mockAppAuth, mockStorage);
  });

  group('OAuthRepository', () {
    test('generateState produces valid state', () {
      final state = repository._generateState();
      expect(state, isNotEmpty);
      expect(state.length, greaterThanOrEqualTo(32));
    });

    test('generateCodeVerifier produces valid verifier', () {
      final verifier = repository._generateCodeVerifier();
      expect(verifier, isNotEmpty);
      expect(verifier.contains('='), false);
    });
  });
}
```

## Migration Checklist

- [ ] Set up flutter_appauth dependency
- [ ] Configure deep links for iOS and Android
- [ ] Implement OAuthRepository
- [ ] Implement AuthRepository for backend tokens
- [ ] Create OAuth callback handler
- [ ] Implement JWT token validation
- [ ] Add token refresh logic
- [ ] Integrate with API client interceptor
- [ ] Test OAuth flow end-to-end
- [ ] Test token refresh on expiry
- [ ] Test deep link handling

## Next Steps

1. Review `05-ui-components-core.md` for UI component implementation
2. Test OAuth flow on both iOS and Android
3. Implement secure token storage
4. Add comprehensive error handling for OAuth failures
