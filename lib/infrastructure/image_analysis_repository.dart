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

class ImageAnalysisRepository {
  final CameraDataSource _cameraService;
  final ModelRunner _tfliteModelRunner;
  final ImageProcessingService _imgProcessor;

  ImageAnalysisRepository(
    this._cameraService,
    this._tfliteModelRunner,
    this._imgProcessor,
  );

  Future<Either<CameraFailure, Uint8List>> takePicture(
      {required CameraController controller,
      required Interpreter interpreter}) async {
    try {
      // * Take picture from camera
      final XFile xFileImage =
          await _cameraService.takePicture(controller: controller);

      logger.i('[Repository] Returning image bytes');
      final Uint8List imageBytes = await xFileImage.readAsBytes();

      return right(imageBytes);
    } on CameraException catch (e) {
      return left(
          CameraFailure.cameraException(e.description ?? 'Unknown Error!'));
    } on CameraInitializationException catch (e) {
      return left(CameraFailure.cameraException(e.message));
    }
  }

  Future<SegmentationResult> removeBackgroundFromImage({
    required Uint8List imageBytes,
    required Interpreter interpreter,
  }) async {
    try {
      // * Prepare Input Tensor
      final imageReshaped =
          _imgProcessor.getReshapedImage(imageData: imageBytes);
      final imageReshapedBytes = Uint8List.fromList(
          img.encodePng(imageReshaped)); // this will return as original image
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
    } catch (e) {
      logger.e('Error removing background: $e');
      throw Exception('Error removing background');
    }
  }

  // * test classification model
  Future<void> runClassificatinModel({
    required Interpreter interpreter,
    required Uint8List input,
  }) async {
    // * Prepare Input Tensor

    img.Image? image = img.decodeImage(Uint8List.fromList(input));
    final inputTensor = _imgProcessor.getInputTensor(image: image!);

    final outputTensor = [
      [0.0, 0.0, 0.0, 0.0]
    ];
    // * Run classification model
    _tfliteModelRunner.runClassificatinModel(
      interpreter: interpreter,
      input: inputTensor,
      output: outputTensor,
    );

    logger.i('Input shape: ${interpreter.getInputTensor(0).shape}');
    logger.i('output shape: ${interpreter.getOutputTensor(0).shape}');
  }
}

// * ImageProcessingRepositoryProvider
final imageProcessingRepositoryProvider =
    Provider<ImageAnalysisRepository>((ref) {
  final cameraService = ref.watch(cameraDataSourceProvider);
  final modelRunner = ref.watch(modelRunnerProvider);
  final imageProcessingService = ref.watch(imageProcessingServiceProvider);
  return ImageAnalysisRepository(
      cameraService, modelRunner, imageProcessingService);
});
