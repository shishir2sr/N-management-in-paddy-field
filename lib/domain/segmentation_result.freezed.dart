// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'segmentation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SegmentationResult {
  Uint8List get originalImage => throw _privateConstructorUsedError;
  Uint8List get outputImage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SegmentationResultCopyWith<SegmentationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SegmentationResultCopyWith<$Res> {
  factory $SegmentationResultCopyWith(
          SegmentationResult value, $Res Function(SegmentationResult) then) =
      _$SegmentationResultCopyWithImpl<$Res, SegmentationResult>;
  @useResult
  $Res call({Uint8List originalImage, Uint8List outputImage});
}

/// @nodoc
class _$SegmentationResultCopyWithImpl<$Res, $Val extends SegmentationResult>
    implements $SegmentationResultCopyWith<$Res> {
  _$SegmentationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? originalImage = null,
    Object? outputImage = null,
  }) {
    return _then(_value.copyWith(
      originalImage: null == originalImage
          ? _value.originalImage
          : originalImage // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      outputImage: null == outputImage
          ? _value.outputImage
          : outputImage // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SegmentationResultImplCopyWith<$Res>
    implements $SegmentationResultCopyWith<$Res> {
  factory _$$SegmentationResultImplCopyWith(_$SegmentationResultImpl value,
          $Res Function(_$SegmentationResultImpl) then) =
      __$$SegmentationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Uint8List originalImage, Uint8List outputImage});
}

/// @nodoc
class __$$SegmentationResultImplCopyWithImpl<$Res>
    extends _$SegmentationResultCopyWithImpl<$Res, _$SegmentationResultImpl>
    implements _$$SegmentationResultImplCopyWith<$Res> {
  __$$SegmentationResultImplCopyWithImpl(_$SegmentationResultImpl _value,
      $Res Function(_$SegmentationResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? originalImage = null,
    Object? outputImage = null,
  }) {
    return _then(_$SegmentationResultImpl(
      originalImage: null == originalImage
          ? _value.originalImage
          : originalImage // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      outputImage: null == outputImage
          ? _value.outputImage
          : outputImage // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ));
  }
}

/// @nodoc

class _$SegmentationResultImpl extends _SegmentationResult {
  const _$SegmentationResultImpl(
      {required this.originalImage, required this.outputImage})
      : super._();

  @override
  final Uint8List originalImage;
  @override
  final Uint8List outputImage;

  @override
  String toString() {
    return 'SegmentationResult(originalImage: $originalImage, outputImage: $outputImage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SegmentationResultImpl &&
            const DeepCollectionEquality()
                .equals(other.originalImage, originalImage) &&
            const DeepCollectionEquality()
                .equals(other.outputImage, outputImage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(originalImage),
      const DeepCollectionEquality().hash(outputImage));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SegmentationResultImplCopyWith<_$SegmentationResultImpl> get copyWith =>
      __$$SegmentationResultImplCopyWithImpl<_$SegmentationResultImpl>(
          this, _$identity);
}

abstract class _SegmentationResult extends SegmentationResult {
  const factory _SegmentationResult(
      {required final Uint8List originalImage,
      required final Uint8List outputImage}) = _$SegmentationResultImpl;
  const _SegmentationResult._() : super._();

  @override
  Uint8List get originalImage;
  @override
  Uint8List get outputImage;
  @override
  @JsonKey(ignore: true)
  _$$SegmentationResultImplCopyWith<_$SegmentationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
