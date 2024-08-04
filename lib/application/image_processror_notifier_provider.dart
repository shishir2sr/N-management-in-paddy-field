import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/string_constants.dart';
import 'package:rice_fertile_ai/domain/segmentation_result.dart';
import 'package:rice_fertile_ai/infrastructure/input_image_repository.dart';
import 'package:rice_fertile_ai/infrastructure/tflite_service.dart';
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
      (imageBytes) {
        image = imageBytes;
      },
      (failure) {
        state = AsyncError(failure.msg, StackTrace.current);
        image = null;
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

  void testClassificatinModel({required Interpreter interpreter}) async {
    final repo = ref.watch(imageProcessingRepositoryProvider);
    var testImagePath = StringConstants.testImagePath;

    // Load the image as Uint8List from assets
    ByteData byteData = await rootBundle.load(testImagePath);
    Uint8List imageBytes = byteData.buffer.asUint8List();

    repo.runClassificatinModel(interpreter: interpreter, input: imageBytes);
  }
}

final imageProcessorProvider =
    AsyncNotifierProvider<ImageProcessorNotifier, ImageProcessorState>(
  ImageProcessorNotifier.new,
);
