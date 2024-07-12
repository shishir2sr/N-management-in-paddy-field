// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CameraFailure {
  String get msg => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String msg) cameraAccessDenied,
    required TResult Function(String msg) previuslyDenied,
    required TResult Function(String msg) accessRestricted,
    required TResult Function(String msg) cameraException,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String msg)? cameraAccessDenied,
    TResult? Function(String msg)? previuslyDenied,
    TResult? Function(String msg)? accessRestricted,
    TResult? Function(String msg)? cameraException,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String msg)? cameraAccessDenied,
    TResult Function(String msg)? previuslyDenied,
    TResult Function(String msg)? accessRestricted,
    TResult Function(String msg)? cameraException,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CameraAccessDenied value) cameraAccessDenied,
    required TResult Function(_PreviuslyDenied value) previuslyDenied,
    required TResult Function(_AccessRestricted value) accessRestricted,
    required TResult Function(_CameraException value) cameraException,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CameraAccessDenied value)? cameraAccessDenied,
    TResult? Function(_PreviuslyDenied value)? previuslyDenied,
    TResult? Function(_AccessRestricted value)? accessRestricted,
    TResult? Function(_CameraException value)? cameraException,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CameraAccessDenied value)? cameraAccessDenied,
    TResult Function(_PreviuslyDenied value)? previuslyDenied,
    TResult Function(_AccessRestricted value)? accessRestricted,
    TResult Function(_CameraException value)? cameraException,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CameraFailureCopyWith<CameraFailure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CameraFailureCopyWith<$Res> {
  factory $CameraFailureCopyWith(
          CameraFailure value, $Res Function(CameraFailure) then) =
      _$CameraFailureCopyWithImpl<$Res, CameraFailure>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class _$CameraFailureCopyWithImpl<$Res, $Val extends CameraFailure>
    implements $CameraFailureCopyWith<$Res> {
  _$CameraFailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_value.copyWith(
      msg: null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CameraAccessDeniedImplCopyWith<$Res>
    implements $CameraFailureCopyWith<$Res> {
  factory _$$CameraAccessDeniedImplCopyWith(_$CameraAccessDeniedImpl value,
          $Res Function(_$CameraAccessDeniedImpl) then) =
      __$$CameraAccessDeniedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$CameraAccessDeniedImplCopyWithImpl<$Res>
    extends _$CameraFailureCopyWithImpl<$Res, _$CameraAccessDeniedImpl>
    implements _$$CameraAccessDeniedImplCopyWith<$Res> {
  __$$CameraAccessDeniedImplCopyWithImpl(_$CameraAccessDeniedImpl _value,
      $Res Function(_$CameraAccessDeniedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$CameraAccessDeniedImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CameraAccessDeniedImpl extends _CameraAccessDenied {
  const _$CameraAccessDeniedImpl(this.msg) : super._();

  @override
  final String msg;

  @override
  String toString() {
    return 'CameraFailure.cameraAccessDenied(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CameraAccessDeniedImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CameraAccessDeniedImplCopyWith<_$CameraAccessDeniedImpl> get copyWith =>
      __$$CameraAccessDeniedImplCopyWithImpl<_$CameraAccessDeniedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String msg) cameraAccessDenied,
    required TResult Function(String msg) previuslyDenied,
    required TResult Function(String msg) accessRestricted,
    required TResult Function(String msg) cameraException,
  }) {
    return cameraAccessDenied(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String msg)? cameraAccessDenied,
    TResult? Function(String msg)? previuslyDenied,
    TResult? Function(String msg)? accessRestricted,
    TResult? Function(String msg)? cameraException,
  }) {
    return cameraAccessDenied?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String msg)? cameraAccessDenied,
    TResult Function(String msg)? previuslyDenied,
    TResult Function(String msg)? accessRestricted,
    TResult Function(String msg)? cameraException,
    required TResult orElse(),
  }) {
    if (cameraAccessDenied != null) {
      return cameraAccessDenied(msg);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CameraAccessDenied value) cameraAccessDenied,
    required TResult Function(_PreviuslyDenied value) previuslyDenied,
    required TResult Function(_AccessRestricted value) accessRestricted,
    required TResult Function(_CameraException value) cameraException,
  }) {
    return cameraAccessDenied(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CameraAccessDenied value)? cameraAccessDenied,
    TResult? Function(_PreviuslyDenied value)? previuslyDenied,
    TResult? Function(_AccessRestricted value)? accessRestricted,
    TResult? Function(_CameraException value)? cameraException,
  }) {
    return cameraAccessDenied?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CameraAccessDenied value)? cameraAccessDenied,
    TResult Function(_PreviuslyDenied value)? previuslyDenied,
    TResult Function(_AccessRestricted value)? accessRestricted,
    TResult Function(_CameraException value)? cameraException,
    required TResult orElse(),
  }) {
    if (cameraAccessDenied != null) {
      return cameraAccessDenied(this);
    }
    return orElse();
  }
}

abstract class _CameraAccessDenied extends CameraFailure {
  const factory _CameraAccessDenied(final String msg) =
      _$CameraAccessDeniedImpl;
  const _CameraAccessDenied._() : super._();

  @override
  String get msg;
  @override
  @JsonKey(ignore: true)
  _$$CameraAccessDeniedImplCopyWith<_$CameraAccessDeniedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PreviuslyDeniedImplCopyWith<$Res>
    implements $CameraFailureCopyWith<$Res> {
  factory _$$PreviuslyDeniedImplCopyWith(_$PreviuslyDeniedImpl value,
          $Res Function(_$PreviuslyDeniedImpl) then) =
      __$$PreviuslyDeniedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$PreviuslyDeniedImplCopyWithImpl<$Res>
    extends _$CameraFailureCopyWithImpl<$Res, _$PreviuslyDeniedImpl>
    implements _$$PreviuslyDeniedImplCopyWith<$Res> {
  __$$PreviuslyDeniedImplCopyWithImpl(
      _$PreviuslyDeniedImpl _value, $Res Function(_$PreviuslyDeniedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$PreviuslyDeniedImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PreviuslyDeniedImpl extends _PreviuslyDenied {
  const _$PreviuslyDeniedImpl(this.msg) : super._();

  @override
  final String msg;

  @override
  String toString() {
    return 'CameraFailure.previuslyDenied(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreviuslyDeniedImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PreviuslyDeniedImplCopyWith<_$PreviuslyDeniedImpl> get copyWith =>
      __$$PreviuslyDeniedImplCopyWithImpl<_$PreviuslyDeniedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String msg) cameraAccessDenied,
    required TResult Function(String msg) previuslyDenied,
    required TResult Function(String msg) accessRestricted,
    required TResult Function(String msg) cameraException,
  }) {
    return previuslyDenied(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String msg)? cameraAccessDenied,
    TResult? Function(String msg)? previuslyDenied,
    TResult? Function(String msg)? accessRestricted,
    TResult? Function(String msg)? cameraException,
  }) {
    return previuslyDenied?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String msg)? cameraAccessDenied,
    TResult Function(String msg)? previuslyDenied,
    TResult Function(String msg)? accessRestricted,
    TResult Function(String msg)? cameraException,
    required TResult orElse(),
  }) {
    if (previuslyDenied != null) {
      return previuslyDenied(msg);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CameraAccessDenied value) cameraAccessDenied,
    required TResult Function(_PreviuslyDenied value) previuslyDenied,
    required TResult Function(_AccessRestricted value) accessRestricted,
    required TResult Function(_CameraException value) cameraException,
  }) {
    return previuslyDenied(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CameraAccessDenied value)? cameraAccessDenied,
    TResult? Function(_PreviuslyDenied value)? previuslyDenied,
    TResult? Function(_AccessRestricted value)? accessRestricted,
    TResult? Function(_CameraException value)? cameraException,
  }) {
    return previuslyDenied?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CameraAccessDenied value)? cameraAccessDenied,
    TResult Function(_PreviuslyDenied value)? previuslyDenied,
    TResult Function(_AccessRestricted value)? accessRestricted,
    TResult Function(_CameraException value)? cameraException,
    required TResult orElse(),
  }) {
    if (previuslyDenied != null) {
      return previuslyDenied(this);
    }
    return orElse();
  }
}

abstract class _PreviuslyDenied extends CameraFailure {
  const factory _PreviuslyDenied(final String msg) = _$PreviuslyDeniedImpl;
  const _PreviuslyDenied._() : super._();

  @override
  String get msg;
  @override
  @JsonKey(ignore: true)
  _$$PreviuslyDeniedImplCopyWith<_$PreviuslyDeniedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AccessRestrictedImplCopyWith<$Res>
    implements $CameraFailureCopyWith<$Res> {
  factory _$$AccessRestrictedImplCopyWith(_$AccessRestrictedImpl value,
          $Res Function(_$AccessRestrictedImpl) then) =
      __$$AccessRestrictedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$AccessRestrictedImplCopyWithImpl<$Res>
    extends _$CameraFailureCopyWithImpl<$Res, _$AccessRestrictedImpl>
    implements _$$AccessRestrictedImplCopyWith<$Res> {
  __$$AccessRestrictedImplCopyWithImpl(_$AccessRestrictedImpl _value,
      $Res Function(_$AccessRestrictedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$AccessRestrictedImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AccessRestrictedImpl extends _AccessRestricted {
  const _$AccessRestrictedImpl(this.msg) : super._();

  @override
  final String msg;

  @override
  String toString() {
    return 'CameraFailure.accessRestricted(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccessRestrictedImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccessRestrictedImplCopyWith<_$AccessRestrictedImpl> get copyWith =>
      __$$AccessRestrictedImplCopyWithImpl<_$AccessRestrictedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String msg) cameraAccessDenied,
    required TResult Function(String msg) previuslyDenied,
    required TResult Function(String msg) accessRestricted,
    required TResult Function(String msg) cameraException,
  }) {
    return accessRestricted(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String msg)? cameraAccessDenied,
    TResult? Function(String msg)? previuslyDenied,
    TResult? Function(String msg)? accessRestricted,
    TResult? Function(String msg)? cameraException,
  }) {
    return accessRestricted?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String msg)? cameraAccessDenied,
    TResult Function(String msg)? previuslyDenied,
    TResult Function(String msg)? accessRestricted,
    TResult Function(String msg)? cameraException,
    required TResult orElse(),
  }) {
    if (accessRestricted != null) {
      return accessRestricted(msg);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CameraAccessDenied value) cameraAccessDenied,
    required TResult Function(_PreviuslyDenied value) previuslyDenied,
    required TResult Function(_AccessRestricted value) accessRestricted,
    required TResult Function(_CameraException value) cameraException,
  }) {
    return accessRestricted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CameraAccessDenied value)? cameraAccessDenied,
    TResult? Function(_PreviuslyDenied value)? previuslyDenied,
    TResult? Function(_AccessRestricted value)? accessRestricted,
    TResult? Function(_CameraException value)? cameraException,
  }) {
    return accessRestricted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CameraAccessDenied value)? cameraAccessDenied,
    TResult Function(_PreviuslyDenied value)? previuslyDenied,
    TResult Function(_AccessRestricted value)? accessRestricted,
    TResult Function(_CameraException value)? cameraException,
    required TResult orElse(),
  }) {
    if (accessRestricted != null) {
      return accessRestricted(this);
    }
    return orElse();
  }
}

abstract class _AccessRestricted extends CameraFailure {
  const factory _AccessRestricted(final String msg) = _$AccessRestrictedImpl;
  const _AccessRestricted._() : super._();

  @override
  String get msg;
  @override
  @JsonKey(ignore: true)
  _$$AccessRestrictedImplCopyWith<_$AccessRestrictedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CameraExceptionImplCopyWith<$Res>
    implements $CameraFailureCopyWith<$Res> {
  factory _$$CameraExceptionImplCopyWith(_$CameraExceptionImpl value,
          $Res Function(_$CameraExceptionImpl) then) =
      __$$CameraExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$CameraExceptionImplCopyWithImpl<$Res>
    extends _$CameraFailureCopyWithImpl<$Res, _$CameraExceptionImpl>
    implements _$$CameraExceptionImplCopyWith<$Res> {
  __$$CameraExceptionImplCopyWithImpl(
      _$CameraExceptionImpl _value, $Res Function(_$CameraExceptionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$CameraExceptionImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CameraExceptionImpl extends _CameraException {
  const _$CameraExceptionImpl(this.msg) : super._();

  @override
  final String msg;

  @override
  String toString() {
    return 'CameraFailure.cameraException(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CameraExceptionImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CameraExceptionImplCopyWith<_$CameraExceptionImpl> get copyWith =>
      __$$CameraExceptionImplCopyWithImpl<_$CameraExceptionImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String msg) cameraAccessDenied,
    required TResult Function(String msg) previuslyDenied,
    required TResult Function(String msg) accessRestricted,
    required TResult Function(String msg) cameraException,
  }) {
    return cameraException(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String msg)? cameraAccessDenied,
    TResult? Function(String msg)? previuslyDenied,
    TResult? Function(String msg)? accessRestricted,
    TResult? Function(String msg)? cameraException,
  }) {
    return cameraException?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String msg)? cameraAccessDenied,
    TResult Function(String msg)? previuslyDenied,
    TResult Function(String msg)? accessRestricted,
    TResult Function(String msg)? cameraException,
    required TResult orElse(),
  }) {
    if (cameraException != null) {
      return cameraException(msg);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CameraAccessDenied value) cameraAccessDenied,
    required TResult Function(_PreviuslyDenied value) previuslyDenied,
    required TResult Function(_AccessRestricted value) accessRestricted,
    required TResult Function(_CameraException value) cameraException,
  }) {
    return cameraException(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CameraAccessDenied value)? cameraAccessDenied,
    TResult? Function(_PreviuslyDenied value)? previuslyDenied,
    TResult? Function(_AccessRestricted value)? accessRestricted,
    TResult? Function(_CameraException value)? cameraException,
  }) {
    return cameraException?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CameraAccessDenied value)? cameraAccessDenied,
    TResult Function(_PreviuslyDenied value)? previuslyDenied,
    TResult Function(_AccessRestricted value)? accessRestricted,
    TResult Function(_CameraException value)? cameraException,
    required TResult orElse(),
  }) {
    if (cameraException != null) {
      return cameraException(this);
    }
    return orElse();
  }
}

abstract class _CameraException extends CameraFailure {
  const factory _CameraException(final String msg) = _$CameraExceptionImpl;
  const _CameraException._() : super._();

  @override
  String get msg;
  @override
  @JsonKey(ignore: true)
  _$$CameraExceptionImplCopyWith<_$CameraExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
