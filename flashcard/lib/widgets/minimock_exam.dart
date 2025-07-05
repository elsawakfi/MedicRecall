import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/fullmock_landing.dart';
import 'package:flashcard_x/screens/fullmock_review.dart';
import 'package:flashcard_x/screens/minimock_scoring.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flashcard_x/widgets/ranking_card_ui.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../screens/minimock_landing.dart';
import '../screens/minimock_review.dart';
import '../utils/timer.dart';
import 'drawer_widget.dart';
import 'drawer_widget2.dart';
import 'minimock_help_button.dart';

abstract class MiniMockExam extends StatefulWidget {
  final String title;
  final String shortTitle;
  final String questionDirectory;
  final String answerDirectory;
  final int time;
  const MiniMockExam({super.key, required this.title, required this.shortTitle, required this.questionDirectory, required this.answerDirectory, required this.time});

  @override
  State<MiniMockExam> createState() => MiniMockExamState();
}

class AdaptiveTextSize {
      const AdaptiveTextSize();

      getadaptiveTextSize(BuildContext context, dynamic value) {
    // 720 is medium screen height
        return (value / 720) * MediaQuery.of(context).size.height;
      }
    }

class MiniMockExamState extends State<MiniMockExam> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  int currentQuestion = 0;
  int remainingSeconds = 2700; // Temp fix for late initialisation error

  List<List<bool>> multiChoiceAnswers = []; // For each question store selected options as a list of booleans
  List<List<String>> rankingAnswers = []; // Desktop left set -> Also used for mobile
  List<List<String>> rankingOptions = []; // Desktop right set
  bool rankingMerged = false; // Have the ranking options been merged? -> Occurs on screen sizes < 600 -> Prevents unnecessary computation
  List<Map<String, dynamic>> questions = []; // Store question data with the question number as key e.g Q14
  final ScrollController _scrollController = ScrollController();

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
     _scrollController.dispose(); // Dispose of the scroll controller
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
            if (MediaQuery.of(context).size.width < 600){
              rankingOptions.add(List<String>.generate(doc['options'].length, (index) => ''));
              rankingAnswers.add(List<String>.generate(doc['options'].length, (index) => String.fromCharCode(65 + index)));
              rankingMerged = true;
            }else{
              rankingOptions.add(List<String>.generate(doc['options'].length, (index) => String.fromCharCode(65 + index)));
              rankingAnswers.add(List<String>.generate(doc['options'].length, (index) => ''));
            }
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
        'examAnswers').doc(widget.answerDirectory);

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
    List<List<String>> finalAnswerList = [];
    // finalAnswerList = mergeRankedLists(rankingAnswers, rankingOptions);
    finalAnswerList = rankingAnswers;
    List<List<String>> multiChoiceFormatted = booleanToString(multiChoiceAnswers);
    finalAnswerList.addAll(multiChoiceFormatted);
    updateExamResults(finalAnswerList);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MiniMockScoring(title: widget.title,
        questionDirectory: widget.questionDirectory,
        answerDirectory: widget.answerDirectory
        ),
      ),
    );
  }

  List<List<String>> mergeRankedLists(List<List<String>> answers, options){
    List<List<String>> combinedList = [];
    for (int i = 0; i < answers.length; i++) {
      combinedList.add([]);
      for (int j = 0; j < answers[i].length; j++) {
        if (answers[i][j].isNotEmpty) {
          combinedList[i].add(answers[i][j]); // Keep the non-empty element from the left list
        } else if (options[i][j].isNotEmpty) {
          combinedList[i].add(options[i][j]); // Fill with the non-empty element from the right list
        }
        options[i][j] = '';
      }
    }
    return combinedList;
  }

  void screenSizeCheck(){
    if (MediaQuery.of(context).size.width < 600 && !rankingMerged){
      rankingAnswers = mergeRankedLists(rankingAnswers, rankingOptions);
      rankingMerged = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        child: Scaffold(
          key: ValueKey(widget.title),
          drawer: const DrawMain2(),
          appBar: CustomAppBar(
              title: widget.title,
              mobileTitle: widget.shortTitle,
              actions: [
              LayoutBuilder(
                builder:(context, constraints) {
                double maxScreenWidth = MediaQuery.of(context).size.width;
                double maxPreferredWidth = 960; // 1920/2
                double offset = (maxPreferredWidth < maxScreenWidth) ? -(maxScreenWidth - maxPreferredWidth) / 2 : 0;
              return Transform.translate(
              offset: Offset(offset , 0),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: MediaQuery.of(context).size.width < 600 ? 100 : 210,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: (remainingSeconds <= 600)
                    ? Colors.red.shade400
                    : const Color.fromARGB(255, 222, 221, 222),
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
                      child: (MediaQuery.of(context).size.width >= 600)
                              ? Text('Time Remaining: $_displayTime',
                                  style: TextStyle(
                                    color: (remainingSeconds <= 600)
                                      ? Colors.white
                                      : Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.w500,
                                ))
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time_rounded, color: Colors.black),
                                    SizedBox(width: 8),
                                    Text(_displayTime,
                                      style: TextStyle(
                                      color: (remainingSeconds <= 600)
                                        ? Colors.white
                                        : Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 18.5,
                                      fontWeight: FontWeight.w500,
                                ))])
                  )
          ));})],
          ),
          body: questions.isEmpty || rankingAnswers.isEmpty
              ? Center(child: CircularProgressIndicator()) // If data is still being fetched, show loading circle
              : LayoutBuilder( builder: (context, constraints) {
                double maxScreenWidth = constraints.maxWidth * 0.5;
                double maxPreferredWidth = (maxScreenWidth > 960) ? maxScreenWidth : 960;
                screenSizeCheck();
                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 5,
                              offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      color:   Color.fromARGB(255, 255, 255, 255),
                    ),
                  constraints: BoxConstraints(
                    maxWidth: maxPreferredWidth,
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          child: Row(
                          children: [
                      Align(
                        alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        width: MediaQuery.of(context).size.width < 600 ? 75 : 160,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color.fromARGB(255, 222, 221, 222),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 0,
                              blurRadius: 5,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: TextButton(
                            onPressed: () {
                              setState((){
                                flaggedQuestions[currentQuestion] = !flaggedQuestions[currentQuestion];
                              });
                            },
                            child: (MediaQuery.of(context).size.width < 600)
                                ? Icon(flaggedQuestions[currentQuestion]
                                  ? Icons.flag
                                  : Icons.flag_outlined,
                                  color: Color.fromARGB(255, 0, 0, 0))
                                : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(flaggedQuestions[currentQuestion]
                                        ? Icons.flag
                                        : Icons.flag_outlined,
                                        color: Color.fromARGB(255, 0, 0, 0)),
                                    SizedBox(width: 4),
                                    Text(flaggedQuestions[currentQuestion]
                                        ? 'Flagged'
                                        : 'Flag for review',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ])
                          ))),
                      Spacer(),
                      Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          width: MediaQuery.of(context).size.width < 600 ? 75 : 160,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color.fromARGB(255, 222, 221, 222),
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
                              child: (MediaQuery.of(context).size.width >= 600)
                                ? Text('Question ${currentQuestion+1}/${questions.length}',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ))
                                : Text('${currentQuestion+1}/${questions.length}',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ))
                            )
                      )
                    ])
                )),
            // Display the current question text
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                    children: [
                // Display the current question text
                  Text( questions[currentQuestion]['question'],
                  style: TextStyle(fontSize:AdaptiveTextSize().getadaptiveTextSize(context, 18), color: Colors.black),
                ),
                const SizedBox(height: 16),

                // If the question is a ranking question, display a reorderable list of options
                if (questions[currentQuestion]['type'] == "ranking") ...[
                    Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Answer slots
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: rankingAnswers[currentQuestion].asMap().entries.map<Widget>((entry) {
                                  int optionIndex = entry.key; // List index
                                  String optionLetter = entry.value;
                                  bool optionNotEmpty = rankingAnswers[currentQuestion][optionIndex].isNotEmpty;
                                  String text = (optionNotEmpty) ? '$optionLetter. ${questions[currentQuestion]['options'][optionLetter.codeUnitAt(0) - 65]}'
                                                              : '${optionIndex+1}:';
                                  return DragTarget<String>(
                                    onAcceptWithDetails: (data) => ({
                                        setState(() {
                                          int sourceIndex = int.parse(data.data.split(':')[1]);
                                          if (data.data.startsWith('internal')) {
                                            // Swap data
                                            String temp = rankingAnswers[currentQuestion][optionIndex];
                                            rankingAnswers[currentQuestion][optionIndex] = rankingAnswers[currentQuestion][sourceIndex];
                                            rankingAnswers[currentQuestion][sourceIndex] = temp;
                                          } else if (data.data.startsWith('external')) {
                                            if(optionNotEmpty){
                                              // Return current data to its original option card and accept new data
                                              rankingOptions[currentQuestion][optionLetter.codeUnitAt(0) - 65] = rankingAnswers[currentQuestion][optionIndex];
                                              rankingAnswers[currentQuestion][optionIndex] = rankingOptions[currentQuestion][sourceIndex];
                                              rankingOptions[currentQuestion][sourceIndex] = '';
                                            }else {
                                              // Accept new data and remove the external option
                                              rankingAnswers[currentQuestion][optionIndex] = rankingOptions[currentQuestion][sourceIndex];
                                              rankingOptions[currentQuestion][sourceIndex] = '';
                                            }
                                          }
                                        })
                                    }),
                                    builder: (context, candidateData, rejectedData) {
                                      return (optionNotEmpty)
                                      ? Draggable<String>(
                                          data: 'internal:$optionIndex:$optionLetter',
                                          key: ValueKey(optionLetter),
                                          feedback: Container(
                                              constraints: BoxConstraints(
                                                // Nested if statement -> As user can  change the size of their screen we need to make sure we are using the correct values
                                                maxWidth: (MediaQuery.of(context).size.width < 600) ? MediaQuery.of(context).size.width - 32 : (MediaQuery.of(context).size.width < maxPreferredWidth) ? (MediaQuery.of(context).size.width/2) - 16 : (maxPreferredWidth/2) - 16,
                                                maxHeight: 170,
                                              ),
                                              child: OptionCard(text: text, overflow: false)),
                                          childWhenDragging: OptionCard(text: '${optionIndex+1}:'),
                                          child: OptionCard(text: '${optionIndex+1}: $text')
                                      )
                                      : OptionCard(text: text);
                                    },
                                  );
                              }).toList())
                            ),

                            // DESKTOP VERSION ONLY:
                            (constraints.maxWidth > 600)
                            // Preloaded Options
                            ? Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: rankingOptions[currentQuestion].asMap().entries.map<Widget>((entry) {
                                  int optionIndex = entry.key;
                                  String optionLetter = rankingOptions[currentQuestion][optionIndex];
                                  bool optionNotEmpty = rankingOptions[currentQuestion][optionIndex].isNotEmpty;
                                  String text = (optionNotEmpty) ? '$optionLetter. ${questions[currentQuestion]['options'][optionLetter.codeUnitAt(0) - 65]}'
                                                              : '';
                                  // If the option hasn't already been ranked, load it, otherwise don't reload it
                                  return DragTarget<String>(
                                    onAcceptWithDetails: (data) => ({
                                      setState(() {
                                        List<String> parts = data.data.split(':').toList();
                                        int sourceIndex = int.parse(parts[1]);
                                        String sourceLetter = parts[2];
                                        if (data.data.startsWith('internal')) {
                                          // Reset answer card and return its data to its original option card
                                          rankingOptions[currentQuestion][sourceLetter.codeUnitAt(0) - 65] = rankingAnswers[currentQuestion][sourceIndex];
                                          rankingAnswers[currentQuestion][sourceIndex] = '';
                                          rankingMerged = false;
                                        }
                                      })
                                    }),
                                    builder: (context, candidateData, rejectedData) {
                                      return (optionNotEmpty)
                                        ? Draggable<String>(
                                          data: 'external:$optionIndex:$optionLetter',
                                          key: ValueKey(optionLetter),
                                          feedback: Container(
                                              constraints: BoxConstraints(
                                                maxWidth: (MediaQuery.of(context).size.width < maxPreferredWidth) ? (MediaQuery.of(context).size.width/2) - 16 : (maxPreferredWidth/2) - 16,
                                                maxHeight: 170,
                                              ),
                                              child: OptionCard(text: text, overflow: false)),
                                          childWhenDragging: OptionCard(text: ''),
                                          child: OptionCard(text: text)
                                        )
                                        : OptionCard(text: text);
                                    },
                                  );
                              }).toList())
                            )
                            : SizedBox(),
                          ],
                        ),
                ]
                // If the question is a multiple choice question, display checkboxes
                else if(questions[currentQuestion]['type'] == "multiple choice") ...[
                  //Line below takes the result of the map() and spreads its widgets into the children of Column
                  Column(
                        children: questions[currentQuestion]['options'].asMap().entries.map<Widget>((entry) {
                          int optionIndex = entry.key;
                          String option = entry.value;
                          int questionIndex = currentQuestion - rankingAnswers.length;
                          String optionLetter = options[optionIndex];
                          return CheckboxListTile(
                            key: ValueKey(optionLetter),
                            fillColor: WidgetStateProperty.resolveWith<Color?>(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.black; // Black box when selected
                                }
                                return Colors.transparent; // Default color when unselected
                              },
                            ),
                            checkColor: Colors.white, // White tick inside black box
                            side: const BorderSide(color: Colors.black, width: 1),
                            title: Text('$optionLetter. $option', style: TextStyle(fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 18), color: Colors.black)),
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
                    )],
                    SizedBox(height: 16), // Adds a small space at the very bottom for easier scrolling back to the top
                  ]))
                ),
                // Buttons to change questions
                SizedBox(height: 16),
                LayoutBuilder(builder: (context, constraints) {
                  return Center(
                    child:
                    SizedBox(
                        child:
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child:  MiniMockHelpButton()
                        ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                        width: MediaQuery.of(context).size.width < 600 ? 50 : 160,
                        height: 50,
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
                          onPressed: () async{
                            int? newIndex = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                (widget.questionDirectory.contains('mini-mock'))
                                  ? MiniMockReview(
                                      miniMockWidget: this,
                                      rankingLength: rankingAnswers.length,
                                      multiChoiceLength: multiChoiceAnswers.length,
                                      flaggedQuestions: flaggedQuestions,
                                      displayTime: _displayTime,
                                      remainingSeconds: remainingSeconds,
                                    )
                                  : FullMockReview(
                                      fullMockWidget: this,
                                      rankingLength: rankingAnswers.length,
                                      multiChoiceLength: multiChoiceAnswers.length,
                                      flaggedQuestions: flaggedQuestions,
                                      displayTime: _displayTime,
                                      remainingSeconds: remainingSeconds,
                                    )
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
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove default padding
                            minimumSize: Size.zero,    // Remove minimum size constraints
                          ),
                          child: (MediaQuery.of(context).size.width < 600)
                            ? Icon(Icons.search, color: Colors.black)
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search, color: Colors.black),
                                  SizedBox(width: 4),
                                  Text('Review Page',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 18,
                                    ),
                                  ),
                                ]
                              )
                        )),
                    const Spacer(),
                    if (currentQuestion > 0) //Prevents button being shown if no previous questions available
                      Container(
                          width: MediaQuery.of(context).size.width < 600 ? 50 : 100,
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
                        child:TextButton(
                        onPressed: () {
                          setState(() {
                            currentQuestion--; // Move to previous question
                          });
                           _scrollController.jumpTo(0); // Scroll to the top of the screen
                        },
                        iconAlignment: IconAlignment.start,
                            child: (MediaQuery.of(context).size.width < 600)
                                ? Icon(Icons.arrow_back, color: Colors.black)
                                : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back, color: Colors.black),
                                  SizedBox(width: 4),
                                  Text('Back', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18)),
                                ]
                            )
                      )),
                    const SizedBox(width: 8),
                    if (currentQuestion < questions.length - 1)
                      Container(
                          width: MediaQuery.of(context).size.width < 600 ? 50 : 100,
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
                          setState(() {
                            currentQuestion++; // Move to next question
                          });
                           _scrollController.jumpTo(0); // Scroll to the top of the screen
                        },
                        child: (MediaQuery.of(context).size.width < 600)
                            ? Icon(Icons.arrow_forward, color: Colors.black)
                            : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Next', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward, color: Colors.black),
                            ]
                        )
                      )),
                    if (currentQuestion == questions.length - 1)
                      Container(
                        width: MediaQuery.of(context).size.width < 600 ? 50 : 120,
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
                          onPressed: () async {
                          int? newIndex = await Navigator.push(
                            context,
                              MaterialPageRoute(
                                builder: (context) =>
                                (widget.questionDirectory.contains('mini-mock'))
                                    ? MiniMockReview(
                                  miniMockWidget: this,
                                  rankingLength: rankingAnswers.length,
                                  multiChoiceLength: multiChoiceAnswers.length,
                                  flaggedQuestions: flaggedQuestions,
                                  displayTime: _displayTime,
                                  remainingSeconds: remainingSeconds,
                                )
                                    : FullMockReview(
                                  fullMockWidget: this,
                                  rankingLength: rankingAnswers.length,
                                  multiChoiceLength: multiChoiceAnswers.length,
                                  flaggedQuestions: flaggedQuestions,
                                  displayTime: _displayTime,
                                  remainingSeconds: remainingSeconds,
                                )
                              ));
                            // statement bellow allows for faster page update
                            // Must check for null in case user finishes exam and no value is returned
                            if (newIndex != null && newIndex != currentQuestion){
                              setState(() {
                                currentQuestion = newIndex;
                              });
                            }
                          },
                          child: (MediaQuery.of(context).size.width < 600)
                            ? Icon(Icons.arrow_forward, color: Colors.black)
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Review', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, color: Colors.black),
                                ]
                            )
                        ),
                      ),
                  ])));
                }),
                ]
              ),
            )
          );
        })
      )
    );
  }
}