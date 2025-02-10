import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/minimock_feedback.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/widgets/average_percent_indicator';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flashcard_x/widgets/circular_percentage_indicator.dart';
import 'package:http/http.dart' as http;
// import 'package:percent_indicator/circular_percent_indicator.dart';


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
  double percentageScore = 0;
  late final int totalQuestions;
  int maxScore = 0;
  double averageScore = 0;
  final scoringIndicator = ScoreIndicator;
  final averageScoringIndicator = AverageScoreIndicator;

  @override
  void initState() {
    super.initState();
    initialise(); // As calculateScores relies on data we need from firebase we require the use of 'await'
  }

  Future<void> initialise() async{
    await getQuestions(); // Fetch the questions on initialisation
    await getUser();
    await fetchUserAnswers(); //Fetch the user's answers from the database
    calculateScores();
    // await fetchAverageScore(); // Fetch the average score from the database
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
      setState(() {
        // Extract the necessary data from the fetchedQuestions and turn it into the same format as userAnswers
        questions = fetchedQuestions;
        totalQuestions = questions.length;
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
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .get();
      // List scores = snapshot.docs.map((doc) => doc.get('score')).toList();
      int totalScores = 0;
      int userCount = snapshot.docs.length;
     
     for (var doc in snapshot.docs){
      DocumentSnapshot<Map<String, dynamic >> userAnswers = await FirebaseFirestore.instance
      .collection('users')
      .doc(doc.id)
      .collection('Exam answers')
      .doc(widget.answerDirectory)
      .get();
      Map<String, dynamic> userAnswerMap = userAnswers.get('answers');
      int userTotalScore = 0;

      userAnswerMap.forEach((questionNumber, userAnswer){
        int questionIndex = int.parse(questionNumber) - 1; // String question number to integer index
        // Score answers based on question type:
        switch (questions[questionIndex]['type']) {
          case 'ranking':
            if (ListEquality().equals(questions[questionIndex]['correct_answers'], userAnswer)){
              userTotalScore += 1;
            }
            break;
          case 'multiple choice':
            if (questions[questionIndex]['type'] == "multiple choice" &&
                UnorderedIterableEquality().equals(questions[questionIndex]['correct_answers'], userAnswer)){
              userTotalScore += 1;
            }
            break;
          default:
        }
      });
      totalScores +=userTotalScore;
     }
     averageScore = totalScores / userCount;
     setState((){
       averageScore = averageScore;
     });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching average score: $error');
      }
    }
  }

  void calculateScores(){
    int tempMaxScore = 0;
    answerScores = List.filled(25, 0); // Placeholder to ensure page loads

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
            userScore += (4 - (questions[questionIndex]['correct_answers'][i].codeUnitAt(0) - userAnswer[i].codeUnitAt(0)).abs()).toInt();
          }
          answerScores[questionIndex] = userScore;
          break;
        case 'multiple choice':
          tempMaxScore += 1;
          if (questions[questionIndex]['type'] == "multiple choice" &&
              UnorderedIterableEquality().equals(questions[questionIndex]['correct_answers'], userAnswer)){
            answerScores[questionIndex] = 1;
          } else{
            answerScores[questionIndex] = 0;
          }
          break;
        default:
      }
    });
    totalScore = answerScores.reduce((value, element) => value + element);
    percentageScore = (totalScore / tempMaxScore) * 100;
    setState(() {
      maxScore = tempMaxScore;
      totalScore = totalScore;
      percentageScore = percentageScore;
    });
    _updateScore(totalScore);
  }

  ScoreIndicator get circularPercentIndicator{
    return ScoreIndicator(
      title: "Your Score: ", 
      totalScore: '$totalScore/25',
      percentageScore: percentageScore, 
      radius: 80.0, lineWidth: 10.0, 
      progressColor: Colors.green, 
      backgroundColor: Colors.red,
    );
  }

  AverageScoreIndicator get averageCircularPercentIndicator{
    return AverageScoreIndicator(
      title: "Average Score: ",
      totalScore: '$averageScore/$maxScore',
      percentageScore: percentageScore,
      radius: 80.0, lineWidth: 10.0,
      progressColor: Colors.green,
      backgroundColor: Colors.red,
    );
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
        'Exam answers').doc(widget.answerDirectory);

    // Add user's score to user score field
    await scoreDocRef.update({
      'score': score,
    });

    // final url = Uri.parse('http://localhost:5001/flashcard-6edc2/us-central1/update_exam_score');
    // final response = await http.post(
    //   url,
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     "userId": id,
    //     "score": score,
    //     "directory": widget.questionDirectory
    //   })
    // );
    // print(response);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.blue,
          elevation: 0,
          title:  Align(
            alignment: const Alignment(-0.05,0),
            child: Stack(
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
                  child: Text('Scoring',
                  ),
                ),
              ],
            ),
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
        body: answerScores.isEmpty || (maxScore == 0)
            ? Center(child: CircularProgressIndicator(),) // If data is still being fetched, show loading circle
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment(-0.5,-3),
                child:
                ScoreIndicator(
                  title: 'Your Score: ',
                  totalScore: '$totalScore/$maxScore',
                  percentageScore: percentageScore,
                  radius: 130.0,
                  lineWidth: 15.0,
                  progressColor: Colors.red,
                  backgroundColor: Colors.green
              ),
              ),
              const Spacer(),
              // circularPercentIndicator:
                // Text('Your Score: $totalScore/$totalQuestions', style: TextStyle(fontSize: 24)),
                // Text('Percentage: $percentageScore%', style: TextStyle(fontSize: 24)),
              // EXIT BUTTON
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton.icon(
                  onPressed: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MiniMockFeedBack(
                            title: widget.title,
                            questionDirectory: widget.questionDirectory,
                            answerDirectory: widget.answerDirectory,
                            answerScores: answerScores,
                        ),
                      ),
                    )
                  },
                  icon:Icon(Icons.arrow_forward, color: Colors.white),
                  label: const Text('Feedback', style:TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          )
        )
      ),
    );
  }
}
