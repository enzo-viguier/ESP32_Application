import 'dart:async';
import 'dart:convert';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:esp32_app/utils/getSettings.dart';
import 'package:logger/logger.dart';

import '../utils/apiCall.dart';


class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  var logger = Logger();
  bool ledState = false;
  String selectedSong = "mario";
  String luminosity = "Chargement...";
  String temperature = "Chargement...";
  Color selectedColor = Colors.blue;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    // Initialiser les mises à jour des capteurs
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      updateSensors();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void updateSensors() async {
    // Mettre à jour la luminosité
    try {
      final response = await getPhotoCell();
      setState(() {
        luminosity = jsonDecode(response.body)["value"].toString() + "  lumens";
      });
    } catch (e) {
      setState(() {
        luminosity = "Erreur";
      });
    }

    // Mettre à jour la température
    try {
      // final response = await getTemps(unit: "c");
      final response = await getTemps();
      setState(() async {
        if(await SettingsManager.celsiusSelected()){
          temperature = jsonDecode(response.body)["temperature_celsius"].toStringAsFixed(2) + " °C";
        } else {
          temperature = jsonDecode(response.body)["temperature_fahrenheit"].toStringAsFixed(2) + " °F";
        }
      });
    } catch (e) {
      setState(() {
        temperature = "Erreur";
      });
    }
  }

  void toggleLed(bool state) async {
    try {
      if (state) {
        await switchLed(true);
      } else {
        await switchLed(false);
      }
      setState(() {
        ledState = state;
      });
    } catch (e) {
      logger.e('Erreur lors de la commutation de la LED : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la commutation de la LED'),
        ),
      );
    }
  }

  void playSelectedSong() async {
    try {
      await playSong(selectedSong);
    } catch (e) {
      logger.e('Erreur lors de la lecture de la chanson : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la lecture de la chanson'),
        ),
      );
    }
  }

  void stopPlayingSong() async {
    try {
      await stopSong();
    } catch (e) {
      logger.e('Erreur lors de l\'arrêt de la chanson : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'arrêt de la chanson'),
        ),
      );
    }
  }

  Future<void> sendColorToLed(Color color) async {
    final r = color.red.toString();
    final g = color.green.toString();
    final b = color.blue.toString();

    try {
      await setLedColor(r, g, b); // Appel à la fonction pour mettre à jour la couleur LED
    } catch (e) {
      logger.e('Erreur lors de la mise à jour de la couleur LED : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour de la couleur LED'),
        ),
      );
    }
  }

  void openColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir une couleur'),
          content: ColorPicker(
            color: selectedColor,
            onColorChanged: (Color color) async {
              setState(() {
                selectedColor = color;
              });
              await sendColorToLed(color);
            },
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.wheel: true,
              ColorPickerType.primary: false,
              ColorPickerType.accent: false,
            },
            enableShadesSelection: false,
            wheelDiameter: 250,
            heading: Text(
              'Sélectionnez une couleur',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            showColorName: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le pop-up
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section LED
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LED',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Switch(
                      value: ledState,
                      onChanged: toggleLed,
                    ),
                    TextButton(
                      onPressed: openColorPicker,
                      child: const Text('Choisir la couleur'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section Lecteur de musique
            const Text(
              'Lecteur de musique',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSong,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Choisir le son',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'mario',
                  child: Text('Mario'),
                ),
                DropdownMenuItem(
                  value: 'pacman',
                  child: Text('Pacman'),
                ),
                DropdownMenuItem(
                  value: 'tetris',
                  child: Text('Tetris'),
                ),
                DropdownMenuItem(
                  value: 'got',
                  child: Text('Games Of Thrones'),
                ),
                DropdownMenuItem(
                  value: 'harrypotter',
                  child: Text('Harry Potter'),
                ),
                DropdownMenuItem(
                  value: 'starwars',
                  child: Text('Star Wars'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedSong = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: playSelectedSong,
                  icon: const Icon(Icons.play_arrow),
                  color: Colors.green,
                  iconSize: 36,
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: stopPlayingSong,
                  icon: const Icon(Icons.stop),
                  color: Colors.red,
                  iconSize: 36,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section Capteurs
            const Text(
              'Capteurs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Luminosité
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.wb_sunny, size: 40, color: Colors.yellow),
                          const SizedBox(height: 10),
                          Text("Luminosité : \n $luminosity",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Température
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.thermostat, size: 40, color: Colors.red),
                          const SizedBox(height: 10),
                          Text("Température : \n $temperature",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
