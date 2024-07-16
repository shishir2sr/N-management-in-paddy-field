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
  List<Uint8List> get originalImage => throw _privateConstructorUsedError;
  List<Uint8List> get processedImages => throw _privateConstructorUsedError;

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
  $Res call({List<Uint8List> originalImage, List<Uint8List> processedImages});
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
    Object? originalImage = null,
    Object? processedImages = null,
  }) {
    return _then(_value.copyWith(
      originalImage: null == originalImage
          ? _value.originalImage
          : originalImage // ignore: cast_nullable_to_non_nullable
              as List<Uint8List>,
      processedImages: null == processedImages
          ? _value.processedImages
          : processedImages // ignore: cast_nullable_to_non_nullable
              as List<Uint8List>,
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
  $Res call({List<Uint8List> originalImage, List<Uint8List> processedImages});
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
    Object? originalImage = null,
    Object? processedImages = null,
  }) {
    return _then(_$ImageProcessorStateImpl(
      originalImage: null == originalImage
          ? _value._originalImage
          : originalImage // ignore: cast_nullable_to_non_nullable
              as List<Uint8List>,
      processedImages: null == processedImages
          ? _value._processedImages
          : processedImages // ignore: cast_nullable_to_non_nullable
              as List<Uint8List>,
    ));
  }
}

/// @nodoc

class _$ImageProcessorStateImpl implements _ImageProcessorState {
  const _$ImageProcessorStateImpl(
      {required final List<Uint8List> originalImage,
      required final List<Uint8List> processedImages})
      : _originalImage = originalImage,
        _processedImages = processedImages;

  final List<Uint8List> _originalImage;
  @override
  List<Uint8List> get originalImage {
    if (_originalImage is EqualUnmodifiableListView) return _originalImage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_originalImage);
  }

  final List<Uint8List> _processedImages;
  @override
  List<Uint8List> get processedImages {
    if (_processedImages is EqualUnmodifiableListView) return _processedImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_processedImages);
  }

  @override
  String toString() {
    return 'ImageProcessorState(originalImage: $originalImage, processedImages: $processedImages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageProcessorStateImpl &&
            const DeepCollectionEquality()
                .equals(other._originalImage, _originalImage) &&
            const DeepCollectionEquality()
                .equals(other._processedImages, _processedImages));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_originalImage),
      const DeepCollectionEquality().hash(_processedImages));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageProcessorStateImplCopyWith<_$ImageProcessorStateImpl> get copyWith =>
      __$$ImageProcessorStateImplCopyWithImpl<_$ImageProcessorStateImpl>(
          this, _$identity);
}

abstract class _ImageProcessorState implements ImageProcessorState {
  const factory _ImageProcessorState(
          {required final List<Uint8List> originalImage,
          required final List<Uint8List> processedImages}) =
      _$ImageProcessorStateImpl;

  @override
  List<Uint8List> get originalImage;
  @override
  List<Uint8List> get processedImages;
  @override
  @JsonKey(ignore: true)
  _$$ImageProcessorStateImplCopyWith<_$ImageProcessorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
