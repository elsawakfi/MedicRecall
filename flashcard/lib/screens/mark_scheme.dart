import 'dart:core';

import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'ms_questions.dart';


// first we define our mark scheme info class - DONE
// this is the struct for what we pass to the mark scheme display
// this needs to be taken from the firestore for the mark scheme


class MSInfo {
  final String index;
  final String answer;
  final String explanation;
  final String situation;
  final String action;
  final String type;
  final String id;
  final String bool;

  const MSInfo(this.index, this.answer, this.explanation, this.type, this.id,this.situation,this.action,this.bool);


  @override
  String toString() {
    return "{ index: $index, answer: $answer, explanation: $explanation, type: $type, id: $id, bool: $bool}";

  }
}

class UMS extends StatelessWidget {
  const UMS({Key? key}) : super(key: key);

/*
Have the first place be an explanation of the mark scheme, leave blank for rn

3 buttons:
  - Rating (q1-114)
  - Multiple choice (q1-20)
  - Ranking (q1-37)

 for each type of question
 - Answer to the question
 - Explanation of the answer
 - Comment section
 - situation
 - action

 */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawMain(),
      appBar: AppBar(
        // backgroundColor: Colors.blue,
          elevation: 0,
          title: Align(
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
                  child: const Text('Unofficial Mark Scheme',
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
              )),
    ),
      body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                          Container(
                              width: double.infinity,
                              height: 200,
                              margin: const EdgeInsets.only(
                                  bottom: 10.0, left: 30.0, right: 30.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: const Center(
                                  child: SingleChildScrollView(
                                    // allow for scrolling if its a long question
                                    child: Center(
                                        child: Text(

                                            "This is our exclusive unofficial mark scheme for the Pearson Vue past paper which was released by the UKFPO but removed from view in 2023 when the Situational Judgement Test was scrapped. Approximately half of the questions overlap with the UKFPO sample paper, which was released with official rationales. Therefore, the official rationales are provided where available, and for the remaining questions, our unofficial mark scheme is used. \n Disclaimer: Our unofficial mark scheme is less reliable than the official content. Therefore, use the unofficial rationales as a basis for reflection and discussion. There is a comments section where users can debate rationales for answering questions and engage with our community.",
                                            //get the question from the map
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ))),
                                  ))),
                          const SizedBox(height: 40),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.grey,
                              side: const BorderSide(color: Colors.green, width: 2),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(100))),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MSI(
                                        qtype: "rating",
                                      )));
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Text('Rating Questions (Q1 - 114)',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(height: 40),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.grey,
                              side: const BorderSide(color: Colors.green, width: 2),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(100))),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MSI(
                                        qtype: "multiple choice",
                                      )));
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Text('Multiple Choice Questions (Q1 - 20)',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.grey,
                              side: const BorderSide(color: Colors.green, width: 2),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(100))),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MSI(
                                        qtype: "ranking",
                                      )));
                            },
                            key: const ValueKey('Rating Questions'),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Text('Ranking Questions (Q1 - 37)',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ],
                      ))),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey,
                  side: const BorderSide(color: Colors.green, width: 2),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                ),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, HomePage.id),
                child: const Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text('Flashcards',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w500)),
                ),
              )
            ],
          )),
    );
  }
}