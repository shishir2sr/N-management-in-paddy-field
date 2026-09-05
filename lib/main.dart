import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:LCC/Utils/result_details_model.dart';
import 'package:LCC/core/shared/color_constants.dart';
import 'package:LCC/core/shared/hive_boxes.dart';
import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/core/shared/notification_service.dart';
import 'package:LCC/infrastructure/inference/inference_providers.dart';
import 'package:LCC/presentation/home/splash_screen.dart';

Future<void> main() async {
  // Everything runs inside a guarded zone so an async throw anywhere in the app
  // is logged rather than silently swallowed, which is what happened to every
  // notification failure before.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        logger.e(
          'Flutter error: ${details.exceptionAsString()}',
          error: details.exception,
          stackTrace: details.stack,
        );
        FlutterError.presentError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        logger.e('Unhandled platform error', error: error, stackTrace: stack);
        return true;
      };

      await NotificationService.instance.initialize();

      final storageReady = await _openStorage();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      runApp(ProviderScope(
        observers: [if (kDebugMode) LogProviderObserver()],
        child: storageReady ? const LCCApp() : const _StorageErrorApp(),
      ));
    },
    (error, stack) {
      logger.f('Uncaught zone error', error: error, stackTrace: stack);
    },
  );
}

/// Opens the Hive box, recovering from a corrupted file.
///
/// This used to be three unguarded `await`s before `runApp`: a `HiveError` gave
/// the user a permanently black screen with no way out.
Future<bool> _openStorage() async {
  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(ResultStateDetailsAdapter().typeId)) {
      Hive.registerAdapter(ResultStateDetailsAdapter());
    }
    await Hive.openBox<ResultStateDetails>(HiveBoxes.resultState);
    return true;
  } catch (e, st) {
    logger.e('Could not open storage — attempting recovery',
        error: e, stackTrace: st);
    try {
      await Hive.deleteBoxFromDisk(HiveBoxes.resultState);
      await Hive.openBox<ResultStateDetails>(HiveBoxes.resultState);
      logger.w('Storage was corrupted; history has been reset');
      return true;
    } catch (e2, st2) {
      logger.f('Storage recovery failed', error: e2, stackTrace: st2);
      return false;
    }
  }
}

class LCCApp extends ConsumerStatefulWidget {
  const LCCApp({super.key});

  @override
  ConsumerState<LCCApp> createState() => _LCCAppState();
}

class _LCCAppState extends ConsumerState<LCCApp> {
  late final InferenceLifecycleObserver _inferenceLifecycle;

  @override
  void initState() {
    super.initState();
    // Hands the TFLite tensor arenas back when the app is backgrounded. They
    // are native allocations, so they are invisible to largeHeap and to the
    // Dart GC.
    _inferenceLifecycle = InferenceLifecycleObserver(
      () => ref.read(inferenceClientProvider),
    )..attach();
  }

  @override
  void dispose() {
    _inferenceLifecycle.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A single overlay above the Navigator. Previously each page created its
    // own `LoaderOverlay` *inside* its body and then called
    // `context.loaderOverlay` from above it, so the lookup escaped the route
    // and hit loader_overlay's process-wide singleton fallback — a
    // LateInitializationError for first-run users and a stale, popped route's
    // overlay for everyone else.
    return GlobalLoaderOverlay(
      useDefaultLoading: false,
      overlayColor: Colors.black.withValues(alpha: 0.5),
      overlayWidgetBuilder: (_) => const Center(
        child: SpinKitWaveSpinner(color: ColorConstants.primaryGreen),
      ),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LCC',
        home: SplashScreen(),
      ),
    );
  }
}

/// Last-resort UI when even a fresh Hive box cannot be opened.
class _StorageErrorApp extends StatelessWidget {
  const _StorageErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storage_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'LCC could not access its local storage.\n\n'
                  'Please make sure the device has free space, then restart '
                  'the app. If the problem persists, clearing the app data '
                  'will fix it.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
