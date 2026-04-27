// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServerConfig _$ServerConfigFromJson(Map<String, dynamic> json) {
  return _ServerConfig.fromJson(json);
}

/// @nodoc
mixin _$ServerConfig {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get transport => throw _privateConstructorUsedError;
  bool get connected => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get faviconUrl => throw _privateConstructorUsedError;
  DateTime? get lastConnected => throw _privateConstructorUsedError;
  AuthConfig? get auth => throw _privateConstructorUsedError;

  /// Serializes this ServerConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServerConfigCopyWith<ServerConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerConfigCopyWith<$Res> {
  factory $ServerConfigCopyWith(
          ServerConfig value, $Res Function(ServerConfig) then) =
      _$ServerConfigCopyWithImpl<$Res, ServerConfig>;
  @useResult
  $Res call(
      {String id,
      String name,
      String url,
      String transport,
      bool connected,
      String? error,
      String? faviconUrl,
      DateTime? lastConnected,
      AuthConfig? auth});

  $AuthConfigCopyWith<$Res>? get auth;
}

/// @nodoc
class _$ServerConfigCopyWithImpl<$Res, $Val extends ServerConfig>
    implements $ServerConfigCopyWith<$Res> {
  _$ServerConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServerConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? url = null,
    Object? transport = null,
    Object? connected = null,
    Object? error = freezed,
    Object? faviconUrl = freezed,
    Object? lastConnected = freezed,
    Object? auth = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      transport: null == transport
          ? _value.transport
          : transport // ignore: cast_nullable_to_non_nullable
              as String,
      connected: null == connected
          ? _value.connected
          : connected // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      faviconUrl: freezed == faviconUrl
          ? _value.faviconUrl
          : faviconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastConnected: freezed == lastConnected
          ? _value.lastConnected
          : lastConnected // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      auth: freezed == auth
          ? _value.auth
          : auth // ignore: cast_nullable_to_non_nullable
              as AuthConfig?,
    ) as $Val);
  }

  /// Create a copy of ServerConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthConfigCopyWith<$Res>? get auth {
    if (_value.auth == null) {
      return null;
    }

    return $AuthConfigCopyWith<$Res>(_value.auth!, (value) {
      return _then(_value.copyWith(auth: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ServerConfigImplCopyWith<$Res>
    implements $ServerConfigCopyWith<$Res> {
  factory _$$ServerConfigImplCopyWith(
          _$ServerConfigImpl value, $Res Function(_$ServerConfigImpl) then) =
      __$$ServerConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String url,
      String transport,
      bool connected,
      String? error,
      String? faviconUrl,
      DateTime? lastConnected,
      AuthConfig? auth});

  @override
  $AuthConfigCopyWith<$Res>? get auth;
}

/// @nodoc
class __$$ServerConfigImplCopyWithImpl<$Res>
    extends _$ServerConfigCopyWithImpl<$Res, _$ServerConfigImpl>
    implements _$$ServerConfigImplCopyWith<$Res> {
  __$$ServerConfigImplCopyWithImpl(
      _$ServerConfigImpl _value, $Res Function(_$ServerConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServerConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? url = null,
    Object? transport = null,
    Object? connected = null,
    Object? error = freezed,
    Object? faviconUrl = freezed,
    Object? lastConnected = freezed,
    Object? auth = freezed,
  }) {
    return _then(_$ServerConfigImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      transport: null == transport
          ? _value.transport
          : transport // ignore: cast_nullable_to_non_nullable
              as String,
      connected: null == connected
          ? _value.connected
          : connected // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      faviconUrl: freezed == faviconUrl
          ? _value.faviconUrl
          : faviconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastConnected: freezed == lastConnected
          ? _value.lastConnected
          : lastConnected // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      auth: freezed == auth
          ? _value.auth
          : auth // ignore: cast_nullable_to_non_nullable
              as AuthConfig?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServerConfigImpl implements _ServerConfig {
  const _$ServerConfigImpl(
      {required this.id,
      required this.name,
      required this.url,
      this.transport = '',
      this.connected = false,
      this.error,
      this.faviconUrl,
      this.lastConnected,
      this.auth});

  factory _$ServerConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServerConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String url;
  @override
  @JsonKey()
  final String transport;
  @override
  @JsonKey()
  final bool connected;
  @override
  final String? error;
  @override
  final String? faviconUrl;
  @override
  final DateTime? lastConnected;
  @override
  final AuthConfig? auth;

  @override
  String toString() {
    return 'ServerConfig(id: $id, name: $name, url: $url, transport: $transport, connected: $connected, error: $error, faviconUrl: $faviconUrl, lastConnected: $lastConnected, auth: $auth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.transport, transport) ||
                other.transport == transport) &&
            (identical(other.connected, connected) ||
                other.connected == connected) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.faviconUrl, faviconUrl) ||
                other.faviconUrl == faviconUrl) &&
            (identical(other.lastConnected, lastConnected) ||
                other.lastConnected == lastConnected) &&
            (identical(other.auth, auth) || other.auth == auth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, url, transport,
      connected, error, faviconUrl, lastConnected, auth);

  /// Create a copy of ServerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerConfigImplCopyWith<_$ServerConfigImpl> get copyWith =>
      __$$ServerConfigImplCopyWithImpl<_$ServerConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServerConfigImplToJson(
      this,
    );
  }
}

abstract class _ServerConfig implements ServerConfig {
  const factory _ServerConfig(
      {required final String id,
      required final String name,
      required final String url,
      final String transport,
      final bool connected,
      final String? error,
      final String? faviconUrl,
      final DateTime? lastConnected,
      final AuthConfig? auth}) = _$ServerConfigImpl;

  factory _ServerConfig.fromJson(Map<String, dynamic> json) =
      _$ServerConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get url;
  @override
  String get transport;
  @override
  bool get connected;
  @override
  String? get error;
  @override
  String? get faviconUrl;
  @override
  DateTime? get lastConnected;
  @override
  AuthConfig? get auth;

  /// Create a copy of ServerConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerConfigImplCopyWith<_$ServerConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthConfig _$AuthConfigFromJson(Map<String, dynamic> json) {
  return _AuthConfig.fromJson(json);
}

/// @nodoc
mixin _$AuthConfig {
  String get type =>
      throw _privateConstructorUsedError; // 'oauth', 'api_key', 'bearer', 'none'
  String? get clientId => throw _privateConstructorUsedError;
  String? get clientSecret => throw _privateConstructorUsedError;
  String? get authorizationUrl => throw _privateConstructorUsedError;
  String? get tokenUrl => throw _privateConstructorUsedError;
  String? get redirectUri => throw _privateConstructorUsedError;
  List<String>? get scopes => throw _privateConstructorUsedError;
  String? get apiKey => throw _privateConstructorUsedError;
  String? get bearerToken => throw _privateConstructorUsedError;

  /// Serializes this AuthConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthConfigCopyWith<AuthConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthConfigCopyWith<$Res> {
  factory $AuthConfigCopyWith(
          AuthConfig value, $Res Function(AuthConfig) then) =
      _$AuthConfigCopyWithImpl<$Res, AuthConfig>;
  @useResult
  $Res call(
      {String type,
      String? clientId,
      String? clientSecret,
      String? authorizationUrl,
      String? tokenUrl,
      String? redirectUri,
      List<String>? scopes,
      String? apiKey,
      String? bearerToken});
}

/// @nodoc
class _$AuthConfigCopyWithImpl<$Res, $Val extends AuthConfig>
    implements $AuthConfigCopyWith<$Res> {
  _$AuthConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? clientId = freezed,
    Object? clientSecret = freezed,
    Object? authorizationUrl = freezed,
    Object? tokenUrl = freezed,
    Object? redirectUri = freezed,
    Object? scopes = freezed,
    Object? apiKey = freezed,
    Object? bearerToken = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String?,
      clientSecret: freezed == clientSecret
          ? _value.clientSecret
          : clientSecret // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizationUrl: freezed == authorizationUrl
          ? _value.authorizationUrl
          : authorizationUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tokenUrl: freezed == tokenUrl
          ? _value.tokenUrl
          : tokenUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      redirectUri: freezed == redirectUri
          ? _value.redirectUri
          : redirectUri // ignore: cast_nullable_to_non_nullable
              as String?,
      scopes: freezed == scopes
          ? _value.scopes
          : scopes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      apiKey: freezed == apiKey
          ? _value.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String?,
      bearerToken: freezed == bearerToken
          ? _value.bearerToken
          : bearerToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthConfigImplCopyWith<$Res>
    implements $AuthConfigCopyWith<$Res> {
  factory _$$AuthConfigImplCopyWith(
          _$AuthConfigImpl value, $Res Function(_$AuthConfigImpl) then) =
      __$$AuthConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      String? clientId,
      String? clientSecret,
      String? authorizationUrl,
      String? tokenUrl,
      String? redirectUri,
      List<String>? scopes,
      String? apiKey,
      String? bearerToken});
}

/// @nodoc
class __$$AuthConfigImplCopyWithImpl<$Res>
    extends _$AuthConfigCopyWithImpl<$Res, _$AuthConfigImpl>
    implements _$$AuthConfigImplCopyWith<$Res> {
  __$$AuthConfigImplCopyWithImpl(
      _$AuthConfigImpl _value, $Res Function(_$AuthConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? clientId = freezed,
    Object? clientSecret = freezed,
    Object? authorizationUrl = freezed,
    Object? tokenUrl = freezed,
    Object? redirectUri = freezed,
    Object? scopes = freezed,
    Object? apiKey = freezed,
    Object? bearerToken = freezed,
  }) {
    return _then(_$AuthConfigImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: freezed == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String?,
      clientSecret: freezed == clientSecret
          ? _value.clientSecret
          : clientSecret // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizationUrl: freezed == authorizationUrl
          ? _value.authorizationUrl
          : authorizationUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tokenUrl: freezed == tokenUrl
          ? _value.tokenUrl
          : tokenUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      redirectUri: freezed == redirectUri
          ? _value.redirectUri
          : redirectUri // ignore: cast_nullable_to_non_nullable
              as String?,
      scopes: freezed == scopes
          ? _value._scopes
          : scopes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      apiKey: freezed == apiKey
          ? _value.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String?,
      bearerToken: freezed == bearerToken
          ? _value.bearerToken
          : bearerToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthConfigImpl implements _AuthConfig {
  const _$AuthConfigImpl(
      {required this.type,
      this.clientId,
      this.clientSecret,
      this.authorizationUrl,
      this.tokenUrl,
      this.redirectUri,
      final List<String>? scopes,
      this.apiKey,
      this.bearerToken})
      : _scopes = scopes;

  factory _$AuthConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthConfigImplFromJson(json);

  @override
  final String type;
// 'oauth', 'api_key', 'bearer', 'none'
  @override
  final String? clientId;
  @override
  final String? clientSecret;
  @override
  final String? authorizationUrl;
  @override
  final String? tokenUrl;
  @override
  final String? redirectUri;
  final List<String>? _scopes;
  @override
  List<String>? get scopes {
    final value = _scopes;
    if (value == null) return null;
    if (_scopes is EqualUnmodifiableListView) return _scopes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? apiKey;
  @override
  final String? bearerToken;

  @override
  String toString() {
    return 'AuthConfig(type: $type, clientId: $clientId, clientSecret: $clientSecret, authorizationUrl: $authorizationUrl, tokenUrl: $tokenUrl, redirectUri: $redirectUri, scopes: $scopes, apiKey: $apiKey, bearerToken: $bearerToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthConfigImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientSecret, clientSecret) ||
                other.clientSecret == clientSecret) &&
            (identical(other.authorizationUrl, authorizationUrl) ||
                other.authorizationUrl == authorizationUrl) &&
            (identical(other.tokenUrl, tokenUrl) ||
                other.tokenUrl == tokenUrl) &&
            (identical(other.redirectUri, redirectUri) ||
                other.redirectUri == redirectUri) &&
            const DeepCollectionEquality().equals(other._scopes, _scopes) &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            (identical(other.bearerToken, bearerToken) ||
                other.bearerToken == bearerToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      clientId,
      clientSecret,
      authorizationUrl,
      tokenUrl,
      redirectUri,
      const DeepCollectionEquality().hash(_scopes),
      apiKey,
      bearerToken);

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthConfigImplCopyWith<_$AuthConfigImpl> get copyWith =>
      __$$AuthConfigImplCopyWithImpl<_$AuthConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthConfigImplToJson(
      this,
    );
  }
}

abstract class _AuthConfig implements AuthConfig {
  const factory _AuthConfig(
      {required final String type,
      final String? clientId,
      final String? clientSecret,
      final String? authorizationUrl,
      final String? tokenUrl,
      final String? redirectUri,
      final List<String>? scopes,
      final String? apiKey,
      final String? bearerToken}) = _$AuthConfigImpl;

  factory _AuthConfig.fromJson(Map<String, dynamic> json) =
      _$AuthConfigImpl.fromJson;

  @override
  String get type; // 'oauth', 'api_key', 'bearer', 'none'
  @override
  String? get clientId;
  @override
  String? get clientSecret;
  @override
  String? get authorizationUrl;
  @override
  String? get tokenUrl;
  @override
  String? get redirectUri;
  @override
  List<String>? get scopes;
  @override
  String? get apiKey;
  @override
  String? get bearerToken;

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthConfigImplCopyWith<_$AuthConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
