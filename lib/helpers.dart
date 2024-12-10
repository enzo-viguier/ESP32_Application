import 'dart:collection';
import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

Future<Response> getPhotoCell() {
  return apiCall("/light");
}

Future<Response> getTemps({String unit = "c"}) {
  return apiCall("/light/$unit", params: {"unit": unit});
}

Future<Response> switchLed(bool state) {
  if (state) return apiCall("/light/on");
  return apiCall("/light/off");
}

Future<Response> apiCall(String endpoint,
    {String method = "GET",
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, String>? params}) async {
  // Définir les en-têtes par défaut
  headers?.putIfAbsent("Content-Type", () => "application/json");

  // Définir l'URL de base
  String url = "apimobile-u6kf.onrender.com";
  var uri = Uri.https(url, endpoint, params);
  // Choisir la méthode HTTP appropriée
  switch (method.toUpperCase()) {
    case "GET":
      return await http.get(uri, headers: headers);
    case "POST":
      return await http.post(uri, headers: headers, body: body);
    case "PUT":
      return await http.put(uri, headers: headers, body: body);
    case "DELETE":
      return await http.delete(uri, headers: headers);

    default:
      throw Exception('Method $method is not supported');
  }
}
