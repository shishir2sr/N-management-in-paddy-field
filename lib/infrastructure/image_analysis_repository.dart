import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/domain/camera_failure.dart';
import 'package:LCC/domain/segmentation_result.dart';
import 'package:LCC/domain/typedefs.dart';
import 'package:LCC/infrastructure/camera_datasource.dart';
import 'package:LCC/infrastructure/image_processing_service.dart';
import 'package:LCC/infrastructure/tflite_service.dart';
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

  Future<Either<String, SegmentationResult>> removeBackgroundFromImage({
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
      return right(SegmentationResult(
        originalImage: imageReshapedBytes,
        outputImage: outputImage,
      ));
    } catch (e) {
      logger.e('Error removing background: ${e.toString()}');
      return left('Error removing background');
    }
  }

  // * test classification model
  Future<Either<String, int>> runClassificatinModel({
    required Interpreter interpreter,
    required Uint8List input,
  }) async {
    // * Prepare Input Tensor
    img.Image? image = img.decodeImage(Uint8List.fromList(input));
    if (image == null) return left('Image cannot be decoded');
    final inputTensor = _imgProcessor.getInputTensor(image: image);
    Tensor2D outputTensor = [
      [0.0, 0.0, 0.0, 0.0]
    ];

    // * Run classification model
    final result = _tfliteModelRunner.runClassificatinModel(
      interpreter: interpreter,
      input: inputTensor,
      output: outputTensor,
    );
    logger.i('result: $result');
    return right(result);
  }
}

// * ImageProcessingRepositoryProvider
final imageProcessingRepositoryProvider =
    Provider<ImageAnalysisRepository>((ref) {
  final cameraService = ref.watch(cameraDataSourceProvider);
  final modelRunner = ref.watch(modelRunnerProvider);
  final imageProcessingService = ref.watch(imageProcessingServiceProvider);

  return ImageAnalysisRepository(
    cameraService,
    modelRunner,
    imageProcessingService,
  );
});
