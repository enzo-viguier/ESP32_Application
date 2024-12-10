import 'package:esp32_app/models/PlaySound.dart';
import 'package:esp32_app/screens/Analytics.dart';
import 'package:esp32_app/screens/ControlPanel.dart';
import 'package:esp32_app/screens/Settings.dart';
import 'package:flutter/material.dart';

class ScaffoldManager extends StatefulWidget {
  const ScaffoldManager({super.key});

  @override
  _ScaffoldManagerState createState() => _ScaffoldManagerState();
}

class _ScaffoldManagerState extends State<ScaffoldManager> {
  // Indice de l'élément sélectionné dans la barre de navigation
  int _selectedIndex = 1;

  // Liste des titres de l'app bar pour chaque item de la barre de navigation
  final List<String> _appBarTitles = ['Analytics', 'ControlPanel', 'Settings'];
  final List<String> _soundsPlay = ['death', 'hit', 'simple1'];

  // Liste des widgets à afficher dans le corps du scaffold
  final List<Widget> _bodyContent = [
    const Analytics(),
    const ControlPanel(),
    const Settings()
  ];

  // Fonction pour changer l'index de la barre de navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    PlaySound().play(_soundsPlay[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
      ),
      body: _bodyContent[_selectedIndex], // Change selon l'index sélectionné
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
