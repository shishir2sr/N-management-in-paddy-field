import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/domain/segmentation_result.dart';
import 'package:rice_fertile_ai/infrastructure/image_analysis_repository.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
part 'image_processror_notifier_provider.freezed.dart';

@freezed
class ImageProcessorState with _$ImageProcessorState {
  const ImageProcessorState._();
  const factory ImageProcessorState({
    required List<int> lccResult,
  }) = _ImageProcessorState;

  factory ImageProcessorState.initial() =>
      const ImageProcessorState(lccResult: []);
  int get remaining => (10 - lccResult.length).toInt();
  double get percentage => lccResult.length.toDouble();
}

// * ImageProcessorNotifier

class ImageProcessorNotifier extends AsyncNotifier<ImageProcessorState> {
  @override
  FutureOr<ImageProcessorState> build() {
    return ImageProcessorState.initial();
  }

  Future<SegmentationResult?> captureAndSegmentImage({
    required CameraController controller,
    required Interpreter interpreter,
  }) async {
    SegmentationResult? result;

    state = const AsyncLoading();
    Uint8List? image =
        await _captureImage(controller: controller, interpreter: interpreter);
    if (image != null) {
      result = await _removeBackgroundFromImage(
        imageBytes: image,
        interpreter: interpreter,
      );
      state = AsyncData(state.value!);
    } else {
      logger.e('Error captureing image');
      state = AsyncError('Error capturing image', StackTrace.current);
    }

    if (result == null) {
      logger.e('Error segmenting image');
      state = AsyncError('Error segmenting image', StackTrace.current);
    }

    return result;
  }

  void resetPrediction() {
    state = AsyncData(ImageProcessorState.initial());
  }

  Future<Uint8List?> _captureImage({
    required CameraController controller,
    required Interpreter interpreter,
  }) async {
    Uint8List? image;

    state = const AsyncLoading();
    final repo = ref.watch(imageProcessingRepositoryProvider);

    final result = await repo.takePicture(
      controller: controller,
      interpreter: interpreter,
    );

    // fold the result
    result.fold(
      (failure) {
        state = AsyncError(failure.msg, StackTrace.current);
        image = null;
      },
      (imageBytes) {
        image = imageBytes;
      },
    );
    return image;
  }

  Future<SegmentationResult?> _removeBackgroundFromImage({
    required Uint8List imageBytes,
    required Interpreter interpreter,
  }) async {
    SegmentationResult? output;
    state = const AsyncLoading();
    final repo = ref.watch(imageProcessingRepositoryProvider);
    final result = await repo.removeBackgroundFromImage(
      imageBytes: imageBytes,
      interpreter: interpreter,
    );

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (segmentationResult) {
        state = AsyncData(state.value!);
        return output = segmentationResult;
      },
    );
    return output;
  }

  Future<void> updateState({required int result}) async {
    state = AsyncData(
      ImageProcessorState(lccResult: [...state.value!.lccResult, result]),
    );
    logger.i('Statee: ${state.value?.lccResult}');
  }

  Future<int> classifyImages({
    required Interpreter interpreter,
    required Uint8List segmentedImage,
  }) async {
    int lccResult = -1;
    final repo = ref.watch(imageProcessingRepositoryProvider);
    state = const AsyncLoading();
    final result = await repo.runClassificatinModel(
      interpreter: interpreter,
      input: segmentedImage,
    );

    result.fold((error) {
      state = AsyncError(error, StackTrace.current);
    }, (outputLabel) {
      state = AsyncData(state.value!);
      lccResult = outputLabel;
    });
    return lccResult;
  }
}

final imageProcessorProvider =
    AsyncNotifierProvider<ImageProcessorNotifier, ImageProcessorState>(
  ImageProcessorNotifier.new,
);
