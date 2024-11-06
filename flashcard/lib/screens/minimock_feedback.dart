import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/pageLayout.dart';
import 'package:flashcard_x/screens/minimock_feedback.dart';

class MiniMockFeedBack extends StatefulWidget {
  const MiniMockFeedBack({super.key});

  @override
  State<MiniMockFeedBack> createState() => MinimockFeedbackState();
}

class MinimockFeedbackState extends State<MiniMockFeedBack> {
  int currentQuestion = 0;
  List<Map<String, dynamic>> answerKeys = [];
   List<Map<String, dynamic>> userAnswers = [];
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

   @override
  void initState() {
    super.initState();
    fetchAnswerKeys(); // Fetch the questions on initialisation (Needed as this is not to be called in the widget build)
    getUser();
    fetchUserAnwsers(); //Fetch the user's answers from the database
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

  Future<List<Map<String, dynamic>>> getUserAnswerData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').where('userId', isEqualTo: user.uid).get(); //questions are not properly stored in order on firestore so order via a field instead
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
      print('Error fetching questions: $error');
    }
  }

  Future<void> fetchUserAnwsers() async {
    try {
      // Fetch the question data (this simulates your Future)
      List<Map<String, dynamic>> fetchedUserAnswers = await getUserAnswerData();

      // Initialise questions and selectedOptions based on fetched data
      setState(() {
        userAnswers = fetchedUserAnswers;
      });
    } catch (error) {
      print('Error fetching questions: $error');
    }
  
}





  //need to query for the user's answers stored in firebase

  @override
  Widget build(BuildContext context) {
    return PageLayout( //Widget made to prevent necessary repetition
      titleText: 'Mini-Mock Exam 1',
      body: answerKeys.isEmpty
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
            //display the selectd answers and the correct answers
            Row(
              children: [
                //rendering logic for the comparison of answers
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  if (answerKeys[currentQuestion]['type'] == "ranking") ...[
                    if (userAnswers != null &&
                       userAnswers[currentQuestion] != null &&
                      answerKeys[currentQuestion]['correct_answers'] == userAnswers[currentQuestion]['mini-mock1Answers']) 
                        Text("Correct Answer", style: TextStyle(color: Colors.green)),
                    if (userAnswers != null &&
                        userAnswers[currentQuestion] != null &&
                        answerKeys[currentQuestion]['correct_answers'] != userAnswers[currentQuestion]['mini-mock1Answers']) 
                        Text("Incorrect Answer", style: TextStyle(color: Colors.red)),


                  ],
                  if (answerKeys[currentQuestion]['type'] == "multiple choice") ...[
                     if (userAnswers != null &&
                       userAnswers[currentQuestion] != null &&
                      answerKeys[currentQuestion]['correct_answers'].length == userAnswers[currentQuestion]['mini-mock1Answers'].length) 
                        Text("Correct Answer", style: TextStyle(color: Colors.green)),
                    if (userAnswers != null &&
                        userAnswers[currentQuestion] != null &&
                        answerKeys[currentQuestion]['correct_answers'].length != userAnswers[currentQuestion]['mini-mock1Answers']) 
                        Text("Incorrect Answer", style: TextStyle(color: Colors.red)),
                  ],
                ],
              ),
                SizedBox(width: 20),
                //displays the correct answers
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: answerKeys[currentQuestion]['correct_answers'].map((letter) => Text(
                    letter,
                    style: TextStyle(fontSize: 18),
                  )).toList()
                ),
              ],

            ),
            SizedBox(height: 20),
             //Display the explanation of the question
            Text(
              answerKeys[currentQuestion]['explanation'],
              style: TextStyle(fontSize: 18),
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

