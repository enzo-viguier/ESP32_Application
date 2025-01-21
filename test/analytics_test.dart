import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esp32_app/screens/Analytics.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  group('Analytics Widget Tests', () {
    testWidgets('Analytics page renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Analytics(),
        ),
      );

      expect(find.text('Température (°C)'), findsOneWidget);
      expect(find.text('Lumière (Lumens)'), findsOneWidget);
      expect(find.byType(LineChart), findsNWidgets(2));
    });

    testWidgets('Export buttons are present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Analytics(),
        ),
      );

      expect(find.text('Exporter en PDF'), findsOneWidget);
      expect(find.text('Exporter en CSV'), findsOneWidget);
    });
  });
}
