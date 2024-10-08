import 'package:flashcard_x/questions/option.dart';
import 'package:flashcard_x/questions/score_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RatingQuestions extends StatefulWidget {
  const RatingQuestions({Key? key}) : super(key: key);

  @override
  RatingQuestionsStateO createState() => RatingQuestionsStateO();
}

class RatingQuestionsStateO extends State<RatingQuestions> {
  String? value = 'Select';

  List<String> answers = ['X', 'X', 'X', 'X', 'X'];

  List<String> items = [
    'Select', // this is the choices provided to the user.
    '1 = Very appropriate',
    '2 = Somewhat appropriate',
    '3 = Somewhat inappropriate',
    '4 = Inappropriate'
  ];

  List<String> idealAnswers = [
    '1 = Very appropriate',
    '2 = Somewhat appropriate',
    '4 = Inappropriate',
    '4 = Inappropriate',
    '3 = Somewhat inappropriate'
  ];

  int score = 20; // score is initially the best, wrong answers are penalised

  //function to generate a score based on the users answers and the ideal answers.

  int generateScore(answers, idealAnswers) {
    score = 20;
    for (int i = 0; i < items.length; i++) {
      // loop through the answer lists

      int idealChoice = int.parse(
          idealAnswers[i][0]); // numerical representation of the ideal answer
      if (answers[i][0] == 'S' || answers[i][0] == 'X') {
        // It will be S when they selected 'Select', X when they didnt pick an answer
        score = score - 4; // if they dont guess, penalise 4 marks
      } else {
        int userChoice = int.parse(
            answers[i][0]); // the numerical representation of their answer
        score = score -
            (userChoice - idealChoice).abs(); // remove the absolute value,
        // score per question is the absolute difference between the user's choice and the ideal choice.
      }
    }

    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text('Rating Questions'),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
            children: [
              Row(
                children: const [
                  SizedBox(
                    height: 20,
                  )
                ],
              ),

              Container(
                  width: double.infinity,
                  height: 130,
                  margin: const EdgeInsets.only(
                      bottom: 10.0, left: 30.0, right: 30.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const SingleChildScrollView(
                    // allow for scrolling if its a long question
                    child: Center(
                        child: Text(
                            "You recently attended an infection control briefing about the importance of washing your hands between seeing patients. \n You are working on a busy shift and you notice that your FY1 colleague never washes their hands between patients.",
                            //get the question from the map
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ))),
                  )),
              Container(
                  width: double.infinity,
                  height: 130,
                  margin: const EdgeInsets.only(
                      bottom: 10.0, left: 30.0, right: 30.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.deepOrangeAccent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const SingleChildScrollView(
                    // allow for scrolling if its a long question
                    child: Center(
                        child: Text(
                            "Rate the appropriateness of the following actions in response to this situation. \n (1= Very appropriate; 2= Somewhat appropriate; 3= Somewhat inappropriate; 4= Inappropriate)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ))),
                  )),

              const SizedBox(height: 20),

              //Option is a class that generates an option box, where the question and the user's choice is displayed
              Option(
                optionText:
                    "Speak directly to your FY1 colleague about your observation.",
                optionChoice: value, // value is default = 'Select'
                onChanged: (value) {
                  // when the 'value' is changed by the user, this then updates the answer list with their choice
                  answers[0] = value;
                },
                items: items,
              ),
              // creates a text box holding an option
              //answers.add(value.toString()),

              Option(
                  optionText:
                      "Raise your observation with the nurse in charge of the ward.",
                  optionChoice: value,
                  onChanged: (String value) {
                    answers[1] = value;
                  },
                  items: items),

              Option(
                optionText:
                    "Tell infection control that your colleague is not complying with their policy.",
                optionChoice: value,
                onChanged: (String value) {
                  answers[2] = value;
                },
                items: items,
              ),

              Option(
                optionText:
                    "Do not say anything immediately but monitor the situation over the course of the next few days.",
                optionChoice: value,
                onChanged: (String value) {
                  answers[3] = value;
                },
                items: items,
              ),

              Option(
                  optionText:
                      "Discuss the situation with your speciality trainee.",
                  optionChoice: value,
                  onChanged: (String value) {
                    answers[4] = value;
                  },
                  items: items),

              MaterialButton(
                  //submission button
                  color: Colors.blue,
                  onPressed: () {
                    if (kDebugMode) {
                      print(score);
                    }
                    generateScore(answers, idealAnswers);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScorePage(
                                score: score,
                                questionRationale:
                                    'A: Very appropriate - this gives your colleague an opportunity to explain themselves (they may be feeling stressed and simply forgot to) before changing their practice.  It is a direct and timely solution to the issue. \n'
                                    '\n'
                                    'B: Somewhat appropriate - This option has several positives i.e the nurse in charge is best placed to ensure standards are met on the ward and may be able to help address the scenario so it doesn\'t happen in the future.  However, this may be an unnecessary escalation which could be resolved with approaching the colleague directly. \n'
                                    '\n'
                                    'C: Inappropriate - this action is disproportionate to the mistake, it does not explore the reason for the error and will damage your professional relationship with the FY1. \n'
                                    '\n'
                                    'D: Inappropriate - All doctors have a duty to raise concerns where they believe that patient safety is being compromised by the practice of colleagues. \n'
                                    '\n'
                                    'E: Somewhat inappropriate - discussion with your speciality trainee could be of some use in addressing the scenario but does not address the problem. It is also an unnecessary escalation and may affect working relationships within your team.\n',
                                threshold: 16,
                                maxMark: 20,
                              )),
                    );
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ))
            ],
          )))
        ],
      )),
    );
  }
}
