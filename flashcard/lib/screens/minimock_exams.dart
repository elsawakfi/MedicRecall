import '../widgets/minimock_exam.dart';

class MiniMockExam1 extends MiniMockExam {
  const MiniMockExam1({super.key}): super(
    title: "Mini-Mock Exam 1",
    questionDirectory: "mini-mock-1",
    answerDirectory: "mini-mock-1-answers",
    time: 2700, // Measured in seconds, e.g. 2700s = 45 minutes
  );
}

class MiniMockExam2 extends MiniMockExam {
  const MiniMockExam2({super.key}): super(
      title: "Mini-Mock Exam 2",
      questionDirectory: "mini-mock-2",
      answerDirectory: "mini-mock-2-answers",
      time: 2700,
  );
}


class FullMockExam extends MiniMockExam {
  const FullMockExam({super.key}): super(
      title: "Full Mock Exam",
      questionDirectory: "full-mock-1",
      answerDirectory: "full-mock-1-answers",
      time: 3600,
  );
} 