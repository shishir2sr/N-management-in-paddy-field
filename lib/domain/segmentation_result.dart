import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
part 'segmentation_result.freezed.dart';

@freezed
class SegmentationResult with _$SegmentationResult {
  const SegmentationResult._();
  const factory SegmentationResult({
    required Uint8List originalImage,
    required Uint8List outputImage,

    /// LCC score (2..5) produced by the classification model.
    ///
    /// Classification used to run separately on the preview page, against an
    /// interpreter with no listeners that could be disposed mid-`run()`. It now
    /// comes back with the segmentation in a single isolate round trip.
    required int lccLabel,
  }) = _SegmentationResult;

  bool get isValidLabel => lccLabel >= 2 && lccLabel <= 5;
}
