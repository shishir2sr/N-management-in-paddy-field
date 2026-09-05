import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:LCC/core/shared/logging_service.dart';

/// Local notifications, actually working.
///
/// Four independent bugs used to stack up here, so the feature had never fired
/// once:
///   1. `tz.initializeTimeZones()` was never called, so reading `tz.local`
///      threw `LateInitializationError: Field '_local' has not been
///      initialized` — see [initialize].
///   2. `POST_NOTIFICATIONS` was never requested on Android 13+; only the iOS
///      branch of `requestPermissions` was called.
///   3. `AndroidScheduleMode.exact` needs `SCHEDULE_EXACT_ALARM`, which the
///      manifest did not declare, so `AlarmManager` threw `SecurityException`
///      on API 31+.
///   4. The caller was `void ... async` and unawaited, so every one of the
///      above vanished as an unhandled async error.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'lcc_recommendations';
  static const String _channelName = 'Recommendations';
  static const String _channelDescription =
      'Reminders to review your nitrogen recommendation.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _permissionGranted = false;

  bool get isReady => _initialized && _permissionGranted;

  /// Safe to call before `runApp`. Never throws — notifications are a
  /// nice-to-have and must not be able to prevent the app from starting.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Must happen before anything reads `tz.local`.
      tz_data.initializeTimeZones();

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Deferred to an explicit request so the prompt is not the first
          // thing a new user sees.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _plugin.initialize(settings);
      _initialized = true;
    } catch (e, st) {
      logger.e('Notification setup failed', error: e, stackTrace: st);
    }
  }

  /// Requests permission on whichever platform is running. Call this when the
  /// user has done something that warrants a reminder, not at cold start.
  Future<bool> requestPermission() async {
    if (!_initialized) await initialize();
    if (!_initialized) return false;
    if (_permissionGranted) return true;

    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        _permissionGranted =
            await android?.requestNotificationsPermission() ?? false;
      } else if (Platform.isIOS) {
        final ios = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        _permissionGranted = await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (e, st) {
      logger.e('Notification permission request failed',
          error: e, stackTrace: st);
      _permissionGranted = false;
    }

    logger.i('Notification permission granted: $_permissionGranted');
    return _permissionGranted;
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
  }) async {
    if (!await requestPermission()) {
      logger.w('Skipping reminder — notifications are not permitted');
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // `exact` requires the SCHEDULE_EXACT_ALARM special permission on API
      // 31+; a one-minute reminder does not warrant asking the user for it.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    logger.i('Reminder scheduled for $when');
  }
}
