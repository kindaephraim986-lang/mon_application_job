import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_test/flutter_test.dart';
import 'package:job_research_frontend/config/app_config.dart';

void main() {
  group('AppConfig base URL resolution', () {
    test('uses the Android emulator backend for Android devices in development', () {
      final url = AppConfig.resolveBaseUrl(
        environment: 'development',
        platform: TargetPlatform.android,
        isWeb: false,
        customBaseUrl: '',
      );

      expect(url, 'http://10.0.2.2:3001/api');
    });

    test('keeps localhost for desktop development', () {
      final url = AppConfig.resolveBaseUrl(
        environment: 'development',
        platform: TargetPlatform.windows,
        isWeb: false,
        customBaseUrl: '',
      );

      expect(url, 'http://localhost:3001/api');
    });

    test('uses localhost for iOS devices in development', () {
      final url = AppConfig.resolveBaseUrl(
        environment: 'development',
        platform: TargetPlatform.iOS,
        isWeb: false,
        customBaseUrl: '',
      );

      expect(url, 'http://localhost:3001/api');
    });
  });
}
