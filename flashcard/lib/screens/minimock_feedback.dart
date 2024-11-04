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
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

   @override
  void initState() {
    super.initState();
    fetchAnswerKeys(); // Fetch the questions on initialisation (Needed as this is not to be called in the widget build)
    getUser();
    //fetchUserAnswers(); //Fetch the user's answers from the database
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
      print('Error fetching questions: $error');
    }
  }

  Future<Map<String, dynamic>?> fetchUserAnwsers() async {
  try {
    final CollectionReference users = FirebaseFirestore.instance.collection('users');
    
    // Retrieve the user document based on userID
    QuerySnapshot u = await users.where("userID", isEqualTo: user.uid).get();
    if (u.docs.isEmpty) {
      print("No user document found with the specified userID.");
      return null;
    }
    
    var id = u.docs.last.id;
    DocumentReference examAnswersDocRef = users.doc(id).collection('Exam answers').doc("mini-mock1Answers");
    
    // Fetch the answers document
    DocumentSnapshot docSnapshot = await examAnswersDocRef.get();
    if (docSnapshot.exists) {
      // Return the data in the document as a map
      return docSnapshot.data() as Map<String, dynamic>?;
    } else {
      print("Exam answers document does not exist.");
      return null;
    }
  } catch (e) {
    print("getExamResults error: $e");
    return null;
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

