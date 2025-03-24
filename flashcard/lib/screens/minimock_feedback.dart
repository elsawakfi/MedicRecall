import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../widgets/drawer_widget.dart';
import 'fullmock_landing.dart';
import 'minimock_landing.dart';

class MiniMockFeedBack extends StatefulWidget {
  final String title;
  final String questionDirectory;
  final String answerDirectory;
  final List<int> answerScores;
  const MiniMockFeedBack(
      {super.key,
      required this.title,
      required this.questionDirectory,
      required this.answerDirectory,
      required this.answerScores});

  @override
  State<MiniMockFeedBack> createState() => MinimockFeedbackState();
}

class MinimockFeedbackState extends State<MiniMockFeedBack> {
  int currentQuestion = 0;
  List<Map<String, dynamic>> questions = [];
  Map<String, dynamic> userAnswers = {};
  List<List<MapEntry<String, String>>> examOptions = []; // Correct option associated to each letter of the correct answers
  List<List<MapEntry<String, String>>> userOptions = []; // Correct option associated to each letter of the user answers

  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialise();
  }

  Future<void> initialise() async {
    await getQuestions(); // Fetch the questions on initialisation
    await getUser();
    await fetchUserAnswers(); //Fetch the user's answers from the database
    // _reorderAnswers();
  }

  Future<void> getUser() async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth.authStateChanges().first;
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
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(widget.questionDirectory)
        .orderBy('questionNumber')
        .get(); //questions are not properly stored in order on firestore so order via a field instead
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> getQuestions() async {
    try {
      List<Map<String, dynamic>> fetchedQuestions = await queryQuestionData();
      // Initialise questions and selectedOptions based on fetched data
      setState(() {
        questions = fetchedQuestions;
        for (var doc in questions) {
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

  void _reorderAnswers() {
    if (questions.isNotEmpty) {
      for (int i = 0; i < questions.length; i++) {
        if (questions[i]['type'] != "ranking") {
          break;
        }
        List<dynamic> options = questions[i]['options'];
        List<dynamic> examLetters = questions[i]['correct_answers'];
        List<dynamic> userLetters = userAnswers[(i + 1).toString()];

        // Assign each option a letter
        // Generates a list where each option is paired with their associated letter
        // These letters are then compared with the index of the correct arrangement allowing them to be reordered correctly
        // (Essentially pairs each letter in correct_answers, which is just a list of letters, to their respective option for later visualisation)
        List<MapEntry<String, String>> tempExamOptions = List.generate(
            options.length, (index) => MapEntry(String.fromCharCode(65 + index), options[index]));
        tempExamOptions.sort((a, b) => examLetters.indexOf(a.key).compareTo(examLetters.indexOf(b.key)));
        examOptions.add(tempExamOptions);

        // (Essentially pairs each letter in userAnswers, which is just a list of letters, to their respective option for later visualisation)
        List<MapEntry<String, String>> tempUserOptions = List.generate(
            options.length, (index) => MapEntry(String.fromCharCode(65 + index), options[index]));
        tempUserOptions.sort((a, b) => userLetters.indexOf(a.key).compareTo(userLetters.indexOf(b.key)));
        userOptions.add(tempUserOptions);
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
           .collection('users')
           .doc(id).collection('examAnswers')
           .doc(widget.answerDirectory).get();
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

  int questionMarks(int currentQuestion) {
    if (questions[currentQuestion]['type'] == 'ranking') {
      return 20;
    } else if (questions[currentQuestion]['type'] == 'multiple choice') {
      return 12;
    }
    return 0;
  }

  //need to query for the user's answers stored in firebase

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        drawer: const DrawMain(),
        appBar: AppBar(
          // backgroundColor: Colors.blue,
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Positioned(
                    top: 2.3,
                    child: Image.asset(
                      'assets/newlogo.png',
                      fit: BoxFit.cover,
                      height: 34,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 32),
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Feedback'),
                  ),
                ],
              )
            ],
          ),
          centerTitle: true,
          leading: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Icon(
                Icons.menu,
              ),
            ),
          ),
        ),
      body: userAnswers.isEmpty
        ? Center(child: CircularProgressIndicator()) // If data is still being fetched, show loading circle
        : LayoutBuilder( builder: (context, constraints) {
        double maxScreenWidth = constraints.maxWidth * 0.5;
        double maxPreferredWidth = 960; // 1920/2

                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: maxScreenWidth > maxPreferredWidth
                          ? maxScreenWidth
                          : maxPreferredWidth,
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row( children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            width: 160,
                            height: 40.31,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color.fromARGB(
                                  255, 235, 230, 239),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 0,
                                  blurRadius: 5,
                                  offset: const Offset(0,
                                      3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Question ${currentQuestion + 1}/${questions.length}',
                                style: const TextStyle(
                                  color:
                                      Color.fromARGB(255, 98, 86, 139),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )),
                          Spacer(),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            width: 160,
                            height: 40.31,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color.fromARGB(
                                  255, 235, 230, 239),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 0,
                                  blurRadius: 5,
                                  offset: const Offset(0,
                                      3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Score: ${widget.answerScores[currentQuestion]}/${questionMarks(currentQuestion)}',
                                style: const TextStyle(
                                  color:
                                      Color.fromARGB(255, 98, 86, 139),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        ]),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(children: [
                          // Display the current question text
                          Text(
                            questions[currentQuestion]['question'],
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          // If the question is a ranking question, display a reorderable list of options
                          if (questions[currentQuestion]['type'] == "ranking") ...[
                            Column(children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // USER ANSWERS
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('  Given Answer:',
                                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 18)),
                                        ...userAnswers[(currentQuestion+1).toString()].asMap().entries.map<Widget>((entry) {
                                          int optionIndex = entry.key;
                                          String optionLetter = entry.value;
                                          // Get the correct option based on the letter (e.g. B = 1 => is option 2 in the options array)
                                          String optionText = (optionLetter != '') ? '$optionLetter. ${questions[currentQuestion]['options'][optionLetter.codeUnitAt(0) - 65]}'
                                              : '';
                                          return Card(
                                              color: (questions[currentQuestion]['correct_answers'][optionIndex] == optionLetter)
                                                  ? Colors.green
                                                  : Colors.red.shade400,
                                              child: SizedBox(
                                                  width: double.infinity, // Define the width
                                                  child: ListTile(
                                                      title: Text(optionText, style: TextStyle(color: Colors.white,fontSize: 18))
                                                  ))
                                          );
                                        })
                                    ])
                                  ),
                                  // CORRECT ANSWERS
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                        Text('  Correct Answer:',
                                          style: TextStyle(
                                              color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 18)),
                                        ...questions[currentQuestion]['correct_answers'].asMap().entries.map<Widget>((entry) {
                                          String optionLetter = entry.value;
                                          String optionText = '$optionLetter. ${questions[currentQuestion]['options'][optionLetter.codeUnitAt(0) - 65]}';
                                          return Card(
                                              child: SizedBox(
                                                  width: double.infinity,
                                                  child: ListTile(
                                                    title: Text(optionText,
                                                        style: TextStyle(color: Colors.blueGrey, fontSize: 18)),
                                            )));
                                        })
                                    ]))
                                ])
                            ])
                          ]
                          // If the question is a multiple choice question, display checkboxes
                          else if (questions[currentQuestion]['type'] == "multiple choice") ...[
                            //Line below takes the result of the map() and spreads its widgets into the children of Column
                            Column(
                                children: questions[currentQuestion]['options'].asMap().entries.map<Widget>((entry) {
                              int optionIndex = entry.key;
                              String option = entry.value;
                              String optionLetter = String.fromCharCode(optionIndex + 65);
                              return ListTile(
                                title: Text('$optionLetter. $option',
                                    style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyMedium?.color)),
                                enabled: false,
                                dense: true,
                                visualDensity: VisualDensity(vertical: -4),
                              );
                            }).toList()),
                            SizedBox(height: 10),
                            //display the selected answers and the correct answers
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                margin: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: (UnorderedIterableEquality()
                                          .equals(questions[currentQuestion]['correct_answers'], userAnswers[(currentQuestion + 1).toString()]))
                                      ? Colors.green
                                      : Colors.red.shade400, // Dark background for contrast
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Given Answer: ${userAnswers[(currentQuestion + 1).toString()]}",
                                        style: TextStyle(color: Colors.white, fontSize: 18)),
                                    Text("Correct Answer: ${questions[currentQuestion]['correct_answers']}",
                                        style: TextStyle(color: Colors.white, fontSize: 18))
                                  ]
                                )))
                          ],
                          SizedBox(height: 10),
                          Text(questions[currentQuestion]['explanation'],
                            style: TextStyle(fontSize: 18),
                          )
                        ]))),
                        //compare the answers keys and the user's answers and provided
                        //format tbd

                        // Buttons to change questions
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (currentQuestion == 0) //Prevents button being shown if no previous questions available
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 98, 86, 139)),
                                  label: Text('Scoring',
                                      style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 98, 86, 139))),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 235, 230, 239),
                                  ),
                                ),
                              if (currentQuestion > 0) //Prevents button being shown if no previous questions available
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      currentQuestion--; // Move to previous question
                                    });
                                  },
                                  icon: Icon(Icons.arrow_back,
                                      color: Color.fromARGB(255, 98, 86, 139)),
                                  label: Text('Previous',
                                      style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 98, 86, 139))),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 235, 230, 239),
                                  ),
                                ),
                              const SizedBox(width: 16),
                              if (currentQuestion < questions.length - 1)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      currentQuestion++; // Move to next question
                                    });
                                  },
                                  icon: Icon(Icons.arrow_forward,
                                      color: Color.fromARGB(255, 98, 86, 139)),
                                  label: Text('Next',
                                      style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 98, 86, 139))),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 235, 230, 239),
                                  ),
                                ),
                              if (currentQuestion == questions.length - 1)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (widget.questionDirectory.contains("mini-mock")) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MiniMockLanding(),
                                        ),
                                      );
                                    } else if (widget.questionDirectory.contains("full-mock")) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const FullMockLanding(),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(Icons.arrow_forward,
                                      color: Color.fromARGB(255, 98, 86, 139)),
                                  label: Text('Menu',
                                      style: TextStyle(fontSize: 16,
                                          color: Color.fromARGB(255, 98, 86, 139))),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 235, 230, 239),
                                  ),
                                ),
                            ],
                          )),
                      ],
                    ),
                  ));
              })));
  }
}
