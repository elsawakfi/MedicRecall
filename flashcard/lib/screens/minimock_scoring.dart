import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/minimock_feedback.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  List<Map<String, dynamic>> questions = [];
  Map<String, dynamic> userAnswers = {};
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

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
                    child: Text('${widget.title}: Scoring',
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
                
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton.icon(
                          onPressed: () => {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MiniMockFeedBack(
                                    title: widget.title,
                                    questionDirectory: widget.questionDirectory,
                                    answerDirectory: widget.answerDirectory)
                              ),
                            )
                          },
                          // icon:Icon(Icons.arrow_forward, color: Colors.white),
                          label: const Text('Complete Scoring', style:TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ]
                  )
                )
        ),
    );
  }
}
