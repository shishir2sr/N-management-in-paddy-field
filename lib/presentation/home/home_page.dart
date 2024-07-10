import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/color_constants.dart';
import 'package:rice_fertile_ai/presentation/home/widgets/bottom_navbar_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    var listContentWidth = (deviceWidth - 60) / 10;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ColorConstants.primaryColor,
        title: const Text(
          'Rice Fertile AI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
          selectFromCamera:
              () {}, //_recognitions.length < 10 ? selectFromCamera : () {},
          restartProgress: () {}, // resetPrediction,
          selectFromGallery: () {}
          //_recognitions.length < 10 ? selectFromImagePicker : () {},
          ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to Rice Fertile AI',
            ),
          ],
        ),
      ),
    );
  }
}
