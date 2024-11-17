import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/page_layout.dart';
import 'package:collection/collection.dart';

class MiniMockFeedBack extends StatefulWidget {
  const MiniMockFeedBack({super.key});

  @override
  State<MiniMockFeedBack> createState() => MinimockFeedbackState();
}

class MinimockFeedbackState extends State<MiniMockFeedBack> {
  int currentQuestion = 0;
  List<Map<String, dynamic>> answerKeys = [];
  Map<String, dynamic> userAnswers = {};
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

   @override
  void initState() {
    super.initState();
    fetchAnswerKeys(); // Fetch the questions on initialisation (Needed as this is not to be called in the widget build)
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


  Future<List<Map<String, dynamic>>> getAnswerData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('mini-mock-1').orderBy('questionNumber').get(); //questions are not properly stored in order on firestore so order via a field instead
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> fetchAnswerKeys() async {
    try {
      // Fetch the question data (this simulates your Future)
      List<Map<String, dynamic>> fetchedAnswers = await getAnswerData();
      // Initialise questions and selectedOptions based on fetched data
      setState(() {
        answerKeys = fetchedAnswers;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching questions: $error');
      }
    }
  }

  Future<Map<String, dynamic>> getUserAnswerData() async {
       QuerySnapshot snapshot = await FirebaseFirestore.instance
           .collection('users')
           .where('userID', isEqualTo: user.uid)
           .get();
       var id = snapshot.docs.last.id;
       DocumentSnapshot<
           Map<String, dynamic>> userAnswers = await FirebaseFirestore.instance
           .collection('users').doc(id).collection('Exam answers').doc(
           "mini-mock1Answers").get();
       Map<String, dynamic> userAnswerMap = userAnswers.get('answers');
       return userAnswerMap;

  }

  Future<void> fetchUserAnswers() async {
    try {
      // Fetch the question data (this simulates your Future)
      Map<String, dynamic> fetchedUserAnswers = await getUserAnswerData();

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
    final listEquality = ListEquality();
    return PageLayout( //Widget made to prevent necessary repetition
      titleText: 'Mini-Mock Exam 1',
      body: answerKeys.isEmpty && userAnswers.isEmpty
          ? Center(child: CircularProgressIndicator()) // If data is still being fetched, show loading circle
          : Padding( //Else load the data

        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the current question text
            Text(
              answerKeys[currentQuestion]['question'],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            //display the selected answers and the correct answers
            if (answerKeys[currentQuestion]['type'] == "ranking")
              (listEquality.equals(answerKeys[currentQuestion]['correct_answers'], userAnswers[(currentQuestion+1).toString()]))
                  ? Text("Correct: ${userAnswers[(currentQuestion+1).toString()]}", style: TextStyle(color: Colors.green,fontSize: 18))
                  : Text("Incorrect: ${userAnswers[(currentQuestion+1).toString()]}", style: TextStyle(color: Colors.red,fontSize: 19)),

            if (answerKeys[currentQuestion]['type'] == "multiple choice")
              (UnorderedIterableEquality().equals(answerKeys[currentQuestion]['correct_answers'], userAnswers[(currentQuestion+1).toString()]))
                  ? Text("Correct: ${userAnswers[(currentQuestion+1).toString()]}", style: TextStyle(color: Colors.green,fontSize: 18))
                  : Text("Incorrect: ${userAnswers[(currentQuestion+1).toString()]}", style: TextStyle(color: Colors.red,fontSize: 18)),
            Text("Correct Answer: ${answerKeys[currentQuestion]['correct_answers']}", style: TextStyle(color: Colors.white,fontSize: 18)),

            SizedBox(height: 20),
              Expanded(
               //Display the explanation of the question
                child: Text(
                answerKeys[currentQuestion]['explanation'],
                style: TextStyle(fontSize: 18),
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
                if (currentQuestion < answerKeys.length - 1)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        currentQuestion++; // Move to next question
                      });
                    },
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    label: Text('Next', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }      
  }

