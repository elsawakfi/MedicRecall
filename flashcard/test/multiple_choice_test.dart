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
      'correctAnswers': ['A', 'B', 'C'],
      'questionNumber': 1,
      'type': "multiple choice",
    };
    Map<String, dynamic> question2 = {
      'question': 'Question 2 Text',
      'explanation': 'Explanation 2',
      'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5', 'Option 6', 'Option 7', 'Option 8'],
      'correctAnswers': ['A', 'C', 'H'],
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
}