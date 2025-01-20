// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result_notifier_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ResultState {
  double get landAmountInBigha => throw _privateConstructorUsedError;
  LandConversionStrategy get selectedStrategy =>
      throw _privateConstructorUsedError;
  String get recommendation => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ResultStateCopyWith<ResultState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultStateCopyWith<$Res> {
  factory $ResultStateCopyWith(
          ResultState value, $Res Function(ResultState) then) =
      _$ResultStateCopyWithImpl<$Res, ResultState>;
  @useResult
  $Res call(
      {double landAmountInBigha,
      LandConversionStrategy selectedStrategy,
      String recommendation});
}

/// @nodoc
class _$ResultStateCopyWithImpl<$Res, $Val extends ResultState>
    implements $ResultStateCopyWith<$Res> {
  _$ResultStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? landAmountInBigha = null,
    Object? selectedStrategy = null,
    Object? recommendation = null,
  }) {
    return _then(_value.copyWith(
      landAmountInBigha: null == landAmountInBigha
          ? _value.landAmountInBigha
          : landAmountInBigha // ignore: cast_nullable_to_non_nullable
              as double,
      selectedStrategy: null == selectedStrategy
          ? _value.selectedStrategy
          : selectedStrategy // ignore: cast_nullable_to_non_nullable
              as LandConversionStrategy,
      recommendation: null == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResultStateImplCopyWith<$Res>
    implements $ResultStateCopyWith<$Res> {
  factory _$$ResultStateImplCopyWith(
          _$ResultStateImpl value, $Res Function(_$ResultStateImpl) then) =
      __$$ResultStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double landAmountInBigha,
      LandConversionStrategy selectedStrategy,
      String recommendation});
}

/// @nodoc
class __$$ResultStateImplCopyWithImpl<$Res>
    extends _$ResultStateCopyWithImpl<$Res, _$ResultStateImpl>
    implements _$$ResultStateImplCopyWith<$Res> {
  __$$ResultStateImplCopyWithImpl(
      _$ResultStateImpl _value, $Res Function(_$ResultStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? landAmountInBigha = null,
    Object? selectedStrategy = null,
    Object? recommendation = null,
  }) {
    return _then(_$ResultStateImpl(
      landAmountInBigha: null == landAmountInBigha
          ? _value.landAmountInBigha
          : landAmountInBigha // ignore: cast_nullable_to_non_nullable
              as double,
      selectedStrategy: null == selectedStrategy
          ? _value.selectedStrategy
          : selectedStrategy // ignore: cast_nullable_to_non_nullable
              as LandConversionStrategy,
      recommendation: null == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ResultStateImpl extends _ResultState with DiagnosticableTreeMixin {
  _$ResultStateImpl(
      {required this.landAmountInBigha,
      required this.selectedStrategy,
      required this.recommendation})
      : super._();

  @override
  final double landAmountInBigha;
  @override
  final LandConversionStrategy selectedStrategy;
  @override
  final String recommendation;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ResultState(landAmountInBigha: $landAmountInBigha, selectedStrategy: $selectedStrategy, recommendation: $recommendation)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ResultState'))
      ..add(DiagnosticsProperty('landAmountInBigha', landAmountInBigha))
      ..add(DiagnosticsProperty('selectedStrategy', selectedStrategy))
      ..add(DiagnosticsProperty('recommendation', recommendation));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultStateImpl &&
            (identical(other.landAmountInBigha, landAmountInBigha) ||
                other.landAmountInBigha == landAmountInBigha) &&
            (identical(other.selectedStrategy, selectedStrategy) ||
                other.selectedStrategy == selectedStrategy) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, landAmountInBigha, selectedStrategy, recommendation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultStateImplCopyWith<_$ResultStateImpl> get copyWith =>
      __$$ResultStateImplCopyWithImpl<_$ResultStateImpl>(this, _$identity);
}

abstract class _ResultState extends ResultState {
  factory _ResultState(
      {required final double landAmountInBigha,
      required final LandConversionStrategy selectedStrategy,
      required final String recommendation}) = _$ResultStateImpl;
  _ResultState._() : super._();

  @override
  double get landAmountInBigha;
  @override
  LandConversionStrategy get selectedStrategy;
  @override
  String get recommendation;
  @override
  @JsonKey(ignore: true)
  _$$ResultStateImplCopyWith<_$ResultStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
