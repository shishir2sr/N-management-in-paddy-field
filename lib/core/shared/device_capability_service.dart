import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:LCC/core/shared/logging_service.dart';

/// Detects devices where the two TFLite models will be slow, so the user gets a
/// heads-up instead of assuming the app has hung.
///
/// The hard gate is in `android/app/build.gradle`: `abiFilters 'arm64-v8a'`
/// keeps the app off 32-bit devices entirely, since they cannot address enough
/// memory for ~40 MB of models plus their tensor arenas. This is the soft,
/// advisory half — it never blocks anything.
class DeviceCapabilityService {
  DeviceCapabilityService({DeviceInfoPlugin? deviceInfo})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  static const String _warningShownKey = 'lowMemoryWarningShown';

  bool? _cachedIsLowSpec;

  Future<bool> isLowSpecDevice() async {
    if (_cachedIsLowSpec != null) return _cachedIsLowSpec!;

    var lowSpec = false;
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        // `isLowRamDevice` is Android's own `ActivityManager.isLowRamDevice()`,
        // which is a better signal than a RAM threshold: the OEM sets it, and
        // it is what the platform itself uses to disable memory-hungry
        // features.
        final is64Bit = info.supportedAbis
            .any((abi) => abi.contains('arm64') || abi.contains('x86_64'));
        lowSpec = info.isLowRamDevice || !is64Bit;
        logger.i('Device: abis=${info.supportedAbis} '
            'isLowRamDevice=${info.isLowRamDevice} lowSpec=$lowSpec');
      }
    } catch (e) {
      logger.w('Could not read device info: $e');
    }

    _cachedIsLowSpec = lowSpec;
    return lowSpec;
  }

  Future<bool> shouldWarnAboutPerformance() async {
    if (!await isLowSpecDevice()) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(_warningShownKey) ?? false);
    } catch (e) {
      logger.w('Could not read the low-memory warning flag: $e');
      return false;
    }
  }

  Future<void> markWarningShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_warningShownKey, true);
    } catch (e) {
      logger.w('Could not persist the low-memory warning flag: $e');
    }
  }
}

final deviceCapabilityServiceProvider = Provider<DeviceCapabilityService>(
  (ref) => DeviceCapabilityService(),
);
