import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/page_layout.dart';
import 'package:flashcard_x/screens/minimock_feedback.dart';


class MiniMockExam1 extends StatefulWidget {
  const MiniMockExam1({super.key});

  @override
  State<MiniMockExam1> createState() => MiniMockExam1State();
}

class MiniMockExam1State extends State<MiniMockExam1> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

  int currentQuestion = 0;
  List<List<bool>> multiChoiceAnswers = []; // For each question store selected options as a list of booleans
  List<List<String>> rankingAnswers = [];
  List<Map<String, dynamic>> questions = []; // Store question data with the question number as key e.g Q14
  final options = 'ABCDEFGH';

  @override
  void initState() {
    super.initState();
    getUser();
    getQuestions(); // Fetch the questions on initialisation (Needed as this is not to be called in the widget build)
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
  // Fetch mini-mock-1 questions from firestore and store as a list of maps
  Future<List<Map<String, dynamic>>> queryQuestionData() async {
    //questions are not properly stored in order on firestore so order via a field instead
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('mini-mock-1').orderBy('questionNumber').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Get the question data from the firestore
  Future<void> getQuestions() async {
    List<Map<String, dynamic>> fetchedQuestions = await queryQuestionData();
    // Initialise questions and answer lists based on the queried data
    setState(() {
      questions = fetchedQuestions;

      for (var doc in questions){
        String type = doc['type'];
        switch (type) {
          case 'ranking':
            String modifiedQuestion = doc['question'].replaceFirst('Rank', '\nRank');
            doc['question'] = modifiedQuestion; // Add a newline between the question (could store a newline in the firebase itself but this allows for easier customisation)
            // Add a list of ordered letter 'A', 'B', ... based on quesiton index
            rankingAnswers.add(List<String>.generate(doc['options'].length, (index) => String.fromCharCode(65 + index)));
            break;
          case 'multiple choice':
            String modifiedQuestion = doc['question'].replaceFirst('Choose', '\nChoose');
            doc['question'] = modifiedQuestion;
            // Add a list of booleans
            multiChoiceAnswers.add(List<bool>.filled(doc['options'].length, false));
            break;
          default:
        }
      }
    });
  }

  Future<void> updateExamResults(List<List<String>> answers) async {
    Map<String, List<String>> answerMap = {
      for (int i = 0; i < questions.length; i++) '${i+1}' : answers[i]
    };
    final CollectionReference users = FirebaseFirestore.instance.collection(
        'users');
    QuerySnapshot u =
    await users.where("userID", isEqualTo: user.uid).get();
    var id = u.docs.last.id;
    DocumentReference userDocRef = FirebaseFirestore.instance.collection(
        'users').doc(id);
    DocumentReference examAnswersDocRef = userDocRef.collection(
        'Exam answers').doc("mini-mock1Answers");

    await examAnswersDocRef.set({
      'answers': answerMap,
      'timestamp': FieldValue.serverTimestamp(),
    });

  }

  List<List<String>> booleanToString(List<List<bool>> multiChoice) {
    List<List<String>> multiChoiceLetters = [];
    for (int i = 0; i < multiChoice.length; i++){
      List<String> letters = [
        for (int j = 0; j < multiChoice[i].length; j++)
        if (multiChoice[i][j] ) options[j]
      ];
      multiChoiceLetters.add(letters);
    }
    return multiChoiceLetters;
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout( //Widget made to prevent necessary repetition
      titleText: 'Mini-Mock Exam 1',
      body: questions.isEmpty
          ? Center(child: CircularProgressIndicator()) // If data is still being fetched, show loading circle
          : Padding( //Else load the data
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the current question text
            Text(
              questions[currentQuestion]['question'],
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),

            // If the question is a ranking question, display a reorderable list of options
            if (questions[currentQuestion]['type'] == "ranking") ...[
              Expanded(
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if(newIndex > oldIndex) newIndex --; // Adjust the list based on movement of item
                      // Update position of option in answer list
                      final ranking = rankingAnswers[currentQuestion].removeAt(oldIndex);
                      rankingAnswers[currentQuestion].insert(newIndex, ranking);
                      // Update position of option text in question list
                      final option = questions[currentQuestion]['options'].removeAt(oldIndex);
                      questions[currentQuestion]['options'].insert(newIndex, option);
                    });
                  },
                  // Create children for the reorderable list using questions
                  children: questions[currentQuestion]['options'].asMap().entries.map<Widget>((entry) {
                    int optionIndex = entry.key;
                    String option = entry.value;
                    String optionLetter = rankingAnswers[currentQuestion][optionIndex];
                    return ReorderableDragStartListener(
                      key: ValueKey(option),
                      index: optionIndex,
                      child: Card(
                        child: ListTile(
                          title: Text('${optionIndex+1}:   $optionLetter. $option', style: TextStyle(color: Colors.blueGrey, fontSize: 20)),
                          trailing: Icon(Icons.drag_handle , color: Colors.blueGrey),
                        )
                      )
                    );
                  }).toList(),
                ),
              )
            ]
            // If the question is a multiple choice question, display checkboxes
            else if(questions[currentQuestion]['type'] == "multiple choice") ...[
              //Line below takes the result of the map() and spreads its widgets into the children of Column
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: questions[currentQuestion]['options'].asMap().entries.map<Widget>((entry) {
                      int optionIndex = entry.key;
                      String option = entry.value;
                      int questionIndex = currentQuestion - rankingAnswers.length;
                      String optionLetter = options[optionIndex];
                      return ListTile(
                        title: Text('$optionLetter. $option', style: TextStyle(color: Colors.white, fontSize: 16)),
                        leading: Checkbox(
                          value: multiChoiceAnswers[questionIndex][optionIndex],
                          onChanged: (value) {
                            int checkedCount = multiChoiceAnswers[questionIndex].where((element) => element).length;
                            if (checkedCount < 3 || value == false) {
                              setState(() {
                                multiChoiceAnswers[questionIndex][optionIndex] = value!;
                              });
                            }
                          },
                          side: BorderSide( color: Colors.white),
                        ),
                      );
                    }).toList()
                  )
                )
              )
            ],

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
                    label: Text('Previous', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                    label: Text('Next', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                if (currentQuestion == questions.length - 1)
                  ElevatedButton.icon(
                    onPressed: () {
                      List<List<String>> multiChoiceFormatted = booleanToString(multiChoiceAnswers);
                      List<List<String>> finalAnswerList = [];
                      finalAnswerList.addAll(rankingAnswers);
                      finalAnswerList.addAll(multiChoiceFormatted);
                      updateExamResults(finalAnswerList);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MiniMockFeedBack(),
                        ),
                      );
                    },
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    label: Text('Finish', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}