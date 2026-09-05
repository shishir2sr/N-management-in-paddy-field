import 'dart:async';

import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/domain/analysis_failure.dart';
import 'package:LCC/domain/segmentation_result.dart';
import 'package:LCC/infrastructure/image_analysis_repository.dart';

part 'image_processror_notifier_provider.freezed.dart';

/// Number of leaf readings a full assessment needs.
const int kRequiredReadings = 10;

@freezed
class ImageProcessorState with _$ImageProcessorState {
  const ImageProcessorState._();
  const factory ImageProcessorState({
    required List<int> lccResult,
  }) = _ImageProcessorState;

  factory ImageProcessorState.initial() =>
      const ImageProcessorState(lccResult: []);

  int get remaining => kRequiredReadings - lccResult.length;
  double get percentage => lccResult.length.toDouble();
  bool get isComplete => lccResult.length >= kRequiredReadings;
}

// * ImageProcessorNotifier

class ImageProcessorNotifier extends AsyncNotifier<ImageProcessorState> {
  /// Guards against a second capture starting while one is in flight. The
  /// shutter used to fire an unawaited future, so a double tap re-entered
  /// `takePicture` (→ "Previous capture has not returned yet") and could push
  /// two preview routes.
  bool _isBusy = false;

  bool get isBusy => _isBusy;

  @override
  FutureOr<ImageProcessorState> build() => ImageProcessorState.initial();

  ImageProcessorState get _current => state.value ?? ImageProcessorState.initial();

  /// Sets loading without discarding the readings collected so far.
  void _beginWork(ImageProcessorState previous) {
    state = const AsyncLoading<ImageProcessorState>()
        .copyWithPrevious(AsyncData(previous));
  }

  void _failWith(AnalysisFailure failure, ImageProcessorState previous) {
    state = AsyncError<ImageProcessorState>(failure, StackTrace.current)
        .copyWithPrevious(AsyncData(previous));
  }

  Future<SegmentationResult?> captureAndSegmentImage({
    required CameraController controller,
  }) async {
    if (_isBusy) {
      logger.w('Capture already in progress — ignoring tap');
      return null;
    }
    _isBusy = true;

    final previous = _current;
    _beginWork(previous);

    try {
      final result = await ref
          .read(imageProcessingRepositoryProvider)
          .captureAndAnalyze(controller: controller);

      // Exactly one terminal state per operation. The old code could emit two
      // AsyncErrors for a single failure, which showed two stacked snackbars.
      return result.fold(
        (failure) {
          _failWith(failure, previous);
          return null;
        },
        (segmentation) {
          state = AsyncData(previous);
          return segmentation;
        },
      );
    } finally {
      _isBusy = false;
    }
  }

  Future<SegmentationResult?> pickImageFromGallery() async {
    if (_isBusy) {
      logger.w('Analysis already in progress — ignoring gallery pick');
      return null;
    }

    final XFile? pickedFile;
    try {
      pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        // Without these a 48 MP photo is decoded at full size before it is
        // scaled to 256x256 anyway.
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      logger.e('Gallery picker failed: $e');
      _failWith(
        const ProcessingFailure('Could not open the gallery.'),
        _current,
      );
      return null;
    }

    if (pickedFile == null) {
      // User cancelled — not an error, and must not leave the UI in a
      // loading/error state.
      return null;
    }

    _isBusy = true;
    final previous = _current;
    _beginWork(previous);

    try {
      final result = await ref
          .read(imageProcessingRepositoryProvider)
          .analyzeImageAt(imagePath: pickedFile.path);

      return result.fold(
        (failure) {
          _failWith(failure, previous);
          return null;
        },
        (segmentation) {
          state = AsyncData(previous);
          return segmentation;
        },
      );
    } finally {
      _isBusy = false;
    }
  }

  void resetPrediction() {
    state = AsyncData(ImageProcessorState.initial());
  }

  void removeImage(int index) {
    final results = List<int>.from(_current.lccResult);
    if (index < 0 || index >= results.length) {
      logger.w('removeImage($index) out of range for ${results.length} items');
      return;
    }
    results.removeAt(index);
    state = AsyncData(ImageProcessorState(lccResult: results));
  }

  /// Records an accepted reading.
  void addResult(int result) {
    if (_current.isComplete) {
      logger.w('Already have $kRequiredReadings readings — ignoring');
      return;
    }
    state = AsyncData(
      ImageProcessorState(lccResult: [..._current.lccResult, result]),
    );
    logger.i('Readings: ${_current.lccResult}');
  }
}

final imageProcessorProvider =
    AsyncNotifierProvider<ImageProcessorNotifier, ImageProcessorState>(
  ImageProcessorNotifier.new,
);
