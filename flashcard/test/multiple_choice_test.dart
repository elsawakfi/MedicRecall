import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  // setupCloudFirestoreMocks();
  late Widget multipleChoiceWidget;
  late List<Map<String,dynamic>> questions;
  late List<List<bool>> multiChoiceAnswers;
  late String options;
  int currentQuestion = 0;

  setUp(() {
    options = 'ABCDEFGH';
    Map<String, dynamic> question1 = {
      'question': 'Question 1 Text',
      'explanation': 'Explanation 1',
      'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5', 'Option 6', 'Option 7', 'Option 8'],
      'correct_answers': ['A', 'B', 'C'],
      'questionNumber': 1,
      'type': "multiple choice",
    };
    Map<String, dynamic> question2 = {
      'question': 'Question 2 Text',
      'explanation': 'Explanation 2',
      'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5', 'Option 6', 'Option 7', 'Option 8'],
      'correct_answers': ['A', 'C', 'H'],
      'questionNumber': 2,
      'type': "multiple choice",
    };
    questions = [question1, question2];
    multiChoiceAnswers = [[false, false, false, false, false, false, false, false], [false, false, false, false, false, false, false, false]];

    multipleChoiceWidget = MaterialApp(
        home: StatefulBuilder(builder: (context, setState) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
              children: questions[currentQuestion]['options'].asMap().entries.map<Widget>((entry) {
                int optionIndex = entry.key;
                String option = entry.value;
                int questionIndex = currentQuestion;
                String optionLetter = options[optionIndex];
                return CheckboxListTile(
                  key: ValueKey(optionLetter),
                  fillColor: WidgetStateProperty.resolveWith<Color?>(
                        (states) {
                      if (states.contains(WidgetState.selected)) {
                        return Theme.of(context).textTheme.bodyMedium?.color; // Color when the checkbox is checked
                      }
                      return Colors.transparent; // Transparent when unchecked
                    },
                  ),
                  checkColor: Theme.of(context).scaffoldBackgroundColor,
                  title: Text('$optionLetter. $option', style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyMedium?.color)),
                  value: multiChoiceAnswers[questionIndex][optionIndex],
                  onChanged: (value) {
                    int checkedCount = multiChoiceAnswers[questionIndex].where((element) => element).length;
                    if (checkedCount < 3 || value == false) {
                      setState(() {
                        multiChoiceAnswers[questionIndex][optionIndex] = value!;
                      });
                    }
                  },
                  enableFeedback: false,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList()
            )));
        })
    );
  });

  // Function that creates lists of user answers in letter form using the boolean lists
  List<List<String>> booleanToString(List<List<bool>> multiChoice) {
    List<List<String>> multiChoiceLetters = [];
    for (int i = 0; i < multiChoice.length; i++){
      List<String> letters = [
        for (int j = 0; j < multiChoice[i].length; j++)
          if (multiChoice[i][j]) options[j]
      ];
      multiChoiceLetters.add(letters);
    }
    return multiChoiceLetters;
  }

  testWidgets('Multiple Choice UI displays options in correct order', (WidgetTester tester) async {
    await tester.pumpWidget(multipleChoiceWidget);
    await tester.pumpAndSettle();
    expect(find.text('A. Option 1'), findsOneWidget);
    expect(find.text('B. Option 2'), findsOneWidget);
    expect(find.text('C. Option 3'), findsOneWidget);
    expect(find.text('D. Option 4'), findsOneWidget);
    expect(find.text('E. Option 5'), findsOneWidget);
    expect(find.text('F. Option 6'), findsOneWidget);
    expect(find.text('G. Option 7'), findsOneWidget);
    expect(find.text('H. Option 8'), findsOneWidget);
  });

  testWidgets('Multiple Choice UI is interactable', (WidgetTester tester) async {
    await tester.pumpWidget(multipleChoiceWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('A')));
    await tester.pumpAndSettle();
    expect(multiChoiceAnswers[0], [true, false, false, false, false, false, false, false]);
    await tester.tap(find.byKey(ValueKey('A')));
    await tester.pumpAndSettle();
    expect(multiChoiceAnswers[0], [false, false, false, false, false, false, false, false]);
  });

  testWidgets('User cannot select more than 3 options at any time', (WidgetTester tester) async {
    await tester.pumpWidget(multipleChoiceWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('A')));
    await tester.tap(find.byKey(ValueKey('B')));
    await tester.tap(find.byKey(ValueKey('C')));
    await tester.pumpAndSettle();
    // Maximise selected options
    expect(multiChoiceAnswers[0], [true, true, true, false, false, false, false, false]);
    await tester.tap(find.byKey(ValueKey('D')));
    await tester.pumpAndSettle();
    // Ensure D has not been selected
    expect(multiChoiceAnswers[0], [true, true, true, false, false, false, false, false]);
    await tester.tap(find.byKey(ValueKey('A')));
    await tester.tap(find.byKey(ValueKey('D')));
    await tester.pumpAndSettle();
    // Check that A has been deselected, and D has been selected
    expect(multiChoiceAnswers[0], [false, true, true, true, false, false, false, false]);
  });

  testWidgets('Check that booleanToString converts lists correctly', (WidgetTester tester) async {
    // Simulate user answers
    multiChoiceAnswers = [[false, true, false, false, false, true, true, false], [true, true, true, false, false, false, false, false]];
    List<List<String>> userAnswers = booleanToString(multiChoiceAnswers);
    expect(userAnswers, [['B','F','G'],['A','B','C']]);
  });

}