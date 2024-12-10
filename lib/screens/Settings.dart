import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _controller = TextEditingController();
  final String _prefKey = 'esp32_address';

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  // Charger l'adresse enregistrée si elle existe
  Future<void> _loadSavedAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAddress = prefs.getString(_prefKey);
    if (savedAddress != null) {
      setState(() {
        _controller.text = savedAddress;
      });
    }
  }

  // Enregistrer l'adresse dans les préférences partagées
  Future<void> _saveAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _controller.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adresse enregistrée avec succès !')),
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
          ],
        ),
      ),
    );
  }
}
