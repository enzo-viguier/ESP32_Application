import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:esp32_app/utils/apiCall.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('API Call Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });






  });
}
