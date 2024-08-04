import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/domain/camera_failure.dart';
import 'package:rice_fertile_ai/domain/segmentation_result.dart';
import 'package:rice_fertile_ai/infrastructure/camera_datasource.dart';
import 'package:rice_fertile_ai/infrastructure/image_processing_service.dart';
import 'package:rice_fertile_ai/infrastructure/tflite_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class InputImageRepository {
  final CameraDataSource _cameraService;
  final ModelRunner _tfliteModelRunner;
  final ImageProcessingService _imgProcessor;

  InputImageRepository(
    this._cameraService,
    this._tfliteModelRunner,
    this._imgProcessor,
  );

  Future<Either<Uint8List, CameraFailure>> takePicture(
      {required CameraController controller,
      required Interpreter interpreter}) async {
    try {
      // * Take picture from camera
      final XFile xFileImage =
          await _cameraService.takePicture(controller: controller);

      logger.i('[Repository] Returning image bytes');
      final Uint8List imageBytes = await xFileImage.readAsBytes();

      return left(imageBytes);
    } on CameraException catch (e) {
      return right(
          CameraFailure.cameraException(e.description ?? 'Unknown Error!'));
    } on CameraInitializationException catch (e) {
      return right(CameraFailure.cameraException(e.message));
    }
  }

  Future<SegmentationResult> removeBackgroundFromImage({
    required Uint8List imageBytes,
    required Interpreter interpreter,
  }) async {
    // * Prepare Input Tensor
    final imageReshaped = _imgProcessor.getReshapedImage(imageData: imageBytes);
    final imageReshapedBytes = Uint8List.fromList(img.encodePng(imageReshaped));
    final inputTensor = _imgProcessor.getInputTensor(image: imageReshaped);

    // * Prepare Output Tesnsor
    final outputTensor = _imgProcessor.getSegmentationModelsOutputTensor();

    // * Run PreProcessor Model
    final segmentationTensor = await _tfliteModelRunner.runPreProcessorModel(
      interpreter: interpreter,
      input: inputTensor,
      output: outputTensor,
    );

    // * Apply Segmentation Mask
    final outputImage = _imgProcessor.applySegmentationMask(
      originalImage: imageReshaped,
      outputTensor: segmentationTensor!,
    );
    return SegmentationResult(
      originalImage: imageReshapedBytes,
      outputImage: outputImage,
    );
  }

  // * test classification model
  void runClassificatinModel({
    required Interpreter interpreter,
    required Uint8List input,
  }) async {
    // * Prepare Input Tensor
    final imageReshaped = _imgProcessor.getReshapedImage(imageData: input);
    final inputTensor = _imgProcessor.getInputTensor(image: imageReshaped);
    // final outputeTensor = _imgProcessor.getClassificationModelsOutputTensor();
    final outputTensor = [
      [0.0, 0.0, 0.0, 0.0]
    ];
    // * Run classification model
    await _tfliteModelRunner.runClassificatinModel(
      interpreter: interpreter,
      input: inputTensor,
      output: outputTensor,
    );

    logger.i('Input shape: ${interpreter.getInputTensor(0).shape}');
    logger.i('output shape: ${interpreter.getOutputTensor(0).shape}');
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
