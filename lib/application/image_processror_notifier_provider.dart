import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/infrastructure/input_image_repository.dart';
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
    return ImageProcessorState.initial();
  }

  Future<Uint8List?> captureImage(
      {required CameraController controller}) async {
    state = const AsyncLoading();
    final repo = ref.watch(imageProcessingRepositoryProvider);
    final result = await repo.takePicture(controller: controller);
    Uint8List? image;

    // fold the result
    result.fold(
      (imageBytes) {
        return image = imageBytes;
      },
      (failure) {
        state = AsyncError(failure.msg, StackTrace.current);
        return image = null;
      },
    );
    return image;
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
