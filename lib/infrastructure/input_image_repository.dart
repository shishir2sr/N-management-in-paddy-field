import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/domain/camera_failure.dart';
import 'package:rice_fertile_ai/infrastructure/camera_datasource.dart';
import 'package:rice_fertile_ai/infrastructure/image_processing_service.dart';
import 'package:rice_fertile_ai/infrastructure/tflite_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class InputImageRepository {
  final CameraDataSource _cameraService;
  final ModelRunner _tfliteModelRunner;
  final ImageProcessingService _imageProcessingService;

  InputImageRepository(this._cameraService, this._tfliteModelRunner,
      this._imageProcessingService);

  Future<Either<(Uint8List, Uint8List), CameraFailure>> takePicture(
      {required CameraController controller,
      required Interpreter interpreter}) async {
    try {
      final XFile xFileImage =
          await _cameraService.takePicture(controller: controller);
      xFileImage.readAsBytes();
      logger.i('[Repository] Returning image bytes');
      final Uint8List imageBytes = await xFileImage.readAsBytes();
      final inputAndOutputImage = await removeBackground(
          imageBytes: imageBytes, interpreter: interpreter);

      return left(inputAndOutputImage);
    } on CameraException catch (e) {
      return right(
          CameraFailure.cameraException(e.description ?? 'Unknown Error!'));
    } on CameraInitializationException catch (e) {
      return right(CameraFailure.cameraException(e.message));
    }
  }

  Future<(Uint8List, Uint8List)> removeBackground(
      {required Uint8List imageBytes, required Interpreter interpreter}) async {
    final resizedImage =
        _imageProcessingService.getReshapedImage(imageData: imageBytes);
    final resizedImageBytes = Uint8List.fromList(img.encodePng(resizedImage));

    final inputTensor =
        _imageProcessingService.getInputTensor(image: resizedImage);

    final outputTensor = _imageProcessingService.getOutputTensor();

    final segmentationTensor = await _tfliteModelRunner.runPreProcessorModel(
        interpreter: interpreter, input: inputTensor, output: outputTensor);

    final outputImage = _imageProcessingService.getOutputImage(
        originalImage: resizedImage, outputTensor: segmentationTensor!);

    return (resizedImageBytes, outputImage);
  }
}

// * ImageProcessingRepositoryProvider
final imageProcessingRepositoryProvider = Provider<InputImageRepository>((ref) {
  final cameraService = ref.watch(cameraDataSourceProvider);
  final modelRunner = ref.watch(modelRunnerProvider);
  final imageProcessingService = ref.watch(imageProcessingServiceProvider);
  return InputImageRepository(
      cameraService, modelRunner, imageProcessingService);
});
