// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServerConfigImpl _$$ServerConfigImplFromJson(Map<String, dynamic> json) =>
    _$ServerConfigImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      transport: json['transport'] as String? ?? '',
      connected: json['connected'] as bool? ?? false,
      error: json['error'] as String?,
      faviconUrl: json['faviconUrl'] as String?,
      lastConnected: json['lastConnected'] == null
          ? null
          : DateTime.parse(json['lastConnected'] as String),
      auth: json['auth'] == null
          ? null
          : AuthConfig.fromJson(json['auth'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ServerConfigImplToJson(_$ServerConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'transport': instance.transport,
      'connected': instance.connected,
      if (instance.error case final value?) 'error': value,
      if (instance.faviconUrl case final value?) 'faviconUrl': value,
      if (instance.lastConnected?.toIso8601String() case final value?)
        'lastConnected': value,
      if (instance.auth?.toJson() case final value?) 'auth': value,
    };

_$AuthConfigImpl _$$AuthConfigImplFromJson(Map<String, dynamic> json) =>
    _$AuthConfigImpl(
      type: json['type'] as String,
      clientId: json['clientId'] as String?,
      clientSecret: json['clientSecret'] as String?,
      authorizationUrl: json['authorizationUrl'] as String?,
      tokenUrl: json['tokenUrl'] as String?,
      redirectUri: json['redirectUri'] as String?,
      scopes:
          (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      apiKey: json['apiKey'] as String?,
      bearerToken: json['bearerToken'] as String?,
    );

Map<String, dynamic> _$$AuthConfigImplToJson(_$AuthConfigImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      if (instance.clientId case final value?) 'clientId': value,
      if (instance.clientSecret case final value?) 'clientSecret': value,
      if (instance.authorizationUrl case final value?)
        'authorizationUrl': value,
      if (instance.tokenUrl case final value?) 'tokenUrl': value,
      if (instance.redirectUri case final value?) 'redirectUri': value,
      if (instance.scopes case final value?) 'scopes': value,
      if (instance.apiKey case final value?) 'apiKey': value,
      if (instance.bearerToken case final value?) 'bearerToken': value,
    };
