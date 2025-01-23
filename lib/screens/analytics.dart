import 'dart:io';

import 'package:esp32_app/utils/sensor__data_manager.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esp32_app/utils/get_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      // Permission accordée
      logger.i("Permission accordée pour accéder au stockage.");
    } else if (await Permission.manageExternalStorage.request().isGranted) {
      // Permission MANAGE_EXTERNAL_STORAGE pour Android 11+
      logger.i("Permission spéciale accordée pour Android 11+.");
    } else {
      // Si refusée, afficher un message ou rediriger vers les paramètres
      logger.i("Permission refusée pour accéder au stockage.");
      if (await Permission.storage.isPermanentlyDenied ||
          await Permission.manageExternalStorage.isPermanentlyDenied) {
        await openAppSettings(); // Redirige l'utilisateur vers les paramètres
      }
    }
  }

  Future<String?> getDownloadsDirectoryPath() async {
    if (Platform.isAndroid) {
      Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
      if (await downloadsDirectory.exists()) {
        return downloadsDirectory.path;
      } else {
        throw Exception("Le dossier Téléchargements n'existe pas.");
      }
    } else if (Platform.isIOS) {
      // iOS ne permet pas un accès direct au dossier Téléchargements
      Directory directory = await getApplicationDocumentsDirectory();
      return directory.path; // Utiliser un dossier interne pour iOS
    }
    return null;
  }

  Future<void> _exportToPDF() async {
    try {
      await requestStoragePermission();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Firebase Data",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: ["Timestamp", "Temp (°C)", "Temp (°F)", "Lumens"],
                data: List.generate(
                  _temperatureSpots.length,
                      (index) {
                    String timestamp = formatTime(_temperatureSpots[index].x);
                    String tempC = _temperatureSpots[index].y.toStringAsFixed(2);
                    String tempF =
                    (_temperatureSpots[index].y * 9 / 5 + 32).toStringAsFixed(2);
                    String lumens = index < _lightSpots.length
                        ? _lightSpots[index].y.toStringAsFixed(2)
                        : "-";
                    return [timestamp, tempC, tempF, lumens];
                  },
                ),
              ),
            ],
          ),
        ),
      );

      String? downloadsPath = await getDownloadsDirectoryPath();
      if (downloadsPath == null) throw Exception("Chemin Téléchargements introuvable.");

      final path = "$downloadsPath/data_export.pdf";
      await File(path).writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exportation en PDF réussie")),
      );
    } catch (e) {
      logger.e("Erreur lors de l'exportation en PDF : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'exportation en PDF")),
      );
    }
  }

  Future<void> _exportToCSV() async {
    try {
      await requestStoragePermission(); // Demander la permission

      String? downloadsPath = await getDownloadsDirectoryPath();
      if (downloadsPath == null) throw Exception("Chemin Téléchargements introuvable.");

      final path = "$downloadsPath/data_export.csv";

      final file = File(path);

      // Collecter les données de température
      String csvContent = "Timestamp,Temp (°C),Temp (°F),Lumens\n";
      for (int i = 0; i < _temperatureSpots.length; i++) {
        String timestamp = formatTime(_temperatureSpots[i].x);
        String tempC = _temperatureSpots[i].y.toStringAsFixed(2);
        String tempF = (_temperatureSpots[i].y * 9 / 5 + 32).toStringAsFixed(2);
        String lumens = i < _lightSpots.length ? _lightSpots[i].y.toStringAsFixed(2) : "-";
        csvContent += "$timestamp,$tempC,$tempF,$lumens\n";
      }

      // Sauvegarde dans un fichier CSV
      await file.writeAsString(csvContent);
      logger.i("Fichier CSV exporté : $path");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exportation en CSV réussie")),
      );

    } catch (e) {
      logger.e("Erreur lors de l'exportation en CSV : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'exportation en CSV")),
      );
    }
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
            const SizedBox(height: 24),
            // Add export buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _exportToPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exporter en PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _exportToCSV,
                  icon: const Icon(Icons.download),
                  label: const Text('Exporter en CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
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
