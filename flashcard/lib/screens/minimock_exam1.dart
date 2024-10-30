import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/pageLayout.dart';


class MiniMockExam1 extends StatefulWidget {
  const MiniMockExam1({Key? key}) : super(key: key);

  @override
  State<MiniMockExam1> createState() => MiniMockExam1State();
}

class MiniMockExam1State extends State<MiniMockExam1> {
  int currentQuestion = 0;
  List<List<bool>> selectedOptions = []; //For each question store selected options as a list of booleans
  List<Map<String, dynamic>> questions = []; // Store question data with the question number as key e.g Q14

  @override
  void initState() {
    super.initState();
    fetchQuestions(); // Fetch the questions on initialisation (Needed as this is not to be called in the widget build)
  }

  // Fetch mini-mock-1 questions from firestore and store as a list of maps
  Future<List<Map<String, dynamic>>> getQuestionData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('mini-mock-1').orderBy('questionNumber').get(); //questions are not properly stored in order on firestore so order via a field instead
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Fetch questions and initialise selectedOptions to be loaded
  Future<void> fetchQuestions() async {
    try {
      // Fetch the question data (this simulates your Future)
      List<Map<String, dynamic>> fetchedQuestions = await getQuestionData();

      // Initialise questions and selectedOptions based on fetched data
      setState(() {
        questions = fetchedQuestions;
        //Generates questions.length number of lists (each with length relative to the question they represent), initialised with falses
        selectedOptions = List.generate(questions.length, (index) {
          return List<bool>.filled(questions[index]['options'].length, false);
        });
      });
    } catch (error) {
      print('Error fetching questions: $error');
    }
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
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),

            // Display options text with checkboxes
            //Line below takes the result of the map() and spreads its widgets into the children of Column
            ...questions[currentQuestion]['options'].asMap().entries.map((entry) {
              int optionIndex = entry.key;
              String option = entry.value;
              String optionLetter = String.fromCharCode(65 + optionIndex);

              return ListTile(
                title: Text('$optionLetter. $option', style: TextStyle(color: Colors.white)),
                leading: Checkbox(
                  value: selectedOptions[currentQuestion][optionIndex],
                  onChanged: (value) {
                    setState(() {
                      selectedOptions[currentQuestion][optionIndex] = value!;
                    });
                  },
                  side: BorderSide( color: Colors.white),
                ),
              );
            }).toList(),

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
                if (currentQuestion < questions.length - 1)
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