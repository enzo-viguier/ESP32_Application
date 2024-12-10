import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _controller = TextEditingController();
  final String _addressPrefKey = 'esp32_address';
  final String _soundPrefKey = 'villager_sound_enabled';
  bool _isVillagerSoundEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Charger les paramètres enregistrés
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAddress = prefs.getString(_addressPrefKey);
    bool savedSoundSetting = prefs.getBool(_soundPrefKey) ?? false;

    setState(() {
      if (savedAddress != null) {
        _controller.text = savedAddress;
      }
      _isVillagerSoundEnabled = savedSoundSetting;
    });
  }

  // Enregistrer l'adresse et l'état du switch
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  onPressed: _saveAddress,
                  child: const Text("Enregistrer"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                    });
                  },
                  child: const Text("Réinitialiser"),
                ),
              ],
            ),
            const SizedBox(height: 32),
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
      ),
    );
  }
}
