import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'app_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Exam Button Tests:', () {

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
                widget.key == ValueKey('deleteButton');
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
        expect(find.text('Yes'), findsAny);
        await tester.tap(find
            .text('Yes')
            .first);
        await tester.pumpAndSettle();

        expect(find.text('Select Exam Date'), findsOneWidget);
        await tester.tap(find.text('Select Exam Date'));
        await tester.pumpAndSettle();

        expect(find.text('OK'), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        expect(find.byType(Checkbox), findsAny);
        await tester.tap((find.byWidgetPredicate((widget) {
          return widget is Checkbox && widget.value == false;
        })).first);
        await tester.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();


        //Checks that the checkbox builds correctly 
        expect(find.byType(Checkbox), findsWidgets);
        await tester.tap(find.byKey(ValueKey('Official MSRA Practice Paper')));
         await tester.pump();
        await tester.tap(find.byKey(ValueKey('Full-sized Mock Exam')));
         await tester.pump();
        await tester.tap (find.byKey(ValueKey('Mini-mocks')));
         await tester.pump();
        await tester.tap(find.byKey(ValueKey('Flashcard Decks')));
         await tester.pump();
        await tester.tap(find.byKey(ValueKey('Official SJT Practice Paper')));
         await tester.pump();

        // await tester.tap((find.byWidgetPredicate((widget) {
        //   return widget is Checkbox && widget.value == false;
        // })).first);
        await tester.pumpAndSettle();
        // Possible Focus Manager errors occur if the line below isn't used
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        // await tester.tap(find.text('Submit'));
        await tester.tap(find.byKey(ValueKey('submitButton1')));
        await tester.pumpAndSettle();

        expect(find.byType(ChoiceChip), findsAny);
        await tester.tap((find.byType(ChoiceChip)).first);
        await tester.pumpAndSettle();
        // await tester.tap(find.text('Submit'));
        await tester.tap(find.byKey(ValueKey('submitButton2')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ok'));
        await tester.pumpAndSettle();

        tester.printToConsole('Exam date set');
        await tester.pumpAndSettle();
      });
  });
}