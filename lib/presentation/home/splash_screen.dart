import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

import 'package:LCC/Utils/app_icons.dart';
import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/presentation/home/home_page.dart';
import 'package:LCC/presentation/home/slider_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Held so it can be cancelled — an uncancelled Future.delayed kept firing
    // after the route was gone.
    _timer = Timer(const Duration(seconds: 2), _goToNextScreen);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _goToNextScreen() async {
    final hasSeenOnboarding = await _hasSeenOnboarding();

    // Checked *after* the await, not before it. The old code checked `mounted`
    // before reading SharedPreferences, then used `context` afterwards — if the
    // app was backgrounded during that window it threw "Looking up a
    // deactivated widget's ancestor is unsafe".
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => hasSeenOnboarding ? const HomePage() : const SliderPage(),
      ),
    );
  }

  Future<bool> _hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('hovered') ?? false;
    } catch (e) {
      logger.w('Could not read the onboarding flag: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppIcons.splashBG),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  AppIcons.splashLogo,
                  color: Colors.white.withValues(alpha: 0.8),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),
            const SizedBox(height: 93),
            ProgressBarAnimation(
              width: 174,
              duration: const Duration(seconds: 2),
              color: const Color(0xFF1C4821).withValues(alpha: 0.8),
              backgroundColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
