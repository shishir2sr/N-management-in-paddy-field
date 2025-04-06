import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:LCC/Utils/result_details_model.dart';
import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/presentation/home/splash_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void requestNotificationPermission() async {
  final bool? result = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  if (result != null && result) {
    print("Notifications permission granted");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  requestNotificationPermission();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS initialization
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  // Full initialization settings
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // Initialize the plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await Hive.initFlutter();
  Hive.registerAdapter(ResultStateDetailsAdapter()); // Register the adapter
  await Hive.openBox<ResultStateDetails>('resultStateBox'); // Open a Hive box
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(ProviderScope(
      observers: [LogProviderObserver()],
      child: const LCCApp(),
    ));
  });
}

class LCCApp extends StatelessWidget {
  const LCCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LCC',
      home: SplashScreen(),
    );
  }
}
