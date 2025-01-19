import 'dart:async';
// import 'package:esp32_app/navbar.dart';
import 'package:esp32_app/screens/Analytics.dart';
import 'package:esp32_app/screens/ControlPanel.dart';
import 'package:esp32_app/screens/InterfaceApiCall.dart';
import 'package:esp32_app/screens/Settings.dart';
import 'package:esp32_app/screens/TestColorPicker.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'components/ScaffoldManager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  StreamSubscription<InternetStatus>? _listener;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();

    // Setup internet connection listener
    _listener =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      if (mounted) {
        setState(() {
          _isConnected = status == InternetStatus.connected;
        });
      }
    });
  }

  @override
  void dispose() {
    // Cancel the listener when the widget is disposed
    _listener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ConnectionAwareControlPanel(isConnected: _isConnected),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ConnectionAwareControlPanel extends StatefulWidget {
  final bool isConnected;

  const ConnectionAwareControlPanel({super.key, required this.isConnected});

  @override
  _ConnectionAwareControlPanelState createState() =>
      _ConnectionAwareControlPanelState();
}

class _ConnectionAwareControlPanelState
    extends State<ConnectionAwareControlPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(ConnectionAwareControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Show or hide SnackBar when connection status changes
    if (!widget.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Pas de connexion internet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(
                days: 1), // Keeps showing until connection is restored
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldManager(
      navigationItems: [
        NavigationItem(
            body: const Analytics(),
            icon: const Icon(Icons.analytics),
            title: "Analytics"),
        NavigationItem(
            body: const ControlPanel(),
            icon: const Icon(Icons.home),
            title: "Home"),
        NavigationItem(
            body: const Settings(),
            icon: const Icon(Icons.settings),
            title: "Settings"),
      ],
    );
  }
}
