import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/pageLayout.dart';
import 'package:flashcard_x/screens/minimock_feedback.dart';


class MiniMockExam1 extends StatefulWidget {
  const MiniMockExam1({super.key});

  @override
  State<MiniMockExam1> createState() => MiniMockExam1State();
}

class MiniMockExam1State extends State<MiniMockExam1> {
  int currentQuestion = 0;
  List<List<bool>> multiChoiceAnswers = []; // For each question store selected options as a list of booleans
  List<List<String>> rankingAnswers = [];
  List<Map<String, dynamic>> questions = []; // Store question data with the question number as key e.g Q14

  @override
  void initState() {
    super.initState();
    getQuestions(); // Fetch the questions on initialisation (Needed as this is not to be called in the widget build)
  }

  // Fetch mini-mock-1 questions from firestore and store as a list of maps
  Future<List<Map<String, dynamic>>> queryQuestionData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('mini-mock-1').orderBy('questionNumber').get(); //questions are not properly stored in order on firestore so order via a field instead
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
            // Add a list of ordered letter 'A', 'B', ... based on quesiton index
            rankingAnswers.add(List<String>.generate(doc['options'].length, (index) => String.fromCharCode(65 + index)));
            break;
          case 'multiple choice':
            // Add a list of booleans
            multiChoiceAnswers.add(List<bool>.filled(doc['options'].length, false));
            break;
          default:
        }
      }
    });
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
                          title: Text('$optionLetter. $option', style: TextStyle(color: Colors.blueGrey, fontSize: 20)),
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
                child: Column(
                  children: questions[currentQuestion]['options'].asMap().entries.map<Widget>((entry) {
                    int optionIndex = entry.key;
                    String option = entry.value;
                    int questionIndex = currentQuestion - rankingAnswers.length;
                    String optionLetter = String.fromCharCode(65 + optionIndex);
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MiniMockFeedback(),
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