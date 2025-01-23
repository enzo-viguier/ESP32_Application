import 'dart:math';

import 'package:flutter/material.dart';
import 'package:esp32_app/models/play_sound.dart';

class NavigationItem {
  final String title;
  final Icon icon;
  final Widget body;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.body,
  });
}

class ScaffoldManager extends StatefulWidget {
  final List<NavigationItem> navigationItems;

  const ScaffoldManager({super.key, required this.navigationItems});

  @override
  _ScaffoldManagerState createState() => _ScaffoldManagerState();
}

class _ScaffoldManagerState extends State<ScaffoldManager> {
  int _selectedIndex = 0;
  final List<String> _sounds = [
    "death",
    "simple1",
    "simple2",
    "hit",
    "skibidi"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    PlaySound().play(_sounds[Random().nextInt(5)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.navigationItems[_selectedIndex].title),
      ),
      body: widget.navigationItems[_selectedIndex].body, // Dynamically selected
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: widget.navigationItems
            .map((item) => BottomNavigationBarItem(
                  icon: item.icon,
                  label: item.title,
                ))
            .toList(),
      ),
    );
  }
}
