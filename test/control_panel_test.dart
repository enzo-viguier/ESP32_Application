import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esp32_app/screens/control_panel.dart';

void main() {
  group('ControlPanel Widget Tests', () {
    testWidgets('ControlPanel renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ControlPanel(),
        ),
      );

      expect(find.text('LED'), findsOneWidget);
      expect(find.text('Lecteur de musique'), findsOneWidget);
      expect(find.text('Capteurs'), findsOneWidget);
    });

    testWidgets('LED switch works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ControlPanel(),
        ),
      );

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pump();
    });

    testWidgets('Music dropdown shows correct options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ControlPanel(),
        ),
      );

      final dropdownFinder = find.byType(DropdownButtonFormField<String>);
      expect(dropdownFinder, findsOneWidget);
    });
  });
}
