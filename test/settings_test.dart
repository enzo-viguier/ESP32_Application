import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esp32_app/utils/getSettings.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([SharedPreferences])
void main() {
  group('SettingsManager Tests', () {
    late SharedPreferences prefs;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'esp32_address': '192.168.1.1',
        'temperature_unit_celsius': true,
      });
    });

    test('getESPAddress returns correct address', () async {
      final address = await SettingsManager.getESPAddress();
      expect(address, '192.168.1.1');
    });

    test('celsiusSelected returns correct temperature unit', () async {
      final isCelsius = await SettingsManager.celsiusSelected();
      expect(isCelsius, true);
    });

    test('getESPAddress returns null when not set', () async {
      SharedPreferences.setMockInitialValues({});
      final address = await SettingsManager.getESPAddress();
      expect(address, null);
    });
  });
}
