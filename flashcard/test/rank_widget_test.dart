import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  // setupCloudFirestoreMocks();
  late Widget rankWidget;
  late List<Map<String,dynamic>> questions;
  late List<List<String>> rankingAnswers;
  int currentQuestion = 0;

  setUp(() {
    Map<String, dynamic> question1 = {
      'question': 'Question 1 Text',
      'explanation': 'Explanation 1',
      'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5'],
      'correct_answers': ['A', 'B', 'E', 'C', 'D'],
      'questionNumber': 1,
      'type': "ranking"
    };

    Map<String, dynamic> question2 = {
      'question': 'Question 2 Text',
      'explanation': 'Explanation 2',
      'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5', 'Option 6', 'Option 7'],
      'correctAnswers': ['A', 'B', 'C'],
      'questionNumber': 2,
      'type': "multiple choice",
    };
    questions = [question1, question2];
    rankingAnswers = [['A','B','C','D','E']];

    rankWidget = MaterialApp(
        home: StatefulBuilder(builder: (context, setState) {
          return ReorderableListView(
            buildDefaultDragHandles: false,
            proxyDecorator:  (Widget child, int index, Animation<double> animation) {
              return Material(
                color: Colors.transparent,
                child: child,
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if(newIndex > oldIndex) newIndex --; // Adjust the list based on movement of item
                // Update position of option in answer list
                final ranking = rankingAnswers[currentQuestion].removeAt(oldIndex);
                rankingAnswers[currentQuestion].insert(newIndex, ranking);
                // Update position of option text in question list
                final option = questions[currentQuestion]['options'].removeAt(oldIndex);
                questions[currentQuestion]['options'].insert(newIndex, option);
              });
            },
            // Create children for the reorderable list using questions
            children: questions[currentQuestion]['options'].asMap().entries.map<Widget>((entry) {
              int optionIndex = entry.key;
              String option = entry.value;
              String optionLetter = rankingAnswers[currentQuestion][optionIndex];
              return ReorderableDragStartListener(
                  key: ValueKey(option),
                  index: optionIndex,
                  child: Card(
                      elevation: 3,
                      color: Color.fromARGB(255, 235, 230, 239),
                      child: ListTile(
                        title: Text('${optionIndex+1}:   $optionLetter. $option', style: TextStyle(color: Color.fromARGB(255, 98, 86, 139), fontSize: 20)),
                        trailing: Icon(Icons.drag_handle , color: Color.fromARGB(255, 98, 86, 139), size: 30),
                      )
                  )
              );
            }).toList(),
          );
        })
    );
  });

  testWidgets('Ranking UI displays options in correct order and ranking', (WidgetTester tester) async {
    await tester.pumpWidget(rankWidget);
    await tester.pumpAndSettle();
    expect(find.text('1:   A. Option 1'), findsOneWidget);
    expect(find.text('2:   B. Option 2'), findsOneWidget);
    expect(find.text('3:   C. Option 3'), findsOneWidget);
    expect(find.text('4:   D. Option 4'), findsOneWidget);
    expect(find.text('5:   E. Option 5'), findsOneWidget);
  });
}