import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flashcard_x/main.dart' as app;

Future<void> loginTest(WidgetTester tester) async{
  await tester.pump(const Duration(seconds: 1));
  tester.printToConsole('Starting app');
  // Run App
  app.main();
  tester.printToConsole('App started');
  await tester.pumpAndSettle();

  // Finding the email is really on and off for some reason
  var emailFinder = find.byKey(const ValueKey('emailSignUpField'));
  if(emailFinder.evaluate().isNotEmpty) {
    tester.printToConsole('Found email field');
  } else {
    tester.printToConsole("No email field found");
  }
  expect(emailFinder, findsOneWidget);
  await tester.enterText(emailFinder,
      'xecovop602@deligy.com');
  tester.printToConsole('Entered email text');

  await tester.enterText(
      find.byKey(
          const ValueKey('passwordSignUpField')), 'password');
  tester.printToConsole('entered password');
  await tester.tap(find.byKey(
    const ValueKey('Log In Button'),
  ));
  await tester.pumpAndSettle();

  //CLOSE POP UP
  bool isPopUp = find.text('No').evaluate().isNotEmpty;
  if(isPopUp){
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets("Log into the app",
          (WidgetTester tester) async {
        tester.printToConsole('Testing login');
        await loginTest(tester);
        await tester.pumpAndSettle();
      });

  testWidgets("Set Exam Date",
          (WidgetTester tester) async {
        tester.printToConsole('Testing exam date feature');
        await loginTest(tester);
        await tester.pumpAndSettle();
        expect(find.byType(FloatingActionButton), findsOneWidget);
        await tester.tap(find.byType(
            FloatingActionButton));
        tester.printToConsole('Loading popup');
        await tester.pumpAndSettle();
        bool examDateSet = find.text('Change Exam Date').evaluate().isNotEmpty;
        if (examDateSet) {

          // DELETE CURRENT DATE TO PROCEED WITH TEST
          tester.printToConsole('Exam date is already set');
          await tester.tap(find.text('Change Exam Date'));
          await tester.pumpAndSettle();
          expect(find.text('DELETE ALL'), findsOneWidget);
          await tester.tap(find.text('DELETE ALL'));
          tester.printToConsole('Exam date deleted');
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(
              Icons.menu));
          await tester.pumpAndSettle();
          await tester.tap(find.text('MedicRecall'));
          await tester.pumpAndSettle();

          bool isPopUp = find.text('Yes').evaluate().isNotEmpty;
          if (!isPopUp) {
            await tester.tap(find.byType(
                FloatingActionButton));
            tester.printToConsole('Loading popup');
            await tester.pumpAndSettle();
          }
        }

        if(find.text('Yes').evaluate().isNotEmpty) tester.printToConsole("yes found");
        expect(find.text('Yes'), findsOneWidget);
        await tester.tap(find.text('Yes'));
        await tester.pumpAndSettle();
        expect(find.text('Pick Date'), findsOneWidget);
        await tester.tap(find.text('Pick Date'));
        await tester.pumpAndSettle();
        expect(find.text('OK'), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        // expect(find.byWidgetPredicate((widget) {
        //   return widget is Text && widget.data!.contains('repetitions');
        // }), findsOneWidget);
        // await tester.tap(find.byType(TextField));
        // await tester.pump(const Duration(seconds: 2));
        // await tester.enterText(find.byType(TextField),
        //     '8');
        await tester.tap(find.byWidgetPredicate((widget) {
          return widget is RadioListTile<int> && widget.value == 2;
        }));
        tester.printToConsole('Entered number of repetitions');
        await tester.pumpAndSettle();
        expect(find.text('Next'), findsOneWidget);
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(Checkbox).at(2));
        await tester.tap(find.text('Submit'));
        tester.printToConsole('Exam date set');
        await tester.pumpAndSettle();

        expect(find.text('Revision Calendar'), findsOneWidget);
        await tester.tap(find.text('Revision Calendar'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('DELETE ALL'), findsOneWidget);
        await tester.tap(find.text('DELETE ALL'));
        tester.printToConsole('Exam date deleted');
        await tester.pump(const Duration(seconds: 2));

        // Log out
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
        tester.printToConsole('Logged out');
      });

  // testWidgets("Access and complete a mini-mock",
  //         (WidgetTester tester) async {
  //           await tester.pumpAndSettle();
  //
  //           expect(find.byKey(
  //               const ValueKey('Mini-mock')), findsOneWidget);
  //           await tester.tap(find.byKey(
  //               const ValueKey('Mini-mock')));
  //           tester.printToConsole('Loading mini-mock landing');
  //           await tester.pumpAndSettle();
  //
  //
  //         });


// });
}