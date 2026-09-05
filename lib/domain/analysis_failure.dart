/// Failures the capture-and-analyse pipeline can produce.
///
/// Replaces the old freezed `CameraFailure` union (of whose four variants only
/// `cameraException` was ever constructed, so permission denial was
/// indistinguishable from hardware failure) and the stringly-typed
/// `Either<String, _>` used by the model paths.
///
/// A plain sealed class rather than freezed: there is no `copyWith`/equality
/// need here, and it keeps ~700 lines of generated code out of the tree.
sealed class AnalysisFailure implements Exception {
  const AnalysisFailure(this.message);

  /// Safe to show to the user as-is.
  final String message;

  /// Whether the user can fix this from the system settings screen.
  bool get needsSettings => false;

  @override
  String toString() => '$runtimeType: $message';
}

/// Camera permission was denied for this session.
class CameraAccessDeniedFailure extends AnalysisFailure {
  const CameraAccessDeniedFailure([
    super.message = 'Camera access is needed to capture paddy images.',
  ]);
}

/// Camera permission was denied permanently, or is blocked by device policy —
/// re-prompting will not show a dialog.
class CameraAccessBlockedFailure extends AnalysisFailure {
  const CameraAccessBlockedFailure([
    super.message = 'Camera access is blocked. Enable it in Settings to '
        'capture photos.',
  ]);

  @override
  bool get needsSettings => true;
}

/// The camera hardware or plugin failed (initialisation or capture).
class CameraFailure extends AnalysisFailure {
  const CameraFailure(super.message);
}

/// Decoding, segmentation or classification failed.
class ProcessingFailure extends AnalysisFailure {
  const ProcessingFailure(super.message, {this.stage});

  final String? stage;
}

/// Thrown rather than returned, for the camera provider's initialise path.
class CameraInitializationException implements Exception {
  CameraInitializationException(this.message);

  final String message;

  @override
  String toString() => 'CameraInitializationException: $message';
}
