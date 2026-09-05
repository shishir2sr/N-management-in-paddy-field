import 'dart:async';
import 'dart:isolate';

import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/core/shared/string_constants.dart';

import 'inference_isolate_entry.dart';
import 'inference_protocol.dart';
import 'model_asset_cache.dart';

/// Thrown for any failure of the inference pipeline. Carries the stage so the
/// UI can distinguish "your photo could not be read" from "the model failed".
class InferenceException implements Exception {
  InferenceException(this.message, {this.stage});

  final String message;
  final String? stage;

  @override
  String toString() =>
      stage == null ? message : 'InferenceException[$stage]: $message';
}

/// UI-isolate handle onto the dedicated inference isolate.
///
/// Requests are serialised, so a double tap on the shutter cannot interleave
/// two analyses, and — unlike `tflite_flutter`'s own `IsolateInterpreter` — a
/// request is never silently dropped.
class InferenceIsolateClient {
  InferenceIsolateClient({
    this.segmentationAssetKey = StrConsts.segmentationModelPath,
    this.classificationAssetKey = StrConsts.classificationModelPath,
  });

  final String segmentationAssetKey;
  final String classificationAssetKey;

  /// Generous: on a cold first run this covers copying ~40 MB of models out of
  /// the asset bundle before either interpreter is built.
  static const Duration startupTimeout = Duration(seconds: 120);
  static const Duration defaultAnalyzeTimeout = Duration(seconds: 45);

  /// Two live interpreters hold their tensor arenas for as long as they exist,
  /// which for a 256x256 U-Net is far more memory than the model files
  /// themselves. Give it back when the user stops capturing.
  static const Duration idleTimeout = Duration(minutes: 2);

  Isolate? _isolate;
  SendPort? _commandPort;
  ReceivePort? _responsePort;
  ReceivePort? _errorPort;
  ReceivePort? _exitPort;

  Future<IsolateReady>? _startup;
  IsolateReady? _ready;

  final Map<int, Completer<AnalyzeSuccess>> _pending = {};
  int _nextRequestId = 0;
  Future<void> _tail = Future<void>.value();
  bool _disposed = false;

  /// Suppresses the "exited unexpectedly" path during an intentional shutdown.
  bool _shuttingDown = false;

  /// Completed by the single exit-port listener when an intentional shutdown
  /// finishes. `ReceivePort` is a single-subscription stream, so a second
  /// `listen` on it throws `StateError` — the ack has to be routed through the
  /// one listener registered in [_start].
  Completer<void>? _shutdownAck;
  Timer? _idleTimer;

  IsolateReady? get shapes => _ready;

  bool get isRunning => _commandPort != null;

  /// Spawns the isolate and loads both models. Safe to call repeatedly — later
  /// calls join the in-flight startup.
  Future<IsolateReady> warmUp() {
    if (_disposed) {
      throw InferenceException('Inference client has been disposed');
    }
    return _startup ??= _start();
  }

  Future<AnalyzeSuccess> analyze(
    String imagePath, {
    double maskThreshold = 0.6,
    bool deleteSourceWhenDone = false,
    Duration timeout = defaultAnalyzeTimeout,
  }) {
    return _serialise(() async {
      _idleTimer?.cancel();
      await warmUp();
      final commandPort = _commandPort;
      if (commandPort == null) {
        throw InferenceException('Inference isolate is not running');
      }

      final id = _nextRequestId++;
      final completer = Completer<AnalyzeSuccess>();
      _pending[id] = completer;

      commandPort.send(AnalyzeImageRequest(
        id: id,
        imagePath: imagePath,
        maskThreshold: maskThreshold,
        deleteSourceWhenDone: deleteSourceWhenDone,
      ));

      try {
        final result = await completer.future.timeout(timeout);
        _restartIdleTimer();
        return result;
      } on TimeoutException {
        _pending.remove(id);
        // A wedged native `invoke()` cannot be interrupted, so the isolate is
        // no longer trustworthy. Tear it down; the next call restarts it.
        logger.e('Inference timed out after ${timeout.inSeconds}s — restarting '
            'isolate');
        await _teardown(
          reason: 'Inference timed out',
          graceful: false,
        );
        throw InferenceException(
          'Analysis took longer than ${timeout.inSeconds}s',
        );
      }
    });
  }

  /// Shuts the isolate down but leaves the client reusable — the next
  /// [analyze] or [warmUp] transparently starts a fresh one.
  ///
  /// Call this when the app is backgrounded, or when the capture flow is left,
  /// to hand the tensor arenas back to the OS.
  Future<void> releaseResources() async {
    _idleTimer?.cancel();
    _idleTimer = null;
    if (_isolate == null && _startup == null) return;
    await _serialise(
      () => _teardown(reason: 'Resources released', graceful: true),
    );
  }

  /// Closes both interpreters inside the isolate and waits for the
  /// acknowledgement before killing it.
  ///
  /// `Isolate.kill()` on its own leaves the TFLite tensor arenas allocated —
  /// they are process-level allocations, not isolate-owned.
  Future<void> dispose() async {
    _disposed = true;
    _idleTimer?.cancel();
    _idleTimer = null;
    await _teardown(reason: 'Client disposed', graceful: true);
  }

  void _restartIdleTimer() {
    _idleTimer?.cancel();
    if (_disposed) return;
    _idleTimer = Timer(idleTimeout, () {
      logger.i('Inference isolate idle for ${idleTimeout.inMinutes}m — '
          'releasing');
      releaseResources();
    });
  }

  Future<IsolateReady> _start() async {
    // Defensive: a previous failed start could otherwise leak its ports.
    _closePorts();

    final responsePort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();
    _responsePort = responsePort;
    _errorPort = errorPort;
    _exitPort = exitPort;

    final ready = Completer<IsolateReady>();

    responsePort.listen((message) => _onMessage(message, ready));

    errorPort.listen((message) {
      final description = message is List && message.isNotEmpty
          ? message.first.toString()
          : message.toString();
      logger.e('Inference isolate error: $description');
      _failEverything('Inference isolate error: $description', ready);
    });

    // Without this, an isolate that dies mid-request leaves every completer
    // unresolved and the UI hangs on a spinner forever.
    exitPort.listen((_) {
      final ack = _shutdownAck;
      if (ack != null) {
        if (!ack.isCompleted) ack.complete();
        return;
      }
      if (_shuttingDown) return;
      _failEverything('Inference isolate exited unexpectedly', ready);
      // The isolate is gone, so nothing will send on these again.
      _closePorts();
    });

    // Extraction happens here, on the root isolate, because both `rootBundle`
    // and `path_provider` need Flutter bindings that a spawned isolate does not
    // have. Reading the asset from the isolate was tried both ways and neither
    // works — see ModelAssetCache for the two failure modes.
    final List<String> modelPaths;
    try {
      modelPaths = await const ModelAssetCache().ensureExtracted([
        segmentationAssetKey,
        classificationAssetKey,
      ]);
    } catch (e) {
      _closePorts();
      throw InferenceException(
        'Could not unpack the analysis models: $e',
        stage: InferenceStage.init,
      );
    }

    try {
      _isolate = await Isolate.spawn(
        inferenceIsolateEntry,
        InferenceInit(
          replyPort: responsePort.sendPort,
          segmentationModelPath: modelPaths[0],
          classificationModelPath: modelPaths[1],
        ),
        onError: errorPort.sendPort,
        onExit: exitPort.sendPort,
        errorsAreFatal: true,
        debugName: 'lcc-inference',
      );
    } catch (e) {
      await _teardown(reason: 'Spawn failed', graceful: false);
      throw InferenceException(
        'Could not start inference isolate: $e',
        stage: InferenceStage.init,
      );
    }

    try {
      final result = await ready.future.timeout(startupTimeout);
      _ready = result;
      logger.i('Inference isolate ready — $result');
      return result;
    } on TimeoutException {
      await _teardown(reason: 'Startup timed out', graceful: false);
      throw InferenceException(
        'Loading the models took longer than '
        '${startupTimeout.inSeconds}s',
        stage: InferenceStage.init,
      );
    }
  }

  void _onMessage(Object? message, Completer<IsolateReady> ready) {
    if (message is SendPort) {
      _commandPort = message;
      return;
    }

    if (message is IsolateReady) {
      if (!ready.isCompleted) ready.complete(message);
      return;
    }

    if (message is AnalyzeSuccess) {
      _pending.remove(message.id)?.complete(message);
      return;
    }

    if (message is InferenceFailure) {
      if (message.id == IsolateReady.readyResponseId) {
        if (!ready.isCompleted) {
          ready.completeError(
            InferenceException(message.message, stage: message.stage),
          );
        }
        return;
      }
      logger.e('Inference failed at ${message.stage}: ${message.message}');
      _pending.remove(message.id)?.completeError(
            InferenceException(message.message, stage: message.stage),
          );
      return;
    }

    if (message is ShutdownComplete) {
      _pending.remove(message.id)?.completeError(
            InferenceException('Inference isolate shut down'),
          );
      return;
    }
  }

  void _failEverything(String reason, Completer<IsolateReady> ready) {
    if (!ready.isCompleted) {
      ready.completeError(InferenceException(reason));
    }
    final pending = List.of(_pending.entries);
    _pending.clear();
    for (final entry in pending) {
      if (!entry.value.isCompleted) {
        entry.value.completeError(InferenceException(reason));
      }
    }
    // Force the next call to spawn a fresh isolate.
    _commandPort = null;
    _startup = null;
    _ready = null;
  }

  void _closePorts() {
    _responsePort?.close();
    _errorPort?.close();
    _exitPort?.close();
    _responsePort = null;
    _errorPort = null;
    _exitPort = null;
  }

  Future<void> _teardown({
    required String reason,
    required bool graceful,
  }) async {
    final commandPort = _commandPort;
    final isolate = _isolate;

    _shuttingDown = true;
    _commandPort = null;
    _isolate = null;
    _startup = null;
    _ready = null;

    if (graceful && commandPort != null && isolate != null) {
      final id = _nextRequestId++;
      final acknowledged = Completer<void>();
      _shutdownAck = acknowledged;

      // The isolate closes both interpreters, replies ShutdownComplete, then
      // calls Isolate.exit(). Either signal resolves the ack — the exit is the
      // backstop if the reply is lost.
      _pending[id] = Completer<AnalyzeSuccess>()
        ..future.whenComplete(() {
          if (!acknowledged.isCompleted) acknowledged.complete();
        }).ignore();

      commandPort.send(ShutdownRequest(id));
      await acknowledged.future
          .timeout(const Duration(seconds: 5), onTimeout: () {});
      _shutdownAck = null;
    }

    for (final pending in _pending.values) {
      if (!pending.isCompleted) {
        pending.completeError(InferenceException(reason));
      }
    }
    _pending.clear();

    isolate?.kill(priority: Isolate.immediate);
    _closePorts();
    _shuttingDown = false;
  }

  /// Runs [body] after every previously queued request has settled.
  Future<T> _serialise<T>(Future<T> Function() body) {
    final result = _tail.then((_) => body());
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }
}
