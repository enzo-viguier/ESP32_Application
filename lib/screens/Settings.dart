import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/PlaySound.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _thresholdController = TextEditingController();
  final String _addressPrefKey = 'esp32_address';
  final String _soundPrefKey = 'villager_sound_enabled';
  final String _tempUnitPrefKey = 'temperature_unit_celsius';
  final String _thresholdPrefKey = 'luminosity_threshold';
  bool _isVillagerSoundEnabled = false;
  bool _isCelsiusSelected = true;
  bool _isThresholdEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAddress = prefs.getString(_addressPrefKey);
    bool savedSoundSetting = prefs.getBool(_soundPrefKey) ?? false;
    bool savedTempUnit = prefs.getBool(_tempUnitPrefKey) ?? true;
    String? savedThreshold = prefs.getString(_thresholdPrefKey);
    bool savedThresholdEnabled = prefs.getBool('threshold_enabled') ?? false;

    setState(() {
      if (savedAddress != null) {
        _controller.text = savedAddress;
      }
      if (savedThreshold != null) {
        _thresholdController.text = savedThreshold;
      }
      _isVillagerSoundEnabled = savedSoundSetting;
      _isCelsiusSelected = savedTempUnit;
      _isThresholdEnabled = savedThresholdEnabled;
    });
  }

  Future<void> _saveAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressPrefKey, _controller.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adresse enregistrée avec succès !')),
    );
  }

  Future<void> _saveSoundSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundPrefKey, value);
    setState(() {
      _isVillagerSoundEnabled = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Son Villager activé !' : 'Son Villager désactivé !',
        ),
      ),
    );
  }

  Future<void> _saveTemperatureUnit(bool isCelsius) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tempUnitPrefKey, isCelsius);
    setState(() {
      _isCelsiusSelected = isCelsius;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCelsius
              ? 'Température en Celsius activée !'
              : 'Température en Fahrenheit activée !',
        ),
      ),
    );
  }

  Future<void> _saveThresholdSettings() async {
    if (_thresholdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une valeur de seuil')),
      );
      return;
    }

    try {
      int threshold = int.parse(_thresholdController.text);
      if (threshold < 0 || threshold > 4000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le seuil doit être entre 0 et 4000 lumens')),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_thresholdPrefKey, threshold.toString());
      await prefs.setBool('threshold_enabled', _isThresholdEnabled);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seuil de luminosité enregistré !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nombre valide')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            "Adresse ESP32",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "192.56.32.1 ou http://myesp32",
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _saveAddress();
                  PlaySound().play('simple1');
                },
                child: const Text("Enregistrer"),
              ),
              ElevatedButton(
                onPressed: () {
                  PlaySound().play('death');
                  setState(() {
                    _controller.clear();
                  });
                },
                child: const Text("Réinitialiser"),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Nouvelle section pour le seuil de luminosité
          const Text(
            "Seuil de luminosité",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _thresholdController,
                  keyboardType: TextInputType.number,
                  enabled: _isThresholdEnabled,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Seuil en lumens (0-4000)",
                    suffixText: "lumens",
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: _isThresholdEnabled,
                onChanged: (value) {
                  setState(() {
                    _isThresholdEnabled = value;
                  });
                  _saveThresholdSettings();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isThresholdEnabled ? _saveThresholdSettings : null,
            child: const Text("Enregistrer le seuil"),
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Température en Celsius",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _isCelsiusSelected,
                onChanged: (value) => _saveTemperatureUnit(value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Activer le son Villager",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _isVillagerSoundEnabled,
                onChanged: (value) => _saveSoundSetting(value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}