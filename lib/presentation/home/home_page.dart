import 'package:LCC/core/shared/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:LCC/Utils/app_fonts.dart';
import 'package:LCC/application/image_processror_notifier_provider.dart';
import 'package:LCC/core/shared/string_constants.dart';
import 'package:LCC/domain/segmentation_result.dart';
import 'package:LCC/infrastructure/tflite_service.dart';
import 'package:LCC/presentation/home/camera_page.dart';
import 'package:LCC/presentation/home/guideline_screen.dart';
import 'package:LCC/presentation/home/history_screen.dart';
import 'package:LCC/presentation/home/image_preview_page.dart';
import 'package:LCC/presentation/home/widgets/bottom_navbar_widget.dart';
import 'package:LCC/presentation/home/widgets/radial_slider_widget.dart';
import 'package:LCC/presentation/home/widgets/resut_gridview_widget.dart';
import 'package:LCC/presentation/result/input_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interpreter = ref
        .watch(interpreterProvider(StrConsts.segmentationModelPath))
        .valueOrNull;

    final imageProcessorState = ref.watch(imageProcessorProvider).value;
    final imageProcessorStateNotifier =
        ref.read(imageProcessorProvider.notifier);
    ref.listen(imageProcessorProvider, (state, next) {
      state?.maybeWhen(
        orElse: () => context.loaderOverlay.hide(),
        loading: () => context.loaderOverlay.show(),
        error: (error, stackTrace) =>
            ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        ),
      );
    });

    return LoaderOverlay(
      useDefaultLoading: false,
      overlayColor: Colors.black.withOpacity(0.5),
      overlayWidgetBuilder: (progress) =>
          const SpinKitWaveSpinner(color: ColorConstants.primaryGreen),
      child: SafeArea(
        top: false,
        bottom: false,
        maintainBottomViewPadding: true,
        child: Scaffold(
          appBar: getAppBar(
              title: "LCC",
              onHelpPressed: () => gotoGuidelineScreen(context),
              onHistoryPressed: () => gotoHistoryScreen(context)),
          backgroundColor: Colors.white,
          bottomNavigationBar: BottomNavBar(
            selectFromCamera: imageProcessorState?.remaining == 0
                ? () => showSnackBar(context,
                    'You have reached the maximum number of images. Please proceed to the next step.')
                : () => gotoCameraPage(context),
            restartProgress: () {
              imageProcessorStateNotifier.resetPrediction();
            }, // resetPrediction,
            selectFromGallery: () async {
              if (imageProcessorState?.remaining == 0) {
                showSnackBar(context,
                    'You have reached the maximum number of images. Please proceed to the next step.');
              } else {
                SegmentationResult? segmentationResult =
                    await imageProcessorStateNotifier.pickImageFromGallery(
                  interpreter: interpreter,
                );

                if (context.mounted && segmentationResult != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewPage(
                        segmentationResult: segmentationResult,
                      ),
                    ),
                  );
                }
              }
            },
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: RadialSliderWidget(
                  percentage: imageProcessorState?.percentage ?? 0,
                  remaining: imageProcessorState?.remaining ?? 0,
                  // onPressed: () => gotoResultScreen(context),
                  onPressed: () => gotoInputPage(context),
                ),
              ),
              const Expanded(child: ResultGridViewWidget()),
            ],
          ),
        ),
      ),
    );
  }

  void gotoGuidelineScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GuidelineScreen(),
      ),
    );
  }

  void gotoHistoryScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryPage(),
      ),
    );
  }

  void gotoInputPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LandInputPage(),
      ),
    );
  }

  void gotoCameraPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraPage(),
      ),
    );
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: AppFonts.MANROPE),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
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
