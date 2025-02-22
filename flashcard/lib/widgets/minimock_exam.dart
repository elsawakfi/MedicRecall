import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/minimock_scoring.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import '../screens/minimock_review.dart';
import '../utils/timer.dart';
import 'drawer_widget.dart';
import 'minimock_help_button.dart';

abstract class MiniMockExam extends StatefulWidget {
  final String title;
  final String questionDirectory;
  final String answerDirectory;
  final int time;
  const MiniMockExam({super.key, required this.title, required this.questionDirectory, required this.answerDirectory, required this.time});

  @override
  State<MiniMockExam> createState() => MiniMockExamState();
}

class MiniMockExamState extends State<MiniMockExam> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  int currentQuestion = 0;
  int remainingSeconds = 2700; // Temp fix for late initialisation error
  List<List<bool>> multiChoiceAnswers = []; // For each question store selected options as a list of booleans
  List<List<String>> rankingAnswers = [];
  List<Map<String, dynamic>> questions = []; // Store question data with the question number as key e.g Q14
  List<bool> flaggedQuestions = [];
  final options = 'ABCDEFGH';

  late TimerController _timerController;
  String _displayTime = ''; // Initial time display

  @override
  void initState() {
    super.initState();
    getUser();
    getQuestions(); // Fetch the questions on initialisation (Needed as this is not to be called in the widget build)
    // Below defines the exam timer and what happens on each tick / end of exam
    remainingSeconds = widget.time;
    _timerController = TimerController(
      startTime: widget.time, //measured in seconds
      onTimeUpdate: (time) {
        setState(() {
          _displayTime = time;
          remainingSeconds -= 1;

          //   // Parse time string "MM:SS" to seconds
          // List<String> parts = time.split(":");
          // int minutes = int.parse(parts[0]);
          // int seconds = int.parse(parts[1]);
          // remainingSeconds = (minutes * 60) + seconds;// Update display every second
        });
      },
      onTimerComplete: () {
        examEnd();
      },
    );
    _timerController.startTimer(); // Start defined timer
  }

  @override
  void dispose() {
    _timerController.stopTimer(); // REQUIRED! Makes sure timer doesn't continue when page is left
    super.dispose();
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
  // Fetch mini-mock questions from firestore and store as a list of maps
  Future<List<Map<String, dynamic>>> queryQuestionData() async {
    //questions are not properly stored in order on firestore so order via a field instead
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(widget.questionDirectory).orderBy('questionNumber').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Get the question data from the firestore
  Future<void> getQuestions() async {
    List<Map<String, dynamic>> fetchedQuestions = await queryQuestionData();
    // Initialise questions and answer lists based on the queried data
    setState(() {
      questions = fetchedQuestions;
      flaggedQuestions = List<bool>.filled(questions.length, false);

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
        'Exam answers').doc(widget.answerDirectory);

    // Add user's answers to user answer document
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

  void examEnd(){
    _timerController.stopTimer();
    List<List<String>> multiChoiceFormatted = booleanToString(multiChoiceAnswers);
    List<List<String>> finalAnswerList = [];
    finalAnswerList.addAll(rankingAnswers);
    finalAnswerList.addAll(multiChoiceFormatted);
    updateExamResults(finalAnswerList);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MiniMockScoring(title: widget.title, questionDirectory: widget.questionDirectory, answerDirectory: widget.answerDirectory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        child: Scaffold(
          key: ValueKey(widget.title),
          drawer: const DrawMain(),
          appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                              child: Text(widget.title)
                          ),
                        ],
                      )
                  ]
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
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 160,
                  height: 40.31,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color:  (remainingSeconds <= 600)
                    ? Colors.red.shade400
                    : const Color.fromARGB(255, 235, 230, 239),
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
                      child: Text('Time Remaining: $_displayTime',
                        style: TextStyle(
                          color: (remainingSeconds <= 600)
                              ? Colors.white
                              : Color.fromARGB(255, 98, 86, 139),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                )
              ],
          ),
          body: questions.isEmpty
              ? Center(child: CircularProgressIndicator()) // If data is still being fetched, show loading circle
              : Padding( //Else load the data
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display question flag and timer widgets:
                Row(
                    children: [
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
                        child:TextButton.icon(
                            label: Text('Flag for review',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 98, 86, 139),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () {
                              setState((){
                                flaggedQuestions[currentQuestion] = !flaggedQuestions[currentQuestion];
                              });
                            },
                            icon: Icon(
                              flaggedQuestions[currentQuestion]
                                  ? Icons.flag
                                  : Icons.flag_outlined,
                              color: Color.fromARGB(255, 98, 86, 139),
                            )
                        ),
                      ),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                      ),
                    ]
                ),

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
                      buildDefaultDragHandles: false,
                      proxyDecorator:  (Widget child, int index, Animation<double> animation) {
                        return Material(
                          color: Colors.transparent,
                          child: child,
                        );
                      },
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
                              elevation: 3,
                              color: Color.fromARGB(255, 235, 230, 239),
                                child: ListTile(
                                  title: Text('${optionIndex+1}:   $optionLetter. $option', style: TextStyle(color: Color.fromARGB(255, 98, 86, 139), fontSize: 20)),
                                  trailing: Icon(Icons.drag_handle , color: Color.fromARGB(255, 98, 86, 139), size: 30),
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
                                return CheckboxListTile(
                                  fillColor: WidgetStateProperty.resolveWith<Color?>(
                                        (states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return Theme.of(context).textTheme.bodyMedium?.color; // Color when the checkbox is checked
                                      }
                                      return Colors.transparent; // Transparent when unchecked
                                    },
                                  ),
                                  checkColor: Theme.of(context).scaffoldBackgroundColor,
                                  title: Text('$optionLetter. $option', style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyMedium?.color)),
                                  value: multiChoiceAnswers[questionIndex][optionIndex],
                                  onChanged: (value) {
                                    int checkedCount = multiChoiceAnswers[questionIndex].where((element) => element).length;
                                    if (checkedCount < 3 || value == false) {
                                      setState(() {
                                        multiChoiceAnswers[questionIndex][optionIndex] = value!;
                                      });
                                    }
                                  },
                                  enableFeedback: false,
                                  controlAffinity: ListTileControlAffinity.leading,
                                );
                              }).toList()
                          )
                      )
                  )
                ],
                // Buttons to change questions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: MiniMockHelpButton(),
                    ),
                    const Spacer(),
                    if (currentQuestion > 0) //Prevents button being shown if no previous questions available
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            currentQuestion--; // Move to previous question
                          });
                        },
                        icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 98, 86, 139)),
                        label: Text('Previous', style: TextStyle(color: Color.fromARGB(255, 98, 86, 139), fontSize: 16)),
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
                        icon: Icon(Icons.arrow_forward, color: Color.fromARGB(255, 98, 86, 139)),
                        label: Text('Next', style: TextStyle(color: Color.fromARGB(255, 98, 86, 139), fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 235, 230, 239),
                        ),
                      ),
                    if (currentQuestion == questions.length - 1)
                      ElevatedButton.icon(
                        onPressed: () async {
                          // On pressed load new page and wait for a returned value
                          int? newIndex = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MiniMockReview(miniMockWidget: this, rankingLength: rankingAnswers.length, multiChoiceLength: multiChoiceAnswers.length, flaggedQuestions: flaggedQuestions,),
                            ),
                          );
                          // statement bellow allows for faster page update
                          // Must check for null in case user finishes exam and no value is returned
                          if (newIndex != null && newIndex != currentQuestion){
                            setState(() {
                              currentQuestion = newIndex;
                            });
                          }

                        },
                        icon: Icon(Icons.arrow_forward, color: Color.fromARGB(255, 98, 86, 139)),
                        label: Text('Review', style: TextStyle(color: Color.fromARGB(255, 98, 86, 139), fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 235, 230, 239),
                        ),
                      ),
                  ],
                ),
              ]
            ),
          ),

        )
    );
  }
}