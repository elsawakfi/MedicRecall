import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/pageLayout.dart';


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
      //Generates questions.length number of lists (each with length relative to the question they represent), initialised with falses
      multiChoiceAnswers = List.generate(questions.length, (index) {
        return List<bool>.filled(questions[index]['options'].length, false);
      });
      //var rankingQuestions = questions.where((question) => question['type'] == "ranking").toList();
      rankingAnswers = List.generate(questions.length, (index) {
        return List<String>.from(questions[index]['options']);
      });
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
                      final option = rankingAnswers[currentQuestion].removeAt(oldIndex);
                      rankingAnswers[currentQuestion].insert(newIndex, option);
                    });
                  },
                  // Create children for the reorderable list using questions
                  children: rankingAnswers[currentQuestion].asMap().entries.map<Widget>((entry) {
                    // int optionIndex = entry.key;
                    String option = entry.value;
                    int originalIndex = questions[currentQuestion]['options'].indexOf(option);
                    String optionLetter = String.fromCharCode(65 + originalIndex);
                    return ListTile(
                      key: ValueKey(option),
                      title: Text('$optionLetter. $option', style: TextStyle(color: Colors.white, fontSize: 20)),
                      trailing: Icon(Icons.drag_handle),
                    );
                  }).toList(),
                ),
              )
            ]
            // If the question is a multiple choice question, display checkboxes
            else if(questions[currentQuestion]['type'] == "multiple choice") ...[
              //Line below takes the result of the map() and spreads its widgets into the children of Column
              ...questions[currentQuestion]['options'].asMap().entries.map((entry) {
                int optionIndex = entry.key;
                String option = entry.value;
                String optionLetter = String.fromCharCode(65 + optionIndex);
                return ListTile(
                  title: Text('$optionLetter. $option', style: TextStyle(color: Colors.white, fontSize: 16)),
                  leading: Checkbox(
                    value: multiChoiceAnswers[currentQuestion][optionIndex],
                    onChanged: (value) {
                      setState(() {
                        multiChoiceAnswers[currentQuestion][optionIndex] = value!;
                      });
                    },
                    side: BorderSide( color: Colors.white),
                  ),
                );
              })
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}