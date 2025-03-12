import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'app_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Mock Tests:', () {

    testWidgets("Run through an entire mock test",
          (WidgetTester tester) async {
        await tester.pump(const Duration(seconds: 1));
        tester.printToConsole('Testing exam date feature');
        await loginTest(tester);
        await tester.pumpAndSettle();

        expect(find.text('Mini-Mocks'), findsOneWidget);
        await tester.tap(find.text('Mini-Mocks'));
        await tester.pumpAndSettle();

        expect(find.text('Mini-Mock 1'), findsOneWidget);
        await tester.tap(find.text('Mini-Mock 1'));
        await tester.pumpAndSettle();

        expect(find.text('Begin Exam'), findsOneWidget);
        await tester.tap(find.text('Begin Exam'));
        await tester.pumpAndSettle();
      });
  });
}