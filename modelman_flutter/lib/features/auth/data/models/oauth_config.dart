/// OAuth configuration model for a server.
class OAuthConfig {
  final String authorizationEndpoint;
  final String tokenEndpoint;
  final String clientId;
  final String? clientSecret;
  final String redirectUri;
  final String? scope;
  final String? state;

  OAuthConfig({
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.clientId,
    this.clientSecret,
    required this.redirectUri,
    this.scope,
    this.state,
  });

  factory OAuthConfig.fromJson(Map<String, dynamic> json) {
    return OAuthConfig(
      authorizationEndpoint: json['authorizationEndpoint'] ?? '',
      tokenEndpoint: json['tokenEndpoint'] ?? '',
      clientId: json['clientId'] ?? '',
      clientSecret: json['clientSecret'],
      redirectUri: json['redirectUri'] ?? '',
      scope: json['scope'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorizationEndpoint': authorizationEndpoint,
      'tokenEndpoint': tokenEndpoint,
      'clientId': clientId,
      if (clientSecret != null) 'clientSecret': clientSecret,
      'redirectUri': redirectUri,
      if (scope != null) 'scope': scope,
      if (state != null) 'state': state,
    };
  }

  OAuthConfig copyWith({
    String? authorizationEndpoint,
    String? tokenEndpoint,
    String? clientId,
    String? clientSecret,
    String? redirectUri,
    String? scope,
    String? state,
  }) {
    return OAuthConfig(
      authorizationEndpoint: authorizationEndpoint ?? this.authorizationEndpoint,
      tokenEndpoint: tokenEndpoint ?? this.tokenEndpoint,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      redirectUri: redirectUri ?? this.redirectUri,
      scope: scope ?? this.scope,
      state: state ?? this.state,
    );
  }
}
