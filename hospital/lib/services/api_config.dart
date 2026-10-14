import 'package:flutter/foundation.dart';

/// Where the HealthNova backend is.
///
/// Pass the address when starting the app to override the default:
///
///   flutter run --dart-define=API_URL=http://192.168.1.20:5000
///
/// Without it the app picks the usual development address for the platform:
///   * Android emulator: http://10.0.2.2:5000 (the emulator's alias for the
///     computer it runs on - "localhost" would be the emulator itself)
///   * Chrome, Windows, macOS, Linux, iOS simulator: http://localhost:5000
///
/// A physical phone cannot use either; it needs the computer's LAN IP address
/// (run `ipconfig` on Windows) with API_URL, and both must be on the same
/// Wi-Fi network.
class ApiConfig {
  ApiConfig._();

  static const String _override = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) {
      return _override.endsWith('/')
          ? _override.substring(0, _override.length - 1)
          : _override;
    }
    if (kIsWeb) return 'http://localhost:5000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }
}
