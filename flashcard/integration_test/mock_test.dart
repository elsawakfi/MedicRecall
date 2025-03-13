import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'app_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Mock Tests:', () {
    //
    // testWidgets("Run through the mini-mock-1 exam",
    //       (WidgetTester tester) async {
    //     await tester.pump(const Duration(seconds: 1));
    //     tester.printToConsole('Testing exam date feature');
    //     await loginTest(tester);
    //     await tester.pumpAndSettle();
    //
    //     expect(find.text('Mini-Mocks'), findsOneWidget);
    //     await tester.tap(find.text('Mini-Mocks'));
    //     await tester.pumpAndSettle();
    //
    //     expect(find.text('Mini-Mock 1'), findsOneWidget);
    //     await tester.tap(find.text('Mini-Mock 1'));
    //     await tester.pumpAndSettle();
    //
    //     expect(find.text('Begin Exam'), findsOneWidget);
    //     await tester.tap(find.text('Begin Exam'));
    //     await tester.pumpAndSettle();
    //
    //     // Check if navigation works
    //     expect(find.text('Question 1/25'), findsOneWidget);
    //     expect(find.text('Next'), findsOneWidget);
    //     await tester.tap(find.text('Next'));
    //     await tester.pumpAndSettle();
    //     expect(find.text('Question 2/25'), findsOneWidget);
    //     await tester.tap(find.text('Previous'));
    //     await tester.pumpAndSettle();
    //     expect(find.text('Question 1/25'), findsOneWidget);
    //
    //     // Check flagging system works
    //     expect(find.text('Flag for review'), findsOneWidget);
    //     await tester.tap(find.text('Flag for review'));
    //     await tester.pumpAndSettle();
    //     expect(find.text('Flagged'), findsOneWidget);
    //
    //     // Check review page works
    //     await tester.tap(find.text('Review Page'));
    //     await tester.pumpAndSettle();
    //     await tester.tap(find.text('Ranking Questions (Question 1 - 13)'));
    //     await tester.pumpAndSettle();
    //     expect(find.byIcon(Icons.flag), findsOneWidget);
    //
    //     await tester.tap(find.text('1'));
    //     await tester.pumpAndSettle();
    //     expect(find.text('Question 1/25'), findsOneWidget);
    //
    //     // Complete the exam
    //     await tester.tap(find.text('Review Page'));
    //     await tester.pumpAndSettle();
    //     await tester.tap(find.text('Complete Exam'));
    //     await tester.pumpAndSettle();
    //   });

    testWidgets("Test Ranking and Multiple Choice UI",
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
            expect(find.text('Question 1/25'), findsOneWidget);


            List<ValueKey<String>> expectedOrder = [ValueKey('A'), ValueKey('B'), ValueKey('C'), ValueKey('D'), ValueKey('E')];
            var listTiles = tester.widgetList<ReorderableDragStartListener>(find.byType(ReorderableDragStartListener));

            // Verify the number of items matches
            expect(listTiles.length, expectedOrder.length);
            // Verify the order of items
            for (var i = 0; i < expectedOrder.length; i++) {
                var listTile = listTiles.elementAt(i);
                expect(listTile.key, expectedOrder[i]);
            }

            dynamic optionSize = tester.getSize(find.byKey(ValueKey('A')));
            // Move A to B: ['A','B','C','D','E'] -> ['B','A','C','D','E']
            Offset optionPosition = tester.getCenter(find.byKey(ValueKey('A')));
            Offset targetPosition = tester.getBottomLeft(find.byKey(ValueKey('B')));
            // Calculate the required distance for the drag function (requires offset of a tile's height)
            double yOffset = targetPosition.dy - (optionPosition.dy - optionSize.height);
            // Simulate dragging option 1 from its position to the position of option 2
            await tester.dragFrom(optionPosition, Offset(0, yOffset));
            await tester.pumpAndSettle();

            expectedOrder = [ValueKey('B'), ValueKey('A'), ValueKey('C'), ValueKey('D'), ValueKey('E')];
            listTiles = tester.widgetList<ReorderableDragStartListener>(find.byType(ReorderableDragStartListener));

            // Verify the number of items matches
            expect(listTiles.length, expectedOrder.length);
            // Verify the order of items
            for (var i = 0; i < expectedOrder.length; i++) {
                var listTile = listTiles.elementAt(i);
                expect(listTile.key, expectedOrder[i]);
            }
        });
  });
}