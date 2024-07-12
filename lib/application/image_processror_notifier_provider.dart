import 'dart:async';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/infrastructure/camera_datasource.dart';
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

class ImageProcessorNotifier
    extends AutoDisposeAsyncNotifier<ImageProcessorState> {
  @override
  FutureOr<ImageProcessorState> build() {
    return ImageProcessorState.initial();
  }

  void captureImage() async {
    state = const AsyncLoading();
    final controller = ref.watch(cameraControllerProviderProvider).value;
    final repo = ref.watch(imageProcessingRepositoryProvider);

    if (controller == null) {
      state =
          AsyncError('Camera controller not initialized', StackTrace.current);
    }

    final result = await repo.takePicture(controller: controller!);

    // fold the result
    result.fold(
      (imageBytes) {
        state = AsyncData(
          ImageProcessorState(
            imageBytes: [...state.value!.imageBytes, imageBytes],
          ),
        );
      },
      (failure) {
        state = AsyncError(failure.msg, StackTrace.current);
      },
    );
  }
}

final imageProcessorProvider = AsyncNotifierProvider.autoDispose<
    ImageProcessorNotifier, ImageProcessorState>(ImageProcessorNotifier.new);
