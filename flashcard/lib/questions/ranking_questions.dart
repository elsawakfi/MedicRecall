import 'package:flashcard_x/questions/option.dart';
import 'package:flashcard_x/questions/score_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/*
Ranking questions
You are given a scenario and 5? options.
Need to rank them in order of decreasing importance / relevance,
or another appropriate metric.
Score is based on your answer's proximity to the actual answer
 */

/*
TO DO:
1- function which takes in the value from each option, convert to a list of ints
whichever is best to mark against according to the table
2 - scoring function, take the result from func1 and return a score based on the table
 */

class RankingQuestions extends StatefulWidget {
  const RankingQuestions({Key? key}) : super(key: key);

  @override
  RankingQuestionsStateO createState() => RankingQuestionsStateO();
}

class RankingQuestionsStateO extends State<RankingQuestions> {
  String? value = '0';

  int score = 20;

  List<String> answers = ['X', 'X', 'X', 'X', 'X'];

  List<String> items = [
    'Select', // this is the choices provided to the user.
    '1 = Very appropriate',
    '2 = Somewhat appropriate',
    '3 = In the middle',
    '4 = Somewhat inappropriate',
    '5 = Inappropriate'
  ];

  List<String> idealAnswers = [
    '1 = Very appropriate',
    '3 = In the middle',
    '5 = Inappropriate',
    '2 = Somewhat appropriate',
    '4 = Somewhat inappropriate'
  ];

  int generateScore(answers, idealAnswers) {
    score = 20;
    for (int i = 0; i < answers.length; i++) {
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
        title: const Text('Ranking Questions'),
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
                            "Your shift was due to end at 5pm. You have stayed on the ward until 6pm due to a medical emergency.\n Mrs Pleat has recently been transferred from your ward but you notice that she does not have a drug chart that should have been brought with her from the previous ward. ",
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
                            "Rank the following options in order of appropriateness. \n"
                            "1 = Most Appropriate, \n"
                            "5 = Least Appropriate \n"
                            "Don't pick the same result for more than one answer",
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
                      "A) Phone the previous ward to discuss Mr Griffin’s management plan and drug chart",
                  optionChoice: value,
                  // value is default = 'Select'
                  onChanged: (value) {
                    // when the 'value' is changed by the user, this then updates the answer list with their choice
                    answers[0] = value;
                  },
                  items: items),

              Option(
                  optionText:
                      "B) Ask the nurse in charge to request the drug chart from the previous ward as soon as possible.",
                  optionChoice: value,
                  onChanged: (value) {
                    answers[1] = value;
                  },
                  items: items),

              Option(
                  optionText:
                      "C) Send a message to the FY1 doctor on the next shift stating that Mrs Pleat does not have a drug chart.",
                  optionChoice: value,
                  onChanged: (value) {
                    answers[2] = value;
                  },
                  items: items),

              Option(
                  optionText:
                      "D) Handover to the night shift FY1 doctor to chase the drug chart.",
                  optionChoice: value,
                  onChanged: (value) {
                    answers[3] = value;
                  },
                  items: items),

              Option(
                  optionText:
                      "E) Inform a senior doctor (speciality trainee*) that Mrs Pleat was admitted without the correct paperwork.",
                  optionChoice: value,
                  onChanged: (value) {
                    answers[4] = value;
                  },
                  items: items),

              // creates a text box holding an option
              //answers.add(value.toString()),

              // add n-1 more options

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
                                questionRationale: 'The correct ranking is: \n'
                                    '\n'
                                    '1,3,5,2,4',
                                threshold: 15,
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
