import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/string_constants.dart';
import 'package:rice_fertile_ai/infrastructure/input_image_repository.dart';
import 'package:rice_fertile_ai/infrastructure/tflite_service.dart';
part 'image_processror_notifier_provider.freezed.dart';

@freezed
class ImageProcessorState with _$ImageProcessorState {
  const factory ImageProcessorState({
    required List<Uint8List> imageBytes,
  }) = _ImageProcessorState;

  factory ImageProcessorState.initial() => const ImageProcessorState(
        imageBytes: [],
      );
}

// * ImageProcessorNotifier

class ImageProcessorNotifier extends AsyncNotifier<ImageProcessorState> {
  @override
  FutureOr<ImageProcessorState> build() {
    ref.watch(interpreterProvider(StringConstants.segmentationModelPath));
    return ImageProcessorState.initial();
  }

  Future<(Uint8List, Uint8List)?> captureImage(
      {required CameraController controller}) async {
    state = const AsyncLoading();
    final repo = ref.watch(imageProcessingRepositoryProvider);

    final interpreterAsyncValue =
        ref.watch(interpreterProvider(StringConstants.segmentationModelPath));

    return interpreterAsyncValue.when(
      loading: () {
        state = const AsyncLoading();
        return null;
      },
      error: (err, stack) {
        state = AsyncError(err, stack);
        return null;
      },
      data: (interpreter) async {
        final result = await repo.takePicture(
            controller: controller, interpreter: interpreter);
        (Uint8List, Uint8List)? images;

        // fold the result
        result.fold(
          (inputAndOutputImage) {
            images = inputAndOutputImage;
          },
          (failure) {
            state = AsyncError(failure.msg, StackTrace.current);
            images = null;
          },
        );
        return images;
      },
    );
  }

  void updateImageList(Uint8List imageBytes) {
    state = AsyncData(
      ImageProcessorState(
        imageBytes: [...state.value!.imageBytes, imageBytes],
      ),
    );
  }
}

final imageProcessorProvider =
    AsyncNotifierProvider<ImageProcessorNotifier, ImageProcessorState>(
  ImageProcessorNotifier.new,
);
