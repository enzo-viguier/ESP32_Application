import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:esp32_app/utils/get_settings.dart';
import 'package:logger/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_call.dart';
import '../utils/sensor__data_manager.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  var logger = Logger();
  bool ledState = false;
  String selectedSong = "mario";
  String luminosity = "Loading";
  String temperature = "Loading";
  Color selectedColor = Colors.blue;
  bool isThresholdEnabled = false;
  int? luminosityThreshold;
  bool isAutoControl = false;

  late Timer timer;

  TextStyle get titleStyle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  TextStyle get bodyStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    color: Colors.black,
  );

  TextStyle get valueStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );


  late Timer displayTimer;
  late Timer saveTimer;

  @override
  void initState() {
    super.initState();
    _loadThresholdSettings();

    // Timer pour mettre à jour l'affichage toutes les 2 secondes
    displayTimer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      updateDisplay();
    });

    // Timer pour sauvegarder les données toutes les 2 minutes
    saveTimer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      saveData();
    });
  }

  Future<void> _loadThresholdSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isThresholdEnabled = prefs.getBool('threshold_enabled') ?? false;
      String? threshold = prefs.getString('luminosity_threshold');
      if (threshold != null) {
        luminosityThreshold = int.tryParse(threshold);
      }
    });
  }

  void _checkThresholdAndUpdateLED(int currentLuminosity) async {
    if (!isThresholdEnabled || luminosityThreshold == null) return;

    bool shouldLedBeOn = currentLuminosity < luminosityThreshold!;

    if (shouldLedBeOn != ledState) {
      try {
        await switchLed(shouldLedBeOn);
        setState(() {
          ledState = shouldLedBeOn;
          isAutoControl = true;
        });
      } catch (e) {
        logger.e('Erreur lors de la commutation automatique de la LED : $e');
      }
    }
    else {
      await switchLed(ledState);
    }
  }


  @override
  void dispose() {
    displayTimer.cancel();
    saveTimer.cancel();
    super.dispose();
  }

  void updateDisplay() async {
    // Mettre à jour uniquement l'affichage sans sauvegarder
    try {
      final response = await getPhotoCell();
      final luminosityValue = jsonDecode(response.body)["value"];
      setState(() {
        luminosity = "$luminosityValue lumens";
      });

      _checkThresholdAndUpdateLED(luminosityValue);
    } catch (e) {
      setState(() {
        luminosity = "Erreur";
      });
    }

    try {
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

  void saveData() async {
    // Sauvegarder les données dans Firebase
    try {
      final responseLight = await getPhotoCell();
      final luminosityValue = jsonDecode(responseLight.body)["value"];
      addLightData(int.parse(luminosityValue));

      final responseTemp = await getTemps();
      final tempData = jsonDecode(responseTemp.body);
      addTemperatureData(
          double.parse(tempData["temperature_celsius"].toStringAsFixed(2)),
          double.parse(tempData["temperature_fahrenheit"].toStringAsFixed(2))
      );
    } catch (e) {
      logger.e('Erreur lors de la sauvegarde des données');
    }
  }

  void updateSensors() async {
    // Mettre à jour la luminosité
    try {
      final response = await getPhotoCell();
      final luminosityValue = jsonDecode(response.body)["value"];
      setState(() {
        luminosity = "$luminosityValue lumens";
        addLightData(int.parse(luminosityValue));
      });

      _checkThresholdAndUpdateLED(luminosityValue);

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
        addTemperatureData(double.parse(jsonDecode(response.body)["temperature_celsius"].toStringAsFixed(2)), double.parse(jsonDecode(response.body)["temperature_fahrenheit"].toStringAsFixed(2)));
      });
    } catch (e) {
      setState(() {
        temperature = "Erreur";
      });
    }
  }

  void toggleLed(bool state) async {
    if (isThresholdEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Désactivez le contrôle automatique dans les paramètres pour contrôler manuellement la LED'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      await switchLed(state);
      setState(() {
        ledState = state;
        isAutoControl = false;
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
    if (isThresholdEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Désactivez le contrôle automatique dans les paramètres pour changer la couleur'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final r = color.r.toString();
    final g = color.g.toString();
    final b = color.b.toString();

    try {
      await setLedColor(r, g, b);
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
              ColorPickerType.primary: true,
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
            Text('LED', style: titleStyle),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Transform.scale(
                  scaleX: 1.0,
                  scaleY: 1.0,
                  child: Switch(
                    value: ledState,
                    onChanged: toggleLed,
                    activeColor: Colors.green,
                    inactiveTrackColor: Colors.red.withOpacity(0.5),
                    inactiveThumbColor: Colors.red,
                  ),
                ),
                TextButton(
                  onPressed: openColorPicker,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Choisir la couleur',
                    style: bodyStyle.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section Lecteur de musique
            Text('Lecteur de musique', style: titleStyle),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSong,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Choisir le son',
                labelStyle: bodyStyle,
              ),
              style: bodyStyle,
              items: [
                DropdownMenuItem(
                  value: 'mario',
                  child: Text('Mario', style: bodyStyle),
                ),
                DropdownMenuItem(
                  value: 'pacman',
                  child: Text('Pacman', style: bodyStyle),
                ),
                DropdownMenuItem(
                  value: 'tetris',
                  child: Text('Tetris', style: bodyStyle),
                ),
                DropdownMenuItem(
                  value: 'got',
                  child: Text('Games Of Thrones', style: bodyStyle),
                ),
                DropdownMenuItem(
                  value: 'harrypotter',
                  child: Text('Harry Potter', style: bodyStyle),
                ),
                DropdownMenuItem(
                  value: 'starwars',
                  child: Text('Star Wars', style: bodyStyle),
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
            Text('Capteurs', style: titleStyle),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Luminosité
                Container(
                  width: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Icon in top left
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.wb_sunny, size: 24, color: Colors.white),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              luminosity,
                              style: valueStyle.copyWith(fontSize: 20),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Luminosité",
                              style: bodyStyle.copyWith(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Température
                Container(
                  width: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Icon in top right
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.thermostat, size: 24, color: Colors.white),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              temperature,
                              style: valueStyle.copyWith(fontSize: 20),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Température",
                              style: bodyStyle.copyWith(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
