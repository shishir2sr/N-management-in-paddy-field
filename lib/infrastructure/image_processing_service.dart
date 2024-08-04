import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:rice_fertile_ai/domain/tensor4d.dart';

abstract class ImageProcessingService {
  /// Reshapes the provided image data and returns the reshaped image as an [img.Image] object.
  ///
  /// The [imageData] parameter is a required [Uint8List] that represents the image data.
  /// This method processes the image data and returns the reshaped image as an [img.Image] object.
  /// The reshaped image can be used for further image processing or display purposes.
  ///
  /// Example usage:
  /// ```dart
  /// Uint8List imageData = ... // provide the image data
  /// img.Image reshapedImage = getReshapedImage(imageData: imageData);
  /// // use the reshapedImage for further processing or display
  /// ```
  img.Image getReshapedImage(
      {required Uint8List imageData, int width = 256, int height = 256});

  /// Returns the input tensor for image processing.
  ///
  /// This method is responsible for generating and returning the input tensor
  /// that will be used for image processing operations. The input tensor is a
  /// Tensor4D object that represents the image data.
  ///
  /// Returns:
  ///   A Tensor4D object representing the input tensor for image processing.
  Tensor4D getInputTensor({required img.Image image});

  /// Retrieves the output image as a Uint8List.
  ///
  /// Returns the output image as a Uint8List. This method is responsible for
  /// processing and generating the output image based on the input image.
  /// The output image is represented as a Uint8List, which can be used for
  /// further operations or display.
  ///
  /// Example usage:
  /// ```dart
  /// Uint8List outputImage = imageProcessingService.getOutputImage();
  /// ```

  Uint8List applySegmentationMask(
      {required img.Image originalImage, required Tensor4D outputTensor});

  /// Returns the output tensor of the image processing service.
  ///
  /// The output tensor represents the processed image data. It is a Tensor4D object
  /// that contains the processed image data in a multi-dimensional array format.
  /// This tensor can be used for further analysis or visualization.
  ///
  /// Returns:
  ///   - A Tensor4D object representing the output tensor of the image processing service.
  ///
  /// Example usage:
  /// ```dart
  /// Tensor4D outputTensor = imageProcessingService.getOutputTensor();
  /// ```
  ///
  /// See also:
  ///   - [Tensor4D] class
  ///
  Tensor4D getSegmentationModelsOutputTensor();

  List<List<double>> getClassificationModelsOutputTensor();
}

class ImageProcessingServiceImpl implements ImageProcessingService {
  @override
  img.Image getReshapedImage({
    required Uint8List imageData,
    int width = 256,
    int height = 256,
  }) {
    img.Image? image = img.decodeImage(Uint8List.fromList(imageData));
    return img.copyResize(image!, width: width, height: height);
  }

  @override
  Tensor4D getInputTensor({
    required img.Image image,
  }) {
    final height = image.height;
    final width = image.width;
    Tensor4D tensor = List.generate(
      1,
      (_) => List.generate(
        height,
        (_) => List.generate(
          width,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        var pixel = image.getPixel(x, y);
        tensor[0][y][x][0] = (pixel.r / 255.0); // Normalize Red
        tensor[0][y][x][1] = (pixel.g / 255.0); // Normalize Green
        tensor[0][y][x][2] = (pixel.b / 255.0); // Normalize Blue
      }
    }

    return tensor;
  }

  @override
  Uint8List applySegmentationMask(
      {required img.Image originalImage, required Tensor4D outputTensor}) {
    int width = originalImage.width;
    int height = originalImage.height;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Determine if the current pixel is part of the foreground
        bool isForeground = outputTensor[0][y][x][0] > 0.6;

        // If the pixel is not part of the foreground, set its alpha to 0
        if (!isForeground) {
          originalImage.setPixelRgba(
              x, y, 0, 0, 0, 0); // Set pixel to fully transparent
        }
      }
    }

    // Encode the modified image to PNG and return as Uint8List
    return Uint8List.fromList(img.encodePng(originalImage));
  }

  @override
  Tensor4D getSegmentationModelsOutputTensor() {
    return List.generate(
      1,
      (_) => List.generate(
        256,
        (_) => List.generate(
          256,
          (_) => List.filled(1, 0.0),
        ),
      ),
    );
  }

  @override
  List<List<double>> getClassificationModelsOutputTensor() {
    return List.generate(1, (_) => List.filled(4, 0.0));
  }
}

// * create provider for ImageProcessingService

final imageProcessingServiceProvider = Provider<ImageProcessingService>(
  (ref) => ImageProcessingServiceImpl(),
);
