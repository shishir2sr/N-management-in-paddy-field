import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

/// In release builds only warnings and above are emitted.
///
/// `Logger` defaults to `Level.trace`, so every `logger.d`/`logger.i` — plus
/// full provider-state dumps from [LogProviderObserver] — was being formatted
/// and printed in production, including image byte lengths and model output.
final logger = Logger(
  level: kReleaseMode ? Level.warning : Level.debug,
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: !kReleaseMode,
    printEmojis: !kReleaseMode,
  ),
);

/// Debug-only. Registered from `main` behind a `kDebugMode` check, because
/// `didUpdateProvider` stringifies whole state objects.
class LogProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderBase<Object?> provider, Object? previousValue,
      Object? newValue, ProviderContainer container) {
    super.didUpdateProvider(provider, previousValue, newValue, container);

    logger.d('Updated $provider: $newValue');
  }

  @override
  void didDisposeProvider(
      ProviderBase<Object?> provider, ProviderContainer container) {
    super.didDisposeProvider(provider, container);
    logger.d('$provider Disposed');
  }
}
