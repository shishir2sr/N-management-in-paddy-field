// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_processror_notifier_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ImageProcessorState {
  List<int> get lccResult => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ImageProcessorStateCopyWith<ImageProcessorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageProcessorStateCopyWith<$Res> {
  factory $ImageProcessorStateCopyWith(
          ImageProcessorState value, $Res Function(ImageProcessorState) then) =
      _$ImageProcessorStateCopyWithImpl<$Res, ImageProcessorState>;
  @useResult
  $Res call({List<int> lccResult});
}

/// @nodoc
class _$ImageProcessorStateCopyWithImpl<$Res, $Val extends ImageProcessorState>
    implements $ImageProcessorStateCopyWith<$Res> {
  _$ImageProcessorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lccResult = null,
  }) {
    return _then(_value.copyWith(
      lccResult: null == lccResult
          ? _value.lccResult
          : lccResult // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImageProcessorStateImplCopyWith<$Res>
    implements $ImageProcessorStateCopyWith<$Res> {
  factory _$$ImageProcessorStateImplCopyWith(_$ImageProcessorStateImpl value,
          $Res Function(_$ImageProcessorStateImpl) then) =
      __$$ImageProcessorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<int> lccResult});
}

/// @nodoc
class __$$ImageProcessorStateImplCopyWithImpl<$Res>
    extends _$ImageProcessorStateCopyWithImpl<$Res, _$ImageProcessorStateImpl>
    implements _$$ImageProcessorStateImplCopyWith<$Res> {
  __$$ImageProcessorStateImplCopyWithImpl(_$ImageProcessorStateImpl _value,
      $Res Function(_$ImageProcessorStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lccResult = null,
  }) {
    return _then(_$ImageProcessorStateImpl(
      lccResult: null == lccResult
          ? _value._lccResult
          : lccResult // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc

class _$ImageProcessorStateImpl extends _ImageProcessorState
    with DiagnosticableTreeMixin {
  const _$ImageProcessorStateImpl({required final List<int> lccResult})
      : _lccResult = lccResult,
        super._();

  final List<int> _lccResult;
  @override
  List<int> get lccResult {
    if (_lccResult is EqualUnmodifiableListView) return _lccResult;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lccResult);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ImageProcessorState(lccResult: $lccResult)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ImageProcessorState'))
      ..add(DiagnosticsProperty('lccResult', lccResult));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageProcessorStateImpl &&
            const DeepCollectionEquality()
                .equals(other._lccResult, _lccResult));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_lccResult));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageProcessorStateImplCopyWith<_$ImageProcessorStateImpl> get copyWith =>
      __$$ImageProcessorStateImplCopyWithImpl<_$ImageProcessorStateImpl>(
          this, _$identity);
}

abstract class _ImageProcessorState extends ImageProcessorState {
  const factory _ImageProcessorState({required final List<int> lccResult}) =
      _$ImageProcessorStateImpl;
  const _ImageProcessorState._() : super._();

  @override
  List<int> get lccResult;
  @override
  @JsonKey(ignore: true)
  _$$ImageProcessorStateImplCopyWith<_$ImageProcessorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
