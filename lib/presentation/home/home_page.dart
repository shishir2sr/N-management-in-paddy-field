import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/application/image_processror_notifier_provider.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';
import 'package:rice_fertile_ai/presentation/home/camera_page.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/bottom_navbar_widget.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/radial_slider_widget.dart';
import 'package:rice_fertile_ai/presentation/result/result_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(imageProcessorProvider).value?.originalImage;
    final deviceWidth = MediaQuery.of(context).size.width;

    var listContentWidth = (deviceWidth - 60) / 10;
    return SafeArea(
      top: false,
      bottom: false,
      maintainBottomViewPadding: true,
      child: Scaffold(
        appBar: getAppBar(title: "RiceFertile AI"),
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomNavBar(
          selectFromCamera: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CameraPage(),
              ),
            );
          }, //_recognitions.length < 10 ? selectFromCamera : () {},
          restartProgress: () {}, // resetPrediction,
          selectFromGallery: () {},
          //_recognitions.length < 10 ? selectFromImagePicker : () {},
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RadialSliderWidget(
              percentage: 0.10,
              remaining: 5,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResultScreen(
                      lccResult: 3.5,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                  10,
                  (index) => Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: ColorConstants.appGradient,
                        borderRadius:
                            BorderRadius.circular(listContentWidth / 2),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
