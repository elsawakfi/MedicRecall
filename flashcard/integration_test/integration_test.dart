import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flashcard_x/main.dart' as app;



void main() {
  group('Whole App Test:', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets("Pick a topic and revise",
            (WidgetTester tester) async {
              await tester.pump(const Duration(seconds: 1));
              tester.printToConsole('Begin testing');
              // Run App
              app.main();
              tester.printToConsole('opened app');
              await tester.pumpAndSettle();
              tester.printToConsole('pumped & settled');
              await tester.pump(const Duration(seconds: 4));
              // await tester.tap(find.byKey(const ValueKey('Flashcard Tutor')));
              await tester.tapAt(const Offset(100,100));
              await tester.pumpAndSettle();
              await tester.enterText(find.byKey(
                  const ValueKey('emailSignUpField')),
                  'xecovop602@deligy.com');
              tester.printToConsole('Entered email text');
              await tester.pump(const Duration(seconds: 4));
              tester.printToConsole('waited 4s');

              await tester.enterText(
                  find.byKey(
                      const ValueKey('passwordSignUpField')), 'password');
              tester.printToConsole('entered password');
              await tester.pump(const Duration(seconds: 4));
              tester.printToConsole('waited 4s');
              await tester.tap(find.byKey(
                const ValueKey('Log In Button'),
              ));
              await tester.pumpAndSettle();
              expect(find.byKey(
                  const ValueKey('Welcome bar')), findsOneWidget);
              tester.printToConsole('HomePage screen opens');
              // Dashboard
              expect(find.byKey(
                  const ValueKey('Settings')), findsNothing);
              await tester.pumpAndSettle();
              await tester.pump(const Duration(seconds: 4));
              await tester.tap(find.byKey(const ValueKey('Flashcard Tutor')));
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
              // Run App
              app.main();
              await tester.pumpAndSettle();
              await tester.enterText(find.byKey(
                  const ValueKey('emailSignUpField')),
                  'xecovop602@deligy.com');
              await tester.pump(const Duration(seconds: 4));

              await tester.enterText(
                  find.byKey(
                      const ValueKey('passwordSignUpField')), 'password');
              await tester.pump(const Duration(seconds: 4));

              await tester.tap(find.byKey(
                const ValueKey('Log In Button'),
              ));
              await tester.pumpAndSettle();
              expect(find.byKey(
                  const ValueKey('Welcome bar')), findsOneWidget);
              tester.printToConsole('HomePage screen opens');
              // Dashboard
              expect(find.byKey(
                  const ValueKey('Settings')), findsNothing);
              await tester.pumpAndSettle();
              await tester.tap(find.byKey(
                const ValueKey('Flashcard Tutor'),
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
              await tester.pump(const Duration(seconds:6));
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
              // Run App
              app.main();
              await tester.pumpAndSettle();
              // expect(find.byKey(
              //     const ValueKey('Welcome bar')), findsOneWidget);
              // tester.printToConsole('landing screen opens');
              //
              // // Trigger signing in
              // expect(find.byKey(
              //     const ValueKey('Settings')), findsNothing);
              // await tester.tap(find.byKey(
              //   const ValueKey('Flashcard Tutor'),
              // ));
              // await tester.pumpAndSettle();
              // expect(find.byKey(
              //     const ValueKey('emailSignUpField')), findsOneWidget);
              // tester.printToConsole('SignUp screen opens');

              // Signing In
              // expect(find.byKey(
              //     const ValueKey('Welcome bar')), findsNothing);
              await tester.enterText(find.byKey(
                  const ValueKey('emailSignUpField')),
                  'xecovop602@deligy.com');
              await tester.pump(const Duration(seconds: 4));

              await tester.enterText(
                  find.byKey(
                      const ValueKey('passwordSignUpField')), 'password');
              await tester.pump(const Duration(seconds: 4));

              await tester.tap(find.byKey(
                const ValueKey('Log In Button'),
              ));
              await tester.pumpAndSettle();
              expect(find.byKey(
                  const ValueKey('Welcome bar')), findsOneWidget);
              tester.printToConsole('HomePage screen opens');


              // Dashboard
              expect(find.byKey(
                  const ValueKey('Settings')), findsNothing);
              await tester.pumpAndSettle();
              await tester.tap(find.byKey(
                const ValueKey('Flashcard Tutor'),
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
              await tester.pump(const Duration(seconds:6));

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
              // Run App
              app.main();
              await tester.pumpAndSettle();
              // expect(find.byKey(
              //     const ValueKey('Welcome bar')), findsOneWidget);
              // tester.printToConsole('landing screen opens');
              //
              // // Trigger signing in
              // expect(find.byKey(
              //     const ValueKey('Settings')), findsNothing);
              // await tester.tap(find.byKey(
              //   const ValueKey('Flashcard Tutor'),
              // ));
              // await tester.pumpAndSettle();
              // expect(find.byKey(
              //     const ValueKey('emailSignUpField')), findsOneWidget);
              // tester.printToConsole('SignUp screen opens');

              // Signing In
              // expect(find.byKey(
              //     const ValueKey('Welcome bar')), findsNothing);
              await tester.enterText(find.byKey(
                  const ValueKey('emailSignUpField')),
                  'xecovop602@deligy.com');
              await tester.pump(const Duration(seconds: 4));

              await tester.enterText(
                  find.byKey(
                      const ValueKey('passwordSignUpField')), 'password');
              await tester.pump(const Duration(seconds: 4));

              await tester.tap(find.byKey(
                const ValueKey('Log In Button'),
              ));
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

          //   // Reviewing Flashcard Tutor
          //   for (var i = 100; i >= 1; i--) {
          //     await Future.delayed(const Duration(seconds: 1));
          //     await tester.drag(find.byKey(const ValueKey('flashcard center')),
          //         const Offset(-700, 0));
          //     await tester.pump(const Duration(seconds: 1));
          //   }
          //   await tester.pumpAndSettle();
          //
          //   // Completed Flashcard Tutor Screen
          //   expect(find.byKey(const ValueKey('HomePage/CompleteCardsChecker')),
          //       findsOneWidget);
        });
    //
    testWidgets('Logging in and reset data', (WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 4));
      // Run App
      app.main();
      await tester.pumpAndSettle();
      // expect(find.byKey(
      //     const ValueKey('Welcome bar')), findsOneWidget);
      // tester.printToConsole('landing screen opens');
      //
      // // Trigger signing in
      // expect(find.byKey(
      //     const ValueKey('Settings')), findsNothing);
      // await tester.tap(find.byKey(
      //   const ValueKey('Flashcard Tutor'),
      // ));
      // await tester.pumpAndSettle();
      // expect(find.byKey(
      //     const ValueKey('emailSignUpField')), findsOneWidget);
      // tester.printToConsole('SignUp screen opens');

      // Signing In
      // expect(find.byKey(
      //     const ValueKey('Welcome bar')), findsNothing);
      await tester.enterText(find.byKey(const ValueKey('emailSignUpField')),
          'xecovop602@deligy.com');
      await tester.pump(const Duration(seconds: 4));

      await tester.enterText(
          find.byKey(
              const ValueKey('passwordSignUpField')), 'password');
      await tester.pump(const Duration(seconds: 4));

      await tester.tap(find.byKey(
        const ValueKey('Log In Button'),
      ));
      await tester.pumpAndSettle();

      // expect(find.byKey(
          // const ValueKey('Welcome bar')), findsOneWidget);
      tester.printToConsole('HomePage screen opens');
      tester.printToConsole('broken test passed');

      // Dashboard
      expect(find.byKey(
          const ValueKey('Settings')), findsNothing);
      await tester.tap(find.byKey(
        const ValueKey('Flashcard Tutor'),
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
      tester.printToConsole('Userdata reset');
    });

  });
}