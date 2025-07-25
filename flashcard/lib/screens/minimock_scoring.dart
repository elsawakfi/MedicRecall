import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/minimock_feedback.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flashcard_x/widgets/circular_percentage_indicator.dart';
import 'package:http/http.dart' as http;
import '../widgets/drawer_widget2.dart';
import 'package:flashcard_x/screens/landing_screen.dart';
import 'package:flashcard_x/screens/landing_screen_new.dart';


class MiniMockScoring extends StatefulWidget {
  final String title;
  final String questionDirectory;
  final String answerDirectory;
  
  const MiniMockScoring({
    super.key,
    required this.title,
    required this.questionDirectory,
    required this.answerDirectory,
    

  });
  @override
  State<MiniMockScoring> createState() => MiniMockScoringState();
}
class MiniMockScoringState extends State<MiniMockScoring> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

  List<Map<String, dynamic>> questions = [];
  Map<String, dynamic> userAnswers = {};

  List<int> answerScores = [];
  int totalScore = 0;
  double userPercentageScore = 0;
  double averagePercentageScore = 0;
  int maxScore = 0;
  double averageScore = 0;
  final scoringIndicator = ScoreIndicator;

  @override
  void initState() {
    super.initState();
    initialise(); // As calculateScores relies on data we need from firebase we require the use of 'await'
  }

  Future<void> initialise() async{
    await getQuestions(); // Fetch the questions on initialisation
    await getUser();
    await fetchAverageScore(); // Fetch the average score for the mock
    await fetchUserAnswers(); //Fetch the user's answers from the database
    calculateScores();
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
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(widget.questionDirectory)
        .orderBy('questionNumber').get(); //questions are not properly stored in order on firestore so order via a field instead
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> getQuestions() async {
    try {
      List<Map<String, dynamic>> fetchedQuestions = await queryQuestionData();
      setState(() {
        // Extract the necessary data from the fetchedQuestions and turn it into the same format as userAnswers
        questions = fetchedQuestions;
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
        .collection('users').doc(id).collection('examAnswers').doc(
        widget.answerDirectory).get();
    Map<String, dynamic> userAnswerMap = userAnswers.get('answers');
    return userAnswerMap;
  }

  Future<void> fetchUserAnswers() async {
    try {
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

Future<void> fetchAverageScore() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('mini-mock-stats')
        .doc(widget.questionDirectory)
        .get();
    int median;
    // Ensure the median exists else set it to 0
    (snapshot.exists) ? median = snapshot.get('median') : median = 0;
    averageScore = median.toDouble();
  }


  void calculateScores(){
    int tempMaxScore = 0;
    answerScores = List.filled(questions.length, 0); // Placeholder to ensure page loads

    userAnswers.forEach((questionNumber, userAnswer){
      int questionIndex = int.parse(questionNumber) - 1; // String question number to integer index
      // Score answers based on question type:
      switch (questions[questionIndex]['type']) {
        case 'ranking':
          tempMaxScore += 20; // Each ranking question is worth a max of 20 marks
          int userScore = 0;
          // The for loop gets the ASCII value of the letters at each index and subtracts them from one another to get a difference
          // It then subtracts the absolute value of the difference from 4 to get the correct score for that index based on the mark scheme
          // To check for errors just make a list of each score and print it
          for(int i = 0; i < userAnswer.length; i++){
            (userAnswer[i] != '') ? userScore += (4 - (questions[questionIndex]['correct_answers'][i].codeUnitAt(0) - userAnswer[i].codeUnitAt(0)).abs()).toInt()
                                  : userScore += 0;
          }
          answerScores[questionIndex] = userScore;
          break;
        case 'multiple choice':
          tempMaxScore += 12; // Each multiple choice question is worth a max of 12 marks.
          int userScore = 0;
          List correctAnswers = questions[questionIndex]['correct_answers'];
          for(int i = 0; i < correctAnswers.length; i++){
            if (userAnswer.contains(correctAnswers[i])){
              userScore += 4; // Each correct answer is worth 4 marks.
            }}
          answerScores[questionIndex] = userScore;
          break;
        default:  
      }
    });
    totalScore = answerScores.reduce((value, element) => value + element);
    userPercentageScore = (totalScore / tempMaxScore) * 100;
    averagePercentageScore = (averageScore/ tempMaxScore) * 100;
    setState(() {
      maxScore = tempMaxScore;
      totalScore = totalScore;
    });
    _updateScore(totalScore);
  }


  // Update user's score for this mock
  Future<void> _updateScore(int score) async {
    final CollectionReference users = FirebaseFirestore.instance.collection(
        'users');
    QuerySnapshot u =
    await users.where("userID", isEqualTo: user.uid).get();
    var id = u.docs.last.id;
    DocumentReference userDocRef = FirebaseFirestore.instance.collection(
        'users').doc(id);
    DocumentReference scoreDocRef = userDocRef.collection(
        'examAnswers').doc(widget.answerDirectory);

    // Add user's score to user score field
    await scoreDocRef.update({
      'score': score,
    });
  }

  @override
  Widget build(BuildContext context) {
    return  PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result){
        if (!didPop){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Landing()
            ),
          );
        }
      },
      child: Scaffold(
        drawer: const DrawMain2(),
        appBar: CustomAppBar(title: 'Scoring Page', mobileTitle: 'Scoring'),
        body: answerScores.isEmpty || (maxScore == 0)
            ? Center(child: CircularProgressIndicator(),) // If data is still being fetched, show loading circle
            : LayoutBuilder( builder: (context, constraints) {
            double maxScreenWidth = constraints.maxWidth * 0.5;
            double maxPreferredWidth = 960; // 1920/2
            bool isDesktop = constraints.maxWidth > 600;

          return Center(
              child: Container(decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          )
                        ],
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    constraints: BoxConstraints(
                      maxWidth: maxScreenWidth > maxPreferredWidth
                          ? maxScreenWidth
                          : maxPreferredWidth,
                           minHeight: constraints
                            .maxHeight, // Ensure container takes full height
                    ),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                    child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [ isDesktop
              ? Row( // Displaying horizontally on the desktop view
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    ScoreIndicator(
                      title: 'Your Score: ',
                      totalScore: '$totalScore/$maxScore',
                      percentageScore: userPercentageScore,
                      radius: 120,
                      lineWidth: 25.0,
                      progressColor: Colors.red,
                      backgroundColor: Colors.green,
                      textColor: Colors.black, // Add this parameter to set text color
                    ),
                    
                  SizedBox(width:100),
                      ScoreIndicator(
                      title: 'Global Average: ',
                      totalScore: '$averageScore/$maxScore',
                      percentageScore: averagePercentageScore,
                      radius: 120.0,
                      lineWidth:  25.0,
                      progressColor: Colors.red,
                      backgroundColor:  Colors.green,
                      textColor: Colors.black,
                    ),
                ],
              )
              : Column( //Displaying vertically on the mobile UI
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                      ScoreIndicator(
                      title: 'Your Score: ',
                      totalScore: '$totalScore/$maxScore',
                      percentageScore: userPercentageScore,
                      radius: 90.0,
                      lineWidth: 20.0,
                      progressColor: Colors.red,
                      backgroundColor: Colors.green,
                      textColor: Colors.black, // Add this parameter to set text color
                    ),
                  
                  SizedBox(height: 20),
                      ScoreIndicator(
                      title: 'Global Average: ',
                      totalScore: '$averageScore/$maxScore',
                      percentageScore: averagePercentageScore,
                      radius: 90.0,
                      lineWidth:  20.0,
                      progressColor: Colors.red,
                      backgroundColor:  Colors.green,
                      textColor: Colors.black, // Add this parameter to set text color
                    ),
                ],
              ),
              ],
            ),
          ))),
          Align(
              alignment: Alignment.bottomRight,
              child:
              Container(
                  width: MediaQuery.of(context).size.width < 600 ? 50 : 130,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color.fromARGB(255, 222, 221, 222),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 6,
                        offset: const Offset(0, 6), // changes position of shadow
                      ),
                    ],
                  ),
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MiniMockFeedBack(
                              title: widget.title,
                              questionDirectory: widget.questionDirectory,
                              answerDirectory: widget.answerDirectory,
                              answerScores: answerScores,
                            ),
                          ),
                        );
                      },
                      child: (MediaQuery.of(context).size.width < 600)
                          ? Icon(Icons.arrow_forward, color: Colors.black)
                          : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Feedback', style: TextStyle(color: Colors.black, fontSize: 18)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, color: Colors.black),
                          ]
                      )
                  ))),
              ])));
            }),
      ));
  }
}