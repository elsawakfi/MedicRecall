import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_x/main.dart' as app;
import 'package:integration_test/integration_test.dart';
import 'calendar_test.dart' as calendar;
import 'flashcard_test.dart' as flashcard;
import 'mock_test.dart' as mock;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets("Log into the app",
          (WidgetTester tester) async {
        await tester.pump(const Duration(seconds: 1));
        tester.printToConsole('Testing login');
        await loginTest(tester);
        await tester.pumpAndSettle();
      });

  // calendar.main();
  mock.main();
  // flashcard.main();
}

// Reusable test function for logging in
Future<void> loginTest(WidgetTester tester) async{
  await tester.pump(const Duration(seconds: 1));
  tester.printToConsole('Starting app');
  // Run App
  app.main();
  tester.printToConsole('App started');
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();

  // Finding the email is really on and off for some reason
  var emailFinder = find.byKey(const ValueKey('emailSignUpField'));
  if(emailFinder.evaluate().isNotEmpty) {
    tester.printToConsole('Found email field');
  } else {
    tester.printToConsole("No email field found");
  }
  expect(emailFinder, findsOneWidget);
  await tester.enterText(emailFinder,
      'ooz05506@jioso.com');
  tester.printToConsole('Entered email text');
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();

  // Flutter focuses on text fields resulting in possible errors in testing if not disposed of
  await tester.enterText(
      find.byKey(
          const ValueKey('passwordSignUpField')), 'password');
  tester.printToConsole('entered password');
  await tester.tap(find.byKey(
    const ValueKey('Log In Button'),
  ));
  await tester.pumpAndSettle();
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();

  //CLOSE POP UP
  bool isPopUp = find.text('No').evaluate().isNotEmpty;
  if(isPopUp){
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
  }
}
