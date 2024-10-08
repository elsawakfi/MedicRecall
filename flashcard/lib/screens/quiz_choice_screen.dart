import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../questions/multiple_choice_questions.dart';
import '../questions/question_faq.dart';
import '../questions/ranking_questions.dart';
import '../questions/rating_questions.dart';

int textSize = 30;

class Questions extends StatelessWidget {
  const Questions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test yourself!'),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () =>
              Navigator.popUntil(context, ModalRoute.withName(HomePage.id)),
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
              child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(500)),
            alignment: Alignment.center,
            child: FractionallySizedBox(
                widthFactor: 0.75,
                // means 100%, you can change this to 0.8 (80%)
                heightFactor: 0.4,
                child: ElevatedButton.icon(
                    icon: const Icon(Icons.notes, color: Colors.black),
                    label: Text(
                      "Multiple choice questions",
                      style: TextStyle(
                          color: Colors.black, fontSize: textSize.toDouble()),
                    ),
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MCQ()),
                        ))),
          )),
          Flexible(
              child: Container(
            alignment: Alignment.center,
            child: FractionallySizedBox(
                // wrapped button in a box to make width adjustable
                widthFactor:
                    0.75, // means 100%, you can change this to 0.8 (80%)
                heightFactor: 0.4,
                child: ElevatedButton.icon(
                    icon: const Icon(Icons.onetwothree_outlined,
                        color: Colors.black),
                    label: Text("Ranking questions",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: textSize.toDouble())),
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RankingQuestions()),
                        ))),
          )),
          Flexible(
              child: Container(
            alignment: Alignment.center,
            child: FractionallySizedBox(
                // wrapped button in a box to make width adjustable
                widthFactor:
                    0.75, // means 100%, you can change this to 0.8 (80%)
                heightFactor: 0.4,
                child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_box, color: Colors.black),
                    label: Text("Rating questions",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: textSize.toDouble())),
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RatingQuestions()),
                        ))),
          )),
          Flexible(
              child: Container(
            alignment: Alignment.center,
            child: FractionallySizedBox(
                // wrapped button in a box to make width adjustable
                widthFactor:
                    0.75, // means 100%, you can change this to 0.8 (80%)
                heightFactor: 0.4,
                child: ElevatedButton.icon(
                    icon: const Icon(Icons.question_mark, color: Colors.black),
                    label: Text("Info",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: textSize.toDouble())),
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QuestionFAQ()),
                        ))),
          )),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
