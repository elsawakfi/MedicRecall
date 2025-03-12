import 'package:flashcard_x/widgets/minimock_exam.dart';

import '../widgets/fullmock_exam.dart';

class FullMockExam1 extends MiniMockExam {
  const FullMockExam1({super.key}): super(
      title: "Full Mock Exam",
      questionDirectory: "full-mock-1",
      answerDirectory: "full-mock-1-answers",
      time: 5700,
  );
} 