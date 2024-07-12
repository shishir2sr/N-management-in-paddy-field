import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/application/image_processror_notifier_provider.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';
import 'package:rice_fertile_ai/presentation/home/camera_page.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/bottom_navbar_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(imageProcessorProvider);
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
            selectFromGallery: () {}
            //_recognitions.length < 10 ? selectFromImagePicker : () {},
            ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Welcome to Rice Fertile AI',
              ),
              data.maybeMap(
                  orElse: () => Container(),
                  data: (data) {
                    return Text('Image Bytes: ${data.value.imageBytes.length}');
                  }),
            ],
          ),
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
