import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const String _addressPrefKey = 'esp32_address';
  static const String _tempUnitPrefKey = 'temperature_unit_celsius';

  // Récupérer l'adresse ESP enregistrée
  static Future<String?> getESPAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var logger = Logger();
    logger.d(prefs.getString(_addressPrefKey));
    return prefs.getString(_addressPrefKey);
  }

  // Vérifier si l'unité Celsius est sélectionnée
  static Future<bool> celsiusSelected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tempUnitPrefKey) ?? true; // Par défaut : true (Celsius)
  }

}
