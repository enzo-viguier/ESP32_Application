import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

var logger = Logger();

// == Temperature Data ==

Future<void> addTemperatureData(double celsius, double fahrenheit) async {
  String timestamp = DateTime.now().toIso8601String();

  // Ajoute un nouveau document avec un ID généré automatiquement
  await FirebaseFirestore.instance.collection('temperature').add({
    "celsius": celsius,
    "fahrenheit": fahrenheit,
    "timestamp": timestamp,
  });

  logger.i('Temperature data added');
}

// Fonction getTemperatureData qui retourne une plusieurs liste du style [timestamp, celsius, fahrenheit]
Future<List<List<dynamic>>?> getTemperatureData() async {
  List<List<dynamic>> temperatureData = [];

  // Récupère les documents de la collection temperature
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('temperature').get();

  // Parcours les documents
  querySnapshot.docs.forEach((doc) {
    // Ajoute les données à la liste temperatureData
    temperatureData.add([doc['timestamp'], doc['celsius'], doc['fahrenheit']]);
  });

  return temperatureData;
}

// == Light Data ==
Future<void> addLightData(int lumens) async {
  String timestamp = DateTime.now().toIso8601String();

  // Ajoute un nouveau document avec un ID généré automatiquement
  await FirebaseFirestore.instance.collection('light').add({
    "lumens": lumens,
    "timestamp": timestamp,
  });

}
