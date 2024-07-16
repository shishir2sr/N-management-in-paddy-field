import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
part 'segmentation_result.freezed.dart';

@freezed
class SegmentationResult with _$SegmentationResult {
  const SegmentationResult._();
  const factory SegmentationResult({
    required Uint8List originalImage,
    required Uint8List outputImage,
  }) = _SegmentationResult;
}
