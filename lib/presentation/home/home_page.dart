import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rice_fertile_ai/Utils/app_fonts.dart';
import 'package:rice_fertile_ai/application/image_processror_notifier_provider.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';
import 'package:rice_fertile_ai/core/shared/string_constants.dart';
import 'package:rice_fertile_ai/domain/segmentation_result.dart';
import 'package:rice_fertile_ai/infrastructure/tflite_service.dart';
import 'package:rice_fertile_ai/presentation/home/camera_page.dart';
import 'package:rice_fertile_ai/presentation/home/guideline_screen.dart';
import 'package:rice_fertile_ai/presentation/home/image_preview_page.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/bottom_navbar_widget.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/radial_slider_widget.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/resut_gridview_widget.dart';
import 'package:rice_fertile_ai/presentation/result/input_page.dart';

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
              title: "RiceFertile AI",
              onHelpPressed: () => gotoGuidelineScreen(context)),
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
    ],
  );
}
