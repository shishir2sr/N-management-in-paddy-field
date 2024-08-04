import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/domain/segmentation_result.dart';
import 'package:rice_fertile_ai/infrastructure/image_analysis_repository.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
part 'image_processror_notifier_provider.freezed.dart';

@freezed
class ImageProcessorState with _$ImageProcessorState {
  const factory ImageProcessorState({
    required List<Uint8List> originalImage,
    required List<Uint8List> processedImages,
  }) = _ImageProcessorState;

  factory ImageProcessorState.initial() => const ImageProcessorState(
        originalImage: [],
        processedImages: [],
      );
}

// * ImageProcessorNotifier

class ImageProcessorNotifier extends AsyncNotifier<ImageProcessorState> {
  @override
  FutureOr<ImageProcessorState> build() {
    return ImageProcessorState.initial();
  }

  Future<Uint8List?> captureImage({
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

  Future<SegmentationResult> removeBackgroundFromImage({
    required Uint8List imageBytes,
    required Interpreter interpreter,
  }) async {
    state = const AsyncLoading();
    final repo = ref.watch(imageProcessingRepositoryProvider);
    final result = await repo.removeBackgroundFromImage(
      imageBytes: imageBytes,
      interpreter: interpreter,
    );
    state = AsyncData(state.value!);
    return result;
  }

  void updateImageList(SegmentationResult segmentationResult) {
    state = AsyncData(
      ImageProcessorState(
        originalImage: [
          ...state.value!.originalImage,
          segmentationResult.originalImage
        ],
        processedImages: [
          ...state.value!.processedImages,
          segmentationResult.outputImage
        ],
      ),
    );
  }

  Future<void> classifyImages({
    required Interpreter interpreter,
    required Uint8List segmentedImage,
  }) async {
    final repo = ref.watch(imageProcessingRepositoryProvider);
    repo.runClassificatinModel(interpreter: interpreter, input: segmentedImage);
  }
}

final imageProcessorProvider =
    AsyncNotifierProvider<ImageProcessorNotifier, ImageProcessorState>(
  ImageProcessorNotifier.new,
);
