import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'inference_isolate_client.dart';
import 'inference_protocol.dart';

/// Owns the inference isolate for the lifetime of the `ProviderScope`.
///
/// Deliberately **not** `autoDispose`: the previous `interpreterProvider` was
/// `FutureProvider.autoDispose.family`, which both leaked ~24 MB of native
/// memory per camera-page entry (`Interpreter.fromAsset` never frees its
/// flatbuffer) and could free the native handle while `invoke()` was still
/// running on it. Memory is reclaimed explicitly instead — on an idle timeout
/// inside the client, and via [InferenceLifecycleObserver] when the app is
/// backgrounded.
final inferenceClientProvider = Provider<InferenceIsolateClient>((ref) {
  final client = InferenceIsolateClient();
  ref.onDispose(client.dispose);
  return client;
});

/// Starts the isolate and loads both models. Watch this to gate UI that needs
/// the models (the shutter button, the gallery picker).
final inferenceWarmupProvider = FutureProvider<IsolateReady>((ref) {
  return ref.watch(inferenceClientProvider).warmUp();
});

/// Releases the tensor arenas when the app leaves the foreground.
///
/// Register once, near the root of the widget tree.
class InferenceLifecycleObserver with WidgetsBindingObserver {
  InferenceLifecycleObserver(this._read);

  final InferenceIsolateClient Function() _read;

  void attach() => WidgetsBinding.instance.addObserver(this);
  void detach() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused &&
        state != AppLifecycleState.detached) {
      return;
    }
    try {
      _read().releaseResources();
    } catch (_) {
      // On `detached` the ProviderScope may already be tearing down, in which
      // case its own onDispose has handled this.
    }
  }
}
