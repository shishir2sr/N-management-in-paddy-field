import 'package:freezed_annotation/freezed_annotation.dart';
part 'camera_failure.freezed.dart';

@freezed
class CameraFailure with _$CameraFailure {
  const CameraFailure._();
  const factory CameraFailure.cameraAccessDenied(String msg) =
      _CameraAccessDenied;
  const factory CameraFailure.previuslyDenied(String msg) = _PreviuslyDenied;
  const factory CameraFailure.accessRestricted(String msg) = _AccessRestricted;
}

class CameraInitializationException implements Exception {
  final String message;

  CameraInitializationException(this.message);

  @override
  String toString() => 'CameraInitializationException: $message';
}

class CameraCaptureException implements Exception {
  final String message;

  CameraCaptureException(this.message);

  @override
  String toString() => 'CameraCaptureException: $message';
}
