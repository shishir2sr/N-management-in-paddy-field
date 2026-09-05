import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:LCC/Utils/app_fonts.dart';
import 'package:LCC/application/image_processror_notifier_provider.dart';
import 'package:LCC/core/shared/color_constants.dart';
import 'package:LCC/core/shared/device_capability_service.dart';
import 'package:LCC/domain/analysis_failure.dart';
import 'package:LCC/infrastructure/inference/inference_providers.dart';
import 'package:LCC/presentation/home/camera_page.dart';
import 'package:LCC/presentation/home/guideline_screen.dart';
import 'package:LCC/presentation/home/history_screen.dart';
import 'package:LCC/presentation/home/image_preview_page.dart';
import 'package:LCC/presentation/home/widgets/bottom_navbar_widget.dart';
import 'package:LCC/presentation/home/widgets/radial_slider_widget.dart';
import 'package:LCC/presentation/home/widgets/resut_gridview_widget.dart';
import 'package:LCC/presentation/result/input_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _pickingFromGallery = false;

  @override
  void initState() {
    super.initState();
    // Start loading the models while the user reads the home screen rather
    // than making them wait on the camera page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(inferenceWarmupProvider);
      _maybeWarnAboutDevice();
    });
  }

  Future<void> _maybeWarnAboutDevice() async {
    final service = ref.read(deviceCapabilityServiceProvider);
    if (!await service.shouldWarnAboutPerformance()) return;
    if (!mounted) return;
    await service.markWarningShown();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 6),
        content: Text(
          'This device has limited memory, so analysing a photo may take '
          'longer than usual.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageProcessorState = ref.watch(imageProcessorProvider).value;
    final notifier = ref.read(imageProcessorProvider.notifier);
    final isComplete = imageProcessorState?.isComplete ?? false;

    // Driven from `ref.listen` rather than from inside `build`, which used to
    // call `markNeedsBuild()` during the build phase.
    ref.listen(imageProcessorProvider, (_, next) {
      final overlay = context.loaderOverlay;
      if (next.isLoading) {
        overlay.show();
      } else {
        overlay.hide();
      }
      next.whenOrNull(error: (error, _) => _showFailure(error));
    });

    return SafeArea(
      top: false,
      bottom: false,
      maintainBottomViewPadding: true,
      child: Scaffold(
        appBar: getAppBar(
          title: "LCC",
          onHelpPressed: () => gotoGuidelineScreen(context),
          onHistoryPressed: () => gotoHistoryScreen(context),
        ),
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomNavBar(
          selectFromCamera: isComplete
              ? () => _showMaxReached()
              : () => gotoCameraPage(context),
          restartProgress: notifier.resetPrediction,
          selectFromGallery:
              _pickingFromGallery ? null : () => _pickFromGallery(isComplete),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: RadialSliderWidget(
                percentage: imageProcessorState?.percentage ?? 0,
                remaining: imageProcessorState?.remaining ?? kRequiredReadings,
                onPressed: () => gotoInputPage(context),
              ),
            ),
            const Expanded(child: ResultGridViewWidget()),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery(bool isComplete) async {
    if (isComplete) {
      _showMaxReached();
      return;
    }
    if (_pickingFromGallery) return;
    setState(() => _pickingFromGallery = true);

    try {
      final result = await ref
          .read(imageProcessorProvider.notifier)
          .pickImageFromGallery();

      if (!mounted || result == null) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewPage(segmentationResult: result),
        ),
      );
    } finally {
      if (mounted) setState(() => _pickingFromGallery = false);
    }
  }

  void _showFailure(Object error) {
    if (!mounted) return;
    if (error is AnalysisFailure) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red,
          action: error.needsSettings
              ? const SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: openAppSettings,
                )
              : null,
        ),
      );
      return;
    }
    showSnackBar(context, 'Something went wrong. Please try again.');
  }

  void _showMaxReached() => showSnackBar(
        context,
        'You have reached the maximum number of images. Please proceed to '
        'the next step.',
      );

  void gotoGuidelineScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GuidelineScreen()),
    );
  }

  void gotoHistoryScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
  }

  void gotoInputPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LandInputPage()),
    );
  }

  void gotoCameraPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraPage()),
    );
  }
}

void showSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontFamily: AppFonts.MANROPE),
      ),
      backgroundColor: Colors.red,
    ),
  );
}

AppBar getAppBar({
  required String title,
  Color backgroundColor = ColorConstants.primaryGreen,
  IconThemeData? iconTheme = const IconThemeData(color: Colors.white),
  VoidCallback? onHelpPressed,
  VoidCallback? onHistoryPressed,
}) {
  return AppBar(
    centerTitle: true,
    backgroundColor: backgroundColor,
    iconTheme: iconTheme,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: AppFonts.MANROPE,
      ),
    ),
    actions: [
      if (onHelpPressed != null)
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: onHelpPressed,
        ),
      if (onHistoryPressed != null)
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: onHistoryPressed,
        ),
    ],
  );
}
