import 'package:flutter_test/flutter_test.dart';
import 'package:job_research_frontend/utils/cnib_reconnect_helper.dart';

void main() {
  group('CNIB reconnect restore', () {
    test('prefers the latest user value, then initial data, then persisted value', () {
      final restored = resolveCnibUrl(
        userValue: 'https://cdn.example.com/user-recto.jpg',
        initialValue: 'https://cdn.example.com/initial-recto.jpg',
        persistedValue: 'https://cdn.example.com/persisted-recto.jpg',
      );

      expect(restored, 'https://cdn.example.com/user-recto.jpg');
    });

    test('falls back to persisted CNIB url when user data is empty', () {
      final restored = resolveCnibUrl(
        userValue: '',
        initialValue: '',
        persistedValue: 'https://cdn.example.com/persisted-recto.jpg',
      );

      expect(restored, 'https://cdn.example.com/persisted-recto.jpg');
    });

    test('keeps the current CNIB url when refreshed values are empty', () {
      final restored = resolveCnibUrl(
        userValue: '',
        initialValue: '',
        persistedValue: '',
        currentValue: 'https://cdn.example.com/current-recto.jpg',
      );

      expect(restored, 'https://cdn.example.com/current-recto.jpg');
    });
  });
}
