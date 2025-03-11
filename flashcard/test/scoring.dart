import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> userAnswers;
  late List<Map<String, dynamic>> questions;
  late int totalScore;
  late int maxScore;

  setUp(() {
    Map<String, dynamic> question1 = {
      'question': '',
      'explanation': '',
      'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5'],
      'correct_answers': ['A', 'B', 'C', 'D', 'E'],
      'questionNumber': 1,
      'type': "ranking"
    };

    Map<String, dynamic> question2 = {
      'question': '',
      'explanation': '',
      'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5'],
      'correct_answers': ['E','D','C','B','A'],
      'questionNumber': 2,
      'type': "ranking"
    };
    Map<String, dynamic> question3 = {
      'question': '',
      'explanation': '',
      'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5', 'Option 6', 'Option 7', 'Option 8'],
      'correct_answers': ['A', 'B', 'C'],
      'questionNumber': 1,
      'type': "multiple choice",
    };
    Map<String, dynamic> question4 = {
      'question': '',
      'explanation': '',
      'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5', 'Option 6', 'Option 7', 'Option 8'],
      'correct_answers': ['D', 'E', 'F'],
      'questionNumber': 2,
      'type': "multiple choice",
    };
    questions = [question1, question2, question3, question4];
    totalScore = 0;
    maxScore = 0;
  });

  void calculateScores() {
    var userAnswers;
    int tempMaxScore = 0;
    List<int> answerScores = List.filled(5, 0); // Placeholder to ensure page loads
    userAnswers.forEach((questionNumber, userAnswer) {
      int questionIndex = int.parse(questionNumber) - 1;
      switch (questions[questionIndex]['type']) {
        case 'ranking':
          tempMaxScore += 20; // Each ranking question is worth a max of 20 marks
          int userScore = 0;
          for (int i = 0; i < userAnswer.length; i++) {
            userScore += (4 - (questions[questionIndex]['correct_answers'][i].codeUnitAt(0) - userAnswer[i].codeUnitAt(0)).abs()).toInt();
          }
          answerScores[questionIndex] = userScore;
          break;
        case 'multiple choice':
          tempMaxScore += 12; // Each multiple choice question is worth a max of 12 marks.
          int userScore = 0;
          List correctAnswers = questions[questionIndex]['correct_answers'];
          for (int i = 0; i < correctAnswers.length; i++) {
            if (userAnswer.contains(correctAnswers[i])) {
              userScore += 4; // Each correct answer is worth 4 marks.
            }
          }
          answerScores[questionIndex] = userScore;
          break;
        default:
      }
    });
    totalScore = answerScores.reduce((value, element) => value + element);
    maxScore = tempMaxScore;
  }

}

