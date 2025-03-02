import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'app_test.dart';

void main() {

  group('Login/Exam Button Test:', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      testWidgets("Log into the app",
          (WidgetTester tester) async {
        await tester.pump(const Duration(seconds: 1));
        tester.printToConsole('Testing login');
        await loginTest(tester);
        await tester.pumpAndSettle();
      });

    testWidgets("Set Exam Date",
          (WidgetTester tester) async {
        await tester.pump(const Duration(seconds: 1));
        tester.printToConsole('Testing exam date feature');
        await loginTest(tester);
        await tester.pumpAndSettle();
        expect(find.byType(FloatingActionButton), findsOneWidget);
        await tester.tap(find.byType(
            FloatingActionButton));
        tester.printToConsole('Loading popup');
        await tester.pumpAndSettle();
        bool examDateSet = find
            .text('Change Exam Date')
            .evaluate()
            .isNotEmpty;
        await tester.pump(const Duration(seconds: 2));
        if (examDateSet) {
          // DELETE CURRENT DATE TO PROCEED WITH TEST
          tester.printToConsole('Exam date is already set');
          await tester.tap(find.text('Change Exam Date'));
          await tester.pumpAndSettle();
          // DELETE ALL BUTTON
          await tester.pump(const Duration(seconds: 2));
          var deleteButton = find.byWidgetPredicate((widget) {
            return widget is ElevatedButton &&
                widget.key == Key('deleteButton');
          });

          expect(deleteButton, findsOneWidget);
          await tester.tap(deleteButton);
          tester.printToConsole('Exam date deleted');
          await tester.pumpAndSettle();
          await tester.tap(find.text('Go to Homepage'));
          await tester.pumpAndSettle();

          bool isPopUp = find
              .text('Yes')
              .evaluate()
              .isNotEmpty;
          if (!isPopUp) {
            await tester.tap(find.byType(
                FloatingActionButton));
            tester.printToConsole('Loading popup');
            await tester.pumpAndSettle();
          }
        }
        await tester.pumpAndSettle();

        // Start entering exam details
        if (find
            .text('Yes')
            .evaluate()
            .isNotEmpty) tester.printToConsole("yes found");
        tester.printToConsole('${find.text('Yes').evaluate()}');
        expect(find.byKey(Key('yesButton')), findsAny);
        await tester.tap(find
            .byKey(Key('yesButton'))
            .first);
        await tester.pumpAndSettle();

        expect(find.text('Select Exam Date'), findsOneWidget);
        await tester.tap(find.text('Select Exam Date'));
        await tester.pumpAndSettle();

        expect(find.text('OK'), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        await tester.tap((find.byWidgetPredicate((widget) {
          return widget is Checkbox && widget.value == false;
        })).first);
        await tester.tap(find.text('Submit'));
        tester.printToConsole('Exam date set');
        await tester.pumpAndSettle();
      });

    testWidgets('Logging in and reset data', (WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 4));
      await loginTest(tester);
      await tester.pumpAndSettle();

      tester.printToConsole('HomePage screen opens');
      // Dashboard
      expect(find.byKey(
          const ValueKey('Settings')), findsNothing);
      await tester.tap(find.byKey(
        const ValueKey('Flashcards'),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(
          const ValueKey('Settings')), findsNothing);
      expect(find.byKey(
          const ValueKey('Revise')), findsOneWidget);
      tester.printToConsole('Dashboard opens');

      // Menu
      expect(find.byKey(
          const ValueKey('Settings')), findsNothing);
      await tester.tap(find.byIcon(
          Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byKey(
          const ValueKey('Settings')), findsOneWidget);
      tester.printToConsole('Menu opens');

      // User Details
      await tester.tap(find.byKey(
        const ValueKey('Settings'),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(
          const ValueKey('User Details')), findsOneWidget);
      tester.printToConsole('Settings opens');
      await tester.tap(find.byKey(
        const ValueKey('User Details'),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(
          const ValueKey('Reset Userdata')), findsOneWidget);
      tester.printToConsole('User Details opens');

      // Reset User Data
      await tester.tap(find.byKey(
        const ValueKey('Reset Userdata'),
      ));
      await tester.pumpAndSettle();
      tester.printToConsole('User data reset');
    });
  });
}