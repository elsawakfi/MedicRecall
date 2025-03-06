import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/screens/minimock_exams.dart';


class FullMockRules extends StatefulWidget {
  const FullMockRules({super.key});

  @override
  State<FullMockRules> createState() => FullMockRulesState();
}

class FullMockRulesState extends State<FullMockRules> {
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
                    child: const Text('Full Mock Exam 1',
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
       body: SafeArea(
  child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: const Text(
              'MedicRecall Full Mock 1 Exam Instructions: \n',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          //const SizedBox(height: 10),
          Center(child: 
          SizedBox(
            width: 800,
            child: Text(
              'In this test, you will be presented with typical scenarios that Foundation Year Two (FY2) Doctors '
              'encounter, and you will be asked questions about dealing with them. When answering questions, '
              'please consider yourself to be an FY2 Doctor unless stated otherwise and answer based on what you '
              'should do in each scenario.\n',
              style: TextStyle(fontSize: 21),
              textAlign: TextAlign.center,
            ),
          )),
    
          Center(
            child: 
            SizedBox(
              width: 800,
              child: 
            Text(
              'The paper is divided into two parts: ',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          )),
          SizedBox(
            height: 20,
          ),
          Center(
            child: 
            SizedBox(
              width: 800,
              child: 
           Text.rich( 
              TextSpan(
                text: 'Part 1: Ranking Questions (Q1-29).',
                style: TextStyle(fontSize: 21, decoration:TextDecoration.underline,),
                children: <TextSpan>[
                  TextSpan(text:' In this part you are presented with scenarios followed by a number of possible options. For each scenario select the 3 options which together are the most '  
                    'appropriate to the least appropriate given the circumstances described. \n',
                    style: TextStyle(fontSize: 21,decoration:TextDecoration.none)),
                ],),
            ),
          )),
           Center(
            child: 
            SizedBox(
              width: 800,
              child: 
           Text.rich( 
              TextSpan(
                text: 'Part 2: Multiple Choice Questions (Q30-50).',
                style: TextStyle(fontSize: 21, decoration:TextDecoration.underline,),
                children: <TextSpan>[
                  TextSpan(text:' In this part you are presented with scenarios followed by a number of possible options. For each scenario select the 3 options which together are the most '
              'appropriate responses to the situation given the circumstances described. \n',
                    style: TextStyle(fontSize: 21,decoration:TextDecoration.none)),
                ],),
            ),
          )),
          Center(
            child: 
            SizedBox(
              width: 800,
              child: 
          Text(
              'The paper contains 50 questions in total. You have 95 minutes to complete the exam. This is to '
              'simulate the amount of time you will have to complete the exam on the day. \n',
              style: TextStyle(fontSize: 21),
            ),
          )),
           Center(
                child:
                SizedBox(
                  height: 50,
                  width: 500,
                  child:  ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FullMockExam(),
                      ),
                    );
                  },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.green
                    ), child: Text('Begin Exam', style: TextStyle(color:Colors.white, fontSize: 20)),
                  )
                )
           )
        ],
      ),
    ),
  ),
));

  }
}

