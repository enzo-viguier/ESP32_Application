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

Future<List<List<dynamic>>?> getTemperatureData() async {
  try {
    logger.i('Fetching temperature data from Firestore...');
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('temperature').get();

    List<List<dynamic>> temperatureData = [];
    for (var doc in querySnapshot.docs) {
      logger.i('Document fetched: ${doc.data()}');
      temperatureData.add([
        doc['timestamp'],
        doc['celsius'],
        doc['fahrenheit'],
      ]);
    }

    logger.i('Temperature data successfully fetched: $temperatureData');
    return temperatureData;
  } catch (e) {
    logger.e('Error fetching temperature data: $e');
    return null;
  }
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

Future<List<List<dynamic>>?> getLightData() async {
  try {
    logger.i('Fetching light data from Firestore...');
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('light').get();

    List<List<dynamic>> lightData = [];
    for (var doc in querySnapshot.docs) {
      logger.i('Document fetched: ${doc.data()}');
      lightData.add([
        doc['timestamp'],
        doc['lumens'],
      ]);
    }

    logger.i('Light data successfully fetched: $lightData');
    return lightData;
  } catch (e) {
    logger.e('Error fetching light data: $e');
    return null;
  }
}
