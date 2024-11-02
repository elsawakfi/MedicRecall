import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_x/widgets/pageLayout.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';

class MiniMockFeedback extends StatefulWidget {
  const MiniMockFeedback({super.key});

  @override
  State<MiniMockFeedback> createState() => MinimockFeedbackState();
}

class MinimockFeedbackState extends State<MiniMockFeedback> {

  List<Map<String, dynamic>> answerKeys = [];

   @override
  void initState() {
    super.initState();
    fetchAnswerKeys(); // Fetch the questions on initialisation (Needed as this is not to be called in the widget build)
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

  //need to query for the user's answers stored in firebase

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      drawer: const DrawMain(),
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
                    child: const Text('FeedBack',
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
                ))));
       
  }
              //compare the answers keys and the user's answers and provided
              //format tbd
  }

