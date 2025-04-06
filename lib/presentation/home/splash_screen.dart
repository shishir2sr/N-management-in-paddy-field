// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:LCC/Utils/app_icons.dart';
import 'package:LCC/presentation/home/home_page.dart';
import 'package:LCC/presentation/home/slider_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simple_progress_indicators/simple_progress_indicators.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Simulate a delay before navigating to the next screen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        checkIfAlreadyHovered().then((isAlreadyHovered) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoaderOverlay(
                  child:
                      isAlreadyHovered ? const HomePage() : const SliderPage()),
            ),
          );
        });
      }
    });
  }

  Future checkIfAlreadyHovered() async {
    var pref = await SharedPreferences.getInstance();
    var hovered = pref.getBool('hovered') ?? false;
    return hovered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Background Image
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppIcons.splashBG),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        AppIcons.splashLogo,
                        color: Colors.white.withOpacity(0.8),
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),
                  const SizedBox(height: 93),

                  ProgressBarAnimation(
                    width: 174,
                    duration: const Duration(seconds: 2),
                    color: const Color(0xFF1C4821).withOpacity(0.8),
                    backgroundColor: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
