import 'dart:async';
import 'dart:convert';

import 'package:esp32_app/models/PlaySound.dart';
import 'package:esp32_app/screens/Analytics.dart';
import 'package:esp32_app/screens/Settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/apiCall.dart';

// class ControlPanel extends StatelessWidget {
//   const ControlPanel({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Bienvenue au panneau de contrôle!'));
//   }
//
// }

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  bool ledState = false;
  String selectedSong = "mario";
  String luminosity = "Chargement...";
  String temperature = "Chargement...";

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
        luminosity = jsonDecode(response.body)["value"].toString();
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
      setState(() {
        temperature = temperature = jsonDecode(response.body)["temperature_celsius"].toStringAsFixed(2);;
        // temperature = response.body;
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
      // Gestion des erreurs
    }
  }

  void playSelectedSong() async {
    try {
      await playSong(selectedSong);
    } catch (e) {
      // Gestion des erreurs
    }
  }

  void stopPlayingSong() async {
    try {
      await stopSong();
    } catch (e) {
      // Gestion des erreurs
    }
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
                      onPressed: () {},
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
                          Text(
                            luminosity,
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
                          Text(
                            '$temperature°',
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


// Version 1

// class ControlPanel extends StatelessWidget {
//   const ControlPanel({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Section LED
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'LED',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Row(
//                   children: [
//                     Switch(
//                       value: true,
//                       onChanged: (bool value) {},
//                     ),
//                     TextButton(
//                       onPressed: () {},
//                       child: const Text('Choisir la couleur'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             // Section Lecteur de musique
//             const Text(
//               'Lecteur de musique',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Choisir le son',
//               ),
//               items: const [
//                 DropdownMenuItem(
//                   value: 'mario',
//                   child: Text('Mario'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'pacman',
//                   child: Text('Pacman'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'tetris',
//                   child: Text('Tetris'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'got',
//                   child: Text('Games Of Thrones'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'harrypotter',
//                   child: Text('Harry Potter'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'starwars',
//                   child: Text('Star Wars'),
//                 ),
//               ],
//               onChanged: (value) {},
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     // Code pour démarrer le son
//                   },
//                   icon: const Icon(Icons.play_arrow),
//                   color: Colors.green,
//                   iconSize: 36,
//                 ),
//                 const SizedBox(width: 10),
//                 IconButton(
//                   onPressed: () {
//                     // Code pour arrêter le son
//                   },
//                   icon: const Icon(Icons.stop),
//                   color: Colors.red,
//                   iconSize: 36,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             // Section Capteurs
//             const Text(
//               'Capteurs',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 // Luminosité
//                 Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.yellow[100],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         children: const [
//                           Icon(Icons.wb_sunny, size: 40, color: Colors.yellow),
//                           SizedBox(height: 10),
//                           Text(
//                             '18,000 lumen',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 // Température
//                 Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.red[100],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         children: const [
//                           Icon(Icons.thermostat, size: 40, color: Colors.red),
//                           SizedBox(height: 10),
//                           Text(
//                             '28°',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }