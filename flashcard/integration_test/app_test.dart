import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_x/main.dart' as app;
import 'integration_test.dart' as integration;
import 'flashcard_test.dart' as flashcard;

void main() {
  integration.main();
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
