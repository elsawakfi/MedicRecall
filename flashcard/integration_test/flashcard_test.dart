import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'app_test.dart';

void main() {
  group('Whole App Test:', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets("Pick a topic and revise",
            (WidgetTester tester) async {
          await tester.pump(const Duration(seconds: 1));
          await loginTest(tester);
          await tester.pumpAndSettle();

          expect(find.byKey(
              const ValueKey('Welcome bar')), findsOneWidget);
          tester.printToConsole('HomePage screen opens');
          // Dashboard
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 4));
          await tester.tap(find.byKey(const ValueKey('Flashcards')));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          expect(find.byKey(
              const ValueKey('Revise')), findsOneWidget);
          tester.printToConsole('Dashboard opens');

          // Flashcard Tutor Topic
          await tester.tap(find.byKey(
            const ValueKey('Checkbox'),
          ));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(
            const ValueKey('Revise'),
          ));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          expect(find.byIcon(
              Icons.check), findsOneWidget);
          tester.printToConsole('Flashcard opens');
          //Back to the topic choice
          //below
          await tester.tap(find.byIcon(
              Icons.arrow_back));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          expect(find.byIcon(
              Icons.menu), findsOneWidget);
          tester.printToConsole('Back to the topic choice');
          // Menu
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          await tester.tap(find.byIcon(
              Icons.menu));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsOneWidget);
          tester.printToConsole('Menu opens');
          // Logging out
          await tester.tap(find.byKey(
            const ValueKey('Log Out Button'),
          ));
          await tester.pumpAndSettle();
          tester.printToConsole('Back to SignUp screen');
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
        });

    testWidgets("Tick button",
            (WidgetTester tester) async {
          await tester.pump(const Duration(seconds: 4));
          await loginTest(tester);
          await tester.pumpAndSettle();

          expect(find.byKey(
              const ValueKey('Welcome bar')), findsOneWidget);
          tester.printToConsole('HomePage screen opens');
          // Dashboard
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(
            const ValueKey('Flashcards'),
          ));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          expect(find.byKey(
              const ValueKey('Revise')), findsOneWidget);
          tester.printToConsole('Dashboard opens');
          // Flashcard Tutor Topic
          await tester.tap(find.byKey(
            const ValueKey('Checkbox'),
          ));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(
            const ValueKey('Revise'),
          ));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 6));
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          expect(find.byIcon(
              Icons.check), findsOneWidget);
          tester.printToConsole('Flashcard opens');

          // Click tick button
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          await tester.tap(find.byIcon(
              Icons.check),
          );
          await tester.pumpAndSettle();
          expect(find.text(
              'Correct!'), findsOneWidget);
          tester.printToConsole('Tick button clicked');

          //Back to the topic choice
          await tester.tap(find.byIcon(
              Icons.arrow_back));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          expect(find.byIcon(
              Icons.menu), findsOneWidget);
          tester.printToConsole('Back to the topic choice');

          // Menu
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          await tester.tap(find.byIcon(
              Icons.menu));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsOneWidget);
          tester.printToConsole('Menu opens');

          // Logging out
          await tester.tap(find.byKey(
            const ValueKey('Log Out Button'),
          ));
          await tester.pumpAndSettle();
          tester.printToConsole('Back to SignUp screen');
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
        });

    testWidgets("Cross button",
            (WidgetTester tester) async {
          await tester.pump(const Duration(seconds: 4));
          await loginTest(tester);

          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Welcome bar')), findsOneWidget);
          tester.printToConsole('HomePage screen opens');

          // Dashboard
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(
            const ValueKey('Flashcards'),
          ));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          expect(find.byKey(
              const ValueKey('Revise')), findsOneWidget);
          tester.printToConsole('Dashboard opens');

          // Flashcard Tutor Topic
          await tester.tap(find.byKey(
            const ValueKey('Checkbox'),
          ));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(
            const ValueKey('Revise'),
          ));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 6));

          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          expect(find.byIcon(
              Icons.check), findsOneWidget);
          tester.printToConsole('Flashcard opens');

          // Click cross button
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          await tester.tap(find.byIcon(
              Icons.close),
          );
          await tester.pumpAndSettle();
          expect(find.text(
              'Wrong!'), findsOneWidget);
          tester.printToConsole('Tick button clicked');

          //Back to the topic choice
          await tester.tap(find.byIcon(
              Icons.arrow_back));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          expect(find.byIcon(
              Icons.menu), findsOneWidget);
          tester.printToConsole('Back to the topic choice');

          // Menu
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          await tester.tap(find.byIcon(
              Icons.menu));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsOneWidget);
          tester.printToConsole('Menu opens');

          // Logging out
          await tester.tap(find.byKey(
            const ValueKey('Log Out Button'),
          ));
          await tester.pumpAndSettle();
          tester.printToConsole('Back to SignUp screen');
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
        });

    testWidgets("Open markscheme and comments",
            (WidgetTester tester) async {
          await tester.pump(const Duration(seconds: 4));
          await loginTest(tester);
          await tester.pumpAndSettle();

          expect(find.byKey(
              const ValueKey('Welcome bar')), findsOneWidget);
          tester.printToConsole('HomePage screen opens');

          // Mark Scheme
          await tester.tap(find.byKey(
            const ValueKey('Mark Scheme'),
          ));
          await tester.pump(const Duration(seconds: 2));
          expect(find.byKey(
              const ValueKey('Rating Questions')), findsOneWidget);
          tester.printToConsole('Mark scheme opens');

          // Question Type
          expect(find.byKey(const ValueKey('Settings')), findsNothing);
          await tester.tap(find.byKey(
            const ValueKey('Rating Questions'),
          ));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Question 1')), findsOneWidget);
          tester.printToConsole('Rating Questions opens');

          // Choose Question
          await tester.tap(find.byKey(
            const ValueKey('Question 1'),
          ));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Comments')), findsOneWidget);
          tester.printToConsole('Question opens');

          await tester.tap(find.byKey(
            const ValueKey('Comments'),
          ));
          await tester.pump(const Duration(seconds: 2));
          expect(find.byIcon(
              Icons.arrow_upward), findsOneWidget);
          tester.printToConsole('Comments open');

          //Back to the topic choice
          await tester.tap(find.byIcon(
              Icons.arrow_back));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(
              Icons.arrow_back));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(
              Icons.arrow_back));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          expect(find.byIcon(
              Icons.menu), findsOneWidget);
          tester.printToConsole('Back to the topic choice');

          // Menu
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
          await tester.tap(find.byIcon(
              Icons.menu));
          await tester.pumpAndSettle();
          expect(find.byKey(
              const ValueKey('Settings')), findsOneWidget);
          tester.printToConsole('Menu opens');

          // Logging out
          await tester.tap(find.byKey(
            const ValueKey('Log Out Button'),
          ));
          await tester.pumpAndSettle();
          tester.printToConsole('Back to SignUp screen');
          expect(find.byKey(
              const ValueKey('Settings')), findsNothing);
        });
  });
}