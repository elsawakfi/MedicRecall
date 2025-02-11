import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:collection/collection.dart';

import 'minimock_landing.dart';

class MiniMockFeedBack extends StatefulWidget {
  final String title;
  final String questionDirectory;
  final String answerDirectory;
  const MiniMockFeedBack({super.key, required this.title, required this.questionDirectory, required this.answerDirectory});

  @override
  State<MiniMockFeedBack> createState() => MinimockFeedbackState();
}

class MinimockFeedbackState extends State<MiniMockFeedBack> {
  int currentQuestion = 0;
  List<Map<String, dynamic>> questions = [];
  Map<String, dynamic> userAnswers = {};
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  final ScrollController _optionScrollController = ScrollController();
  final ScrollController _explanationScrollController = ScrollController();

  @override
  void dispose() {
    _optionScrollController.dispose();
    _explanationScrollController.dispose();
    super.dispose();
  }

   @override
  void initState() {
    super.initState();
    getQuestions(); // Fetch the questions on initialisation (Needed as this is not to be called in the widget build)
    getUser();
    fetchUserAnswers(); //Fetch the user's answers from the database
  }

 Future<void> getUser() async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth
          .authStateChanges()
          .first;
      if (tmp == null) {
        nav.push(
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            )
        );
      } else {
        user = tmp;
      }
    } else {
      user = auth.currentUser!;
    }
  }


  Future<List<Map<String, dynamic>>> queryQuestionData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(widget.questionDirectory).orderBy('questionNumber').get(); //questions are not properly stored in order on firestore so order via a field instead
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> getQuestions() async {
    try {
      List<Map<String, dynamic>> fetchedQuestions = await queryQuestionData();
      // Initialise questions and selectedOptions based on fetched data
      setState(() {
        questions = fetchedQuestions;
        for (var doc in questions){
          String type = doc['type'];
          switch (type) {
            case 'ranking':
              String modifiedQuestion = doc['question'].replaceFirst('Rank', '\nRank');
              doc['question'] = modifiedQuestion; // Add a newline between the question (could store a newline in the firebase itself but this allows for easier customisation)
              break;
            case 'multiple choice':
              String modifiedQuestion = doc['question'].replaceFirst('Choose', '\nChoose');
              doc['question'] = modifiedQuestion;
              break;
            default:
          }
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching questions: $error');
      }
    }
  }

  Future<Map<String, dynamic>> queryUserAnswerData() async {
       QuerySnapshot snapshot = await FirebaseFirestore.instance
           .collection('users')
           .where('userID', isEqualTo: user.uid)
           .get();
       var id = snapshot.docs.last.id;
       DocumentSnapshot<
           Map<String, dynamic>> userAnswers = await FirebaseFirestore.instance
           .collection('users').doc(id).collection('Exam answers').doc(
           widget.answerDirectory).get();
       Map<String, dynamic> userAnswerMap = userAnswers.get('answers');
       return userAnswerMap;

  }

  Future<void> fetchUserAnswers() async {
    try {
      // Fetch the question data (this simulates your Future)
      Map<String, dynamic> fetchedUserAnswers = await queryUserAnswerData();

      // Initialise questions and selectedOptions based on fetched data
      setState(() {
        userAnswers = fetchedUserAnswers;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching answers: $error');
      }
    }
}

  //need to query for the user's answers stored in firebase

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
      ),
      body: questions.isEmpty || userAnswers.isEmpty
          ? Center(child: CircularProgressIndicator()) // If data is still being fetched, show loading circle
          : Padding( //Else load the data

        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Spacer(),
                Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    width: 160,
                    height: 40.31,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color.fromARGB(255, 235, 230, 239),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text('Question ${currentQuestion+1}/${questions.length}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 98, 86, 139),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                )
              ]
            ),
            // Display the current question text
            Text(
              questions[currentQuestion]['question'],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // If the question is a ranking question, display a reorderable list of options
            if (questions[currentQuestion]['type'] == "ranking") ...[
              Row(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('  Given Answer:', style: TextStyle(color: Colors.white,fontSize: 18)),
                              ...questions[currentQuestion]['options'].asMap().entries.map<Widget>((entry) {
                                int optionIndex = entry.key;
                                String option = entry.value;
                                String optionLetter = String.fromCharCode(optionIndex + 65);
                                return Card(
                                  color: (questions[currentQuestion]['correct_answers'][optionIndex] == userAnswers[(currentQuestion+1).toString()][optionIndex])
                                      ? Colors.green
                                      : Colors.red.shade400,
                                    child: ListTile(
                                      title: Text('$optionLetter. $option', style: TextStyle(color: Colors.white,fontSize: 18))
                                    )
                                );
                              }).toList()
                            ]
                        ),
                      )
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('  Correct Answer:', style: TextStyle(color: Colors.white,fontSize: 18)),
                            ...questions[currentQuestion]['options'].asMap().entries.map<Widget>((entry) {
                              int optionIndex = entry.key;
                              String option = entry.value;
                              String optionLetter = String.fromCharCode(optionIndex + 65);
                              return Card(
                                child: ListTile(
                                  title: Text('$optionLetter. $option',
                                      style: TextStyle(color: Colors.blueGrey, fontSize: 18)),
                                )
                              );
                            }).toList()
                          ]
                      ),
                    )
                  ),
              ])
            ]
            // If the question is a multiple choice question, display checkboxes
            else if(questions[currentQuestion]['type'] == "multiple choice") ...[
              //Line below takes the result of the map() and spreads its widgets into the children of Column
              Expanded(
                child: Scrollbar(
                  controller: _optionScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _optionScrollController,
                      child: Column(
                          children: questions[currentQuestion]['options'].asMap().entries.map<Widget>((entry) {
                            int optionIndex = entry.key;
                            String option = entry.value;
                            String optionLetter = String.fromCharCode(optionIndex + 65);
                            return CheckboxListTile(
                              title: Text('$optionLetter. $option', style: TextStyle(color: Colors.white, fontSize: 18)),
                              value: false,
                              onChanged: null,
                              side: BorderSide( color: Colors.white),
                              enabled: false,
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }).toList()
                      )
                  )
              )),
              SizedBox(height: 10),
              //display the selected answers and the correct answers
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                color: (UnorderedIterableEquality().equals(questions[currentQuestion]['correct_answers'], userAnswers[(currentQuestion+1).toString()]))
                        ? Colors.green
                        : Colors.red.shade400, // Dark background for contrast
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white), // White border
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Given Answer: ${userAnswers[(currentQuestion+1).toString()]}", style: TextStyle(color: Colors.white,fontSize: 18)),
                    Text("Correct Answer: ${questions[currentQuestion]['correct_answers']}", style: TextStyle(color: Colors.white,fontSize: 18))
                  ]
                )
              ),
            ],
            SizedBox(height: 10),
            Expanded(
              child: Scrollbar(
                controller: _explanationScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _explanationScrollController,
                 //Display the explanation of the question
                  child: Text(
                    questions[currentQuestion]['explanation'],
                    style: TextStyle(fontSize: 18),
                  )
                )
              )
            ),
            //compare the answers keys and the user's answers and provided
            //format tbd

            // Buttons to change questions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (currentQuestion > 0) //Prevents button being shown if no previous questions available
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        currentQuestion--; // Move to previous question
                      });
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text('Previous', style: TextStyle(color: Colors.white)),
                  ),
                const SizedBox(width: 16),
                if (currentQuestion < questions.length - 1)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        currentQuestion++; // Move to next question
                      });
                    },
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    label: Text('Next', style: TextStyle(color: Colors.white)),
                  ),
                if (currentQuestion == questions.length - 1)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MiniMockLanding(),
                        ),
                      );
                    },
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    label: Text('Mini-Mock Menu', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    )
    );
  }      
  }

