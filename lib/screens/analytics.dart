import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esp32_app/utils/get_settings.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  List<FlSpot> _temperatureSpots = [];
  List<FlSpot> _lightSpots = [];
  bool _isCelsius = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchTemperatureData();
    _fetchLightData();
  }

  Future<void> _loadSettings() async {
    // Récupère le paramètre "Celsius ou Fahrenheit" depuis SettingManager
    bool celsius = await SettingsManager.celsiusSelected();
    setState(() {
      _isCelsius = celsius;
    });
  }


  Future<void> _fetchTemperatureData() async {
    List<List<dynamic>>? temperatureData = await getTemperatureData();
    if (temperatureData != null) {
      // Trier les données par timestamp
      temperatureData.sort((a, b) => DateTime.parse(a[0]).compareTo(DateTime.parse(b[0])));

      // Trouver le timestamp minimum pour normaliser l'axe x
      DateTime minTimestamp = DateTime.parse(temperatureData[0][0]);

      setState(() {
        _temperatureSpots = temperatureData.map((data) {
          DateTime timestamp = DateTime.parse(data[0]);
          // Convertir la différence de temps en minutes depuis le premier point
          double x = timestamp.difference(minTimestamp).inSeconds.toDouble();
          double temp = _isCelsius ? data[1].toDouble() : data[2].toDouble();
          return FlSpot(x, temp);
        }).toList();
      });
    }
  }

// Même chose pour les données de luminosité
  Future<void> _fetchLightData() async {
    List<List<dynamic>>? lightData = await getLightData();
    if (lightData != null) {
      // Trier les données par timestamp
      lightData.sort((a, b) => DateTime.parse(a[0]).compareTo(DateTime.parse(b[0])));

      // Trouver le timestamp minimum pour normaliser l'axe x
      DateTime minTimestamp = DateTime.parse(lightData[0][0]);

      setState(() {
        _lightSpots = lightData.map((data) {
          DateTime timestamp = DateTime.parse(data[0]);
          // Convertir la différence de temps en minutes depuis le premier point
          double x = timestamp.difference(minTimestamp).inSeconds.toDouble();
          double lumens = data[1].toDouble();
          return FlSpot(x, lumens);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Température (${_isCelsius ? '°C' : '°F'})",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(_temperatureChart()),
            ),
            const SizedBox(height: 32),
            const Text(
              "Lumière (Lumens)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(_lightChart()),
            ),
          ],
        ),
      ),
    );
  }


  String formatTime(double value) {
    int totalSeconds = value.toInt();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "${minutes > 0 ? '${minutes}m' : ''}${seconds}s";
  }

  LineChartData _temperatureChart() {
    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value <= 0 || value.toInt() % 30 != 0) return const SizedBox();
              return Text(
                formatTime(value),
                style: const TextStyle(fontSize: 10),
              );
            },
            reservedSize: 22,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) =>
                Text("${value.toStringAsFixed(1)}${_isCelsius ? '°C' : '°F'}"),
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          top: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(width: 1),
          left: BorderSide(width: 1),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _temperatureSpots,
          isCurved: true,
          color: Colors.red,
          barWidth: 3,
          belowBarData: BarAreaData(show: false),
          dotData: const FlDotData(show: true),
        ),
      ],
    );
  }

  LineChartData _lightChart() {
    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value <= 0 || value.toInt() % 30 != 0) return const SizedBox();
              return Text(
                formatTime(value),
                style: const TextStyle(fontSize: 10),
              );
            },
            reservedSize: 22,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => Text("${value.toInt()} lm"),
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          top: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(width: 1),
          left: BorderSide(width: 1),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _lightSpots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          belowBarData: BarAreaData(show: false),
          dotData: const FlDotData(show: true),
        ),
      ],
    );
  }
  Future<List<List<dynamic>>?> getTemperatureData() async {
    List<List<dynamic>> temperatureData = [];

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('temperature').get();

    for (var doc in querySnapshot.docs) {
      temperatureData.add([
        doc['timestamp'],
        doc['celsius'],
        doc['fahrenheit'],
      ]);
    }

    return temperatureData;
  }

  Future<List<List<dynamic>>?> getLightData() async {
    List<List<dynamic>> lightData = [];

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('light').get();

    for (var doc in querySnapshot.docs) {
      lightData.add([
        doc['timestamp'],
        doc['lumens'],
      ]);
    }

    return lightData;
  }
}
