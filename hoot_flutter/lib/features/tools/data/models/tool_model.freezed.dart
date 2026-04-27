// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tool_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ToolSchema _$ToolSchemaFromJson(Map<String, dynamic> json) {
  return _ToolSchema.fromJson(json);
}

/// @nodoc
mixin _$ToolSchema {
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get inputSchema => throw _privateConstructorUsedError;
  String get serverId => throw _privateConstructorUsedError;

  /// Serializes this ToolSchema to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ToolSchema
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ToolSchemaCopyWith<ToolSchema> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToolSchemaCopyWith<$Res> {
  factory $ToolSchemaCopyWith(
          ToolSchema value, $Res Function(ToolSchema) then) =
      _$ToolSchemaCopyWithImpl<$Res, ToolSchema>;
  @useResult
  $Res call(
      {String name,
      String? description,
      Map<String, dynamic>? inputSchema,
      String serverId});
}

/// @nodoc
class _$ToolSchemaCopyWithImpl<$Res, $Val extends ToolSchema>
    implements $ToolSchemaCopyWith<$Res> {
  _$ToolSchemaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ToolSchema
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? inputSchema = freezed,
    Object? serverId = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      inputSchema: freezed == inputSchema
          ? _value.inputSchema
          : inputSchema // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ToolSchemaImplCopyWith<$Res>
    implements $ToolSchemaCopyWith<$Res> {
  factory _$$ToolSchemaImplCopyWith(
          _$ToolSchemaImpl value, $Res Function(_$ToolSchemaImpl) then) =
      __$$ToolSchemaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String? description,
      Map<String, dynamic>? inputSchema,
      String serverId});
}

/// @nodoc
class __$$ToolSchemaImplCopyWithImpl<$Res>
    extends _$ToolSchemaCopyWithImpl<$Res, _$ToolSchemaImpl>
    implements _$$ToolSchemaImplCopyWith<$Res> {
  __$$ToolSchemaImplCopyWithImpl(
      _$ToolSchemaImpl _value, $Res Function(_$ToolSchemaImpl) _then)
      : super(_value, _then);

  /// Create a copy of ToolSchema
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = freezed,
    Object? inputSchema = freezed,
    Object? serverId = null,
  }) {
    return _then(_$ToolSchemaImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      inputSchema: freezed == inputSchema
          ? _value._inputSchema
          : inputSchema // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ToolSchemaImpl implements _ToolSchema {
  const _$ToolSchemaImpl(
      {required this.name,
      this.description,
      final Map<String, dynamic>? inputSchema,
      this.serverId = ''})
      : _inputSchema = inputSchema;

  factory _$ToolSchemaImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToolSchemaImplFromJson(json);

  @override
  final String name;
  @override
  final String? description;
  final Map<String, dynamic>? _inputSchema;
  @override
  Map<String, dynamic>? get inputSchema {
    final value = _inputSchema;
    if (value == null) return null;
    if (_inputSchema is EqualUnmodifiableMapView) return _inputSchema;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final String serverId;

  @override
  String toString() {
    return 'ToolSchema(name: $name, description: $description, inputSchema: $inputSchema, serverId: $serverId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToolSchemaImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._inputSchema, _inputSchema) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, description,
      const DeepCollectionEquality().hash(_inputSchema), serverId);

  /// Create a copy of ToolSchema
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToolSchemaImplCopyWith<_$ToolSchemaImpl> get copyWith =>
      __$$ToolSchemaImplCopyWithImpl<_$ToolSchemaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ToolSchemaImplToJson(
      this,
    );
  }
}

abstract class _ToolSchema implements ToolSchema {
  const factory _ToolSchema(
      {required final String name,
      final String? description,
      final Map<String, dynamic>? inputSchema,
      final String serverId}) = _$ToolSchemaImpl;

  factory _ToolSchema.fromJson(Map<String, dynamic> json) =
      _$ToolSchemaImpl.fromJson;

  @override
  String get name;
  @override
  String? get description;
  @override
  Map<String, dynamic>? get inputSchema;
  @override
  String get serverId;

  /// Create a copy of ToolSchema
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToolSchemaImplCopyWith<_$ToolSchemaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ToolExecutionResult _$ToolExecutionResultFromJson(Map<String, dynamic> json) {
  return _ToolExecutionResult.fromJson(json);
}

/// @nodoc
mixin _$ToolExecutionResult {
  String get toolName => throw _privateConstructorUsedError;
  String get serverId => throw _privateConstructorUsedError;
  Map<String, dynamic> get arguments => throw _privateConstructorUsedError;
  dynamic get result => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get isError => throw _privateConstructorUsedError;

  /// Serializes this ToolExecutionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ToolExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ToolExecutionResultCopyWith<ToolExecutionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ToolExecutionResultCopyWith<$Res> {
  factory $ToolExecutionResultCopyWith(
          ToolExecutionResult value, $Res Function(ToolExecutionResult) then) =
      _$ToolExecutionResultCopyWithImpl<$Res, ToolExecutionResult>;
  @useResult
  $Res call(
      {String toolName,
      String serverId,
      Map<String, dynamic> arguments,
      dynamic result,
      DateTime timestamp,
      Duration duration,
      String? error,
      bool isError});
}

/// @nodoc
class _$ToolExecutionResultCopyWithImpl<$Res, $Val extends ToolExecutionResult>
    implements $ToolExecutionResultCopyWith<$Res> {
  _$ToolExecutionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ToolExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toolName = null,
    Object? serverId = null,
    Object? arguments = null,
    Object? result = freezed,
    Object? timestamp = null,
    Object? duration = null,
    Object? error = freezed,
    Object? isError = null,
  }) {
    return _then(_value.copyWith(
      toolName: null == toolName
          ? _value.toolName
          : toolName // ignore: cast_nullable_to_non_nullable
              as String,
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      arguments: null == arguments
          ? _value.arguments
          : arguments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as dynamic,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isError: null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ToolExecutionResultImplCopyWith<$Res>
    implements $ToolExecutionResultCopyWith<$Res> {
  factory _$$ToolExecutionResultImplCopyWith(_$ToolExecutionResultImpl value,
          $Res Function(_$ToolExecutionResultImpl) then) =
      __$$ToolExecutionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String toolName,
      String serverId,
      Map<String, dynamic> arguments,
      dynamic result,
      DateTime timestamp,
      Duration duration,
      String? error,
      bool isError});
}

/// @nodoc
class __$$ToolExecutionResultImplCopyWithImpl<$Res>
    extends _$ToolExecutionResultCopyWithImpl<$Res, _$ToolExecutionResultImpl>
    implements _$$ToolExecutionResultImplCopyWith<$Res> {
  __$$ToolExecutionResultImplCopyWithImpl(_$ToolExecutionResultImpl _value,
      $Res Function(_$ToolExecutionResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ToolExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toolName = null,
    Object? serverId = null,
    Object? arguments = null,
    Object? result = freezed,
    Object? timestamp = null,
    Object? duration = null,
    Object? error = freezed,
    Object? isError = null,
  }) {
    return _then(_$ToolExecutionResultImpl(
      toolName: null == toolName
          ? _value.toolName
          : toolName // ignore: cast_nullable_to_non_nullable
              as String,
      serverId: null == serverId
          ? _value.serverId
          : serverId // ignore: cast_nullable_to_non_nullable
              as String,
      arguments: null == arguments
          ? _value._arguments
          : arguments // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as dynamic,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isError: null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ToolExecutionResultImpl implements _ToolExecutionResult {
  const _$ToolExecutionResultImpl(
      {required this.toolName,
      required this.serverId,
      required final Map<String, dynamic> arguments,
      required this.result,
      required this.timestamp,
      required this.duration,
      this.error,
      this.isError = false})
      : _arguments = arguments;

  factory _$ToolExecutionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ToolExecutionResultImplFromJson(json);

  @override
  final String toolName;
  @override
  final String serverId;
  final Map<String, dynamic> _arguments;
  @override
  Map<String, dynamic> get arguments {
    if (_arguments is EqualUnmodifiableMapView) return _arguments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_arguments);
  }

  @override
  final dynamic result;
  @override
  final DateTime timestamp;
  @override
  final Duration duration;
  @override
  final String? error;
  @override
  @JsonKey()
  final bool isError;

  @override
  String toString() {
    return 'ToolExecutionResult(toolName: $toolName, serverId: $serverId, arguments: $arguments, result: $result, timestamp: $timestamp, duration: $duration, error: $error, isError: $isError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToolExecutionResultImpl &&
            (identical(other.toolName, toolName) ||
                other.toolName == toolName) &&
            (identical(other.serverId, serverId) ||
                other.serverId == serverId) &&
            const DeepCollectionEquality()
                .equals(other._arguments, _arguments) &&
            const DeepCollectionEquality().equals(other.result, result) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isError, isError) || other.isError == isError));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      toolName,
      serverId,
      const DeepCollectionEquality().hash(_arguments),
      const DeepCollectionEquality().hash(result),
      timestamp,
      duration,
      error,
      isError);

  /// Create a copy of ToolExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToolExecutionResultImplCopyWith<_$ToolExecutionResultImpl> get copyWith =>
      __$$ToolExecutionResultImplCopyWithImpl<_$ToolExecutionResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ToolExecutionResultImplToJson(
      this,
    );
  }
}

abstract class _ToolExecutionResult implements ToolExecutionResult {
  const factory _ToolExecutionResult(
      {required final String toolName,
      required final String serverId,
      required final Map<String, dynamic> arguments,
      required final dynamic result,
      required final DateTime timestamp,
      required final Duration duration,
      final String? error,
      final bool isError}) = _$ToolExecutionResultImpl;

  factory _ToolExecutionResult.fromJson(Map<String, dynamic> json) =
      _$ToolExecutionResultImpl.fromJson;

  @override
  String get toolName;
  @override
  String get serverId;
  @override
  Map<String, dynamic> get arguments;
  @override
  dynamic get result;
  @override
  DateTime get timestamp;
  @override
  Duration get duration;
  @override
  String? get error;
  @override
  bool get isError;

  /// Create a copy of ToolExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToolExecutionResultImplCopyWith<_$ToolExecutionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
