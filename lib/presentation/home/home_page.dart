import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rice_fertile_ai/application/image_processror_notifier_provider.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';
import 'package:rice_fertile_ai/presentation/home/camera_page.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/bottom_navbar_widget.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/radial_slider_widget.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/resut_gridview_widget.dart';
import 'package:rice_fertile_ai/presentation/result/result_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageProcessorState = ref.watch(imageProcessorProvider).value;
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
          appBar: getAppBar(title: "RiceFertile AI"),
          backgroundColor: Colors.white,
          bottomNavigationBar: BottomNavBar(
            selectFromCamera: imageProcessorState?.remaining == 0
                ? () => showSnackBar(context,
                    'You have reached the maximum number of images. Please proceed to the next step.')
                : () => gotoCameraPage(context),
            restartProgress: () {}, // resetPrediction,
            selectFromGallery: () {},
            //_recognitions.length < 10 ? selectFromImagePicker : () {},
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RadialSliderWidget(
                  percentage: imageProcessorState?.percentage ?? 0,
                  remaining: imageProcessorState?.remaining ?? 0,
                  onPressed: () => gotoResultScreen(context)),
              const ResultGridViewWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void gotoResultScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ResultScreen(
          lccResult: 3.5,
        ),
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
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

AppBar getAppBar({
  required String title,
  Color backgroundColor = ColorConstants.primaryGreen,
  IconThemeData? iconTheme,
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
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    ),
  );
}
