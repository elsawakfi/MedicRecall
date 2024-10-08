import 'package:flashcard_x/questions/option.dart';
import 'package:flashcard_x/questions/score_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MCQ extends StatefulWidget {
  const MCQ({Key? key}) : super(key: key);

  @override
  MCQStateO createState() => MCQStateO();
}

class MCQStateO extends State<MCQ> {
  List<String> topics = [
    "Maintaining patient focus",
    "Coping with pressure"
  ]; // Topic, may need to be displayed

  String? value =
      'NO'; // default value displayed  // default value to be shown to the user before they choose their answer

  List<String> answers = [
    'NO',
    'NO',
    'NO',
    'NO',
    'NO',
    'NO',
    'NO',
    'NO'
  ]; // default for all is NO, easier for them to select the 3 correct answers

  List<String> items = ['NO', 'YES']; // The 2 options they can pick from

  // if 2 no's are there, maybe remove no from the items

  List<String> idealAnswers = [
    // Mark scheme
    'NO',
    'YES', //B
    'NO',
    'NO',
    'NO',
    'YES', //F
    'YES', //G
    'NO'
  ];

  int score = 12; // score is initially the best, wrong answers are penalised

  //function to generate a score based on the users answers and the ideal answers.

  int generateScore(answers, idealAnswers) {
    score = 12;
    for (int i = 0; i < answers.length; i++) {
      // loop through the answer lists
      if (idealAnswers[i] != answers[i]) {
        // compare the answers to the mark scheme
        score = score - 4; // if they are incorrect, subtract from the score
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
        title: const Text('Multiple Choice Questions'),
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
                            "You are part of the team involved in the care of a 90-year-old patient, Mrs Turner, who has metastatic liver cancer and has now been put on a palliative care pathway. \n You are reviewing her notes at her bedside when her son comes into the room and insists on being able to take his mother home immediately. He tells you that he does not want her to remain on the hospital ward, and instead wants her to die at home surrounded by all of her family. Mrs Skinner is awake and appears to be distressed by the situation.",
                            //get the question from the map
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ))),
                  )),
              Container(
                  width: double.infinity,
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
                            "Choose the THREE most appropriate actions to take in this scenario.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ))),
                  )),

              const SizedBox(height: 20),

              //Option is a class that generates an option box, where the question and the user's choice is displayed
              Option(
                optionText: "Ask Mrs Turner's son to try and calm down.",
                // text to be shown as the option
                optionChoice: value,
                // value is default = 'NO'
                onChanged: (value) {
                  // when the 'value' is changed by the user,
                  answers[0] =
                      value; //this then updates the answer list with their choice
                },
                items: items, // answer choices
              ),
              // creates a text box holding an option

              Option(
                  optionText:
                      "Suggest to Mrs Turner's son that he come with you to a quiet room on the ward.",
                  optionChoice: value,
                  onChanged: (String value) {
                    answers[1] = value;
                  },
                  items: items),

              Option(
                optionText:
                    "Ask a senior doctor on the ward to speak to Mrs Turner's son.",
                optionChoice: value,
                onChanged: (String value) {
                  answers[2] = value;
                },
                items: items,
              ),

              Option(
                optionText: "Call security to defuse the situation",
                optionChoice: value,
                onChanged: (String value) {
                  answers[3] = value;
                },
                items: items,
              ),

              Option(
                  optionText:
                      " Inform Mrs Turner that you will discuss the situation with her son.",
                  optionChoice: value,
                  onChanged: (String value) {
                    answers[4] = value;
                  },
                  items: items),

              Option(
                  optionText:
                      "Try to explore with the son the rationale behind his request.",
                  optionChoice: value,
                  onChanged: (String value) {
                    answers[5] = value;
                  },
                  items: items),

              Option(
                  optionText:
                      "Discuss with Mrs Turner what her preference is for where she dies.",
                  optionChoice: value,
                  onChanged: (String value) {
                    answers[6] = value;
                  },
                  items: items),

              Option(
                  optionText:
                      "Advise Mrs Turner to ask her son to leave the ward until he is calmer.",
                  optionChoice: value,
                  onChanged: (String value) {
                    answers[7] = value;
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
                                questionRationale: 'Correct Answer : B,F,G'
                                    'The first priority here is to try and diffuse this tense situation. \n'
                                    '\n'
                                    'This can be done by first suggesting that you speak with the son in a quiet room B (to minimise stress to the patient) and also exploring the rationale behind the son’s request G. \n'
                                    '\n'
                                    'You also need to clarify Mrs Turner\'s preference for dying to maintain patient focus as they are the patient and their wishes are more important than the son’s. This should be done ideally away from this pressured situation. \n'
                                    '\n'
                                    'You need to gain consent from Mrs Skinner to discuss her care with the son. Therefore E would be appropriate if you asked rather than simply ‘informing’ Mrs Skinner that you are going to have this conversation.\n'
                                    '\n'
                                    'Asking a disgruntled patient or relative to calm down is not helpful and may antagonise him A. Similarly, asking to patient to tell their relative to leave is inappropriate and will lead to an escalation in the situation H. \n'
                                    '\n'
                                    'Security should only be called is the son is perceived to be an immediate danger to patient or staff safety which is not the case here D. \n'
                                    '\n'
                                    'A senior doctor will likely be needed to speak with the son but this is not needed to address the current tense situation, which is the key problem in the scenario C.',
                                threshold: 8,
                                maxMark: 12,
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
