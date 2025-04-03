import '../widgets/minimock_exam.dart';
import 'package:flashcard_x/widgets/minimock_exam.dart';

class MiniMockExam1 extends MiniMockExam {
  const MiniMockExam1({super.key}): super(
    title: "Mini-Mock Exam 1",
    shortTitle: "Mock 1",
    questionDirectory: "mini-mock-1",
    answerDirectory: "mini-mock-1-answers",
    time: 2700, // Measured in seconds, e.g. 2700s = 45 minutes
  );
}

class MiniMockExam2 extends MiniMockExam {
  const MiniMockExam2({super.key}): super(
      title: "Mini-Mock Exam 2",
      shortTitle: "Mock 2",
      questionDirectory: "mini-mock-2",
      answerDirectory: "mini-mock-2-answers",
      time: 2700,
  );
}


class FullMockExam1 extends MiniMockExam {
  const FullMockExam1({super.key}): super(
      title: "Full Mock Exam",
      shortTitle: "Full Mock 1",
      questionDirectory: "full-mock-1",
      answerDirectory: "full-mock-1-answers",
      time: 5700,
  );
} 