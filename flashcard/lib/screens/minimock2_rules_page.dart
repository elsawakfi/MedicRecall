import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flashcard_x/screens/minimock_exams.dart';


class MiniMock2Rules extends StatefulWidget {
  const MiniMock2Rules({super.key});

  @override
  State<MiniMock2Rules> createState() => MiniMock2RulesState();
}

class AdaptiveTextSize {
      const AdaptiveTextSize();

      getadaptiveTextSize(BuildContext context, dynamic value) {
    // 720 is medium screen height
        return (value / 720) * MediaQuery.of(context).size.height;
      }
    } 

class MiniMock2RulesState extends State<MiniMock2Rules> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawMain(),
      appBar: CustomAppBar(title: "Mini-Mock Exam 2"),
       body:  LayoutBuilder(builder: (context, constraints) { 
        double maxScreenWidth = constraints.maxWidth * 0.5;
        double maxPreferredWidth = (maxScreenWidth > 960) ? maxScreenWidth : 960; 
        return Center(
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
                    minHeight: constraints.maxHeight
                  ),
                   padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth > 600 ? 16 : 8,  // Adaptive padding
          vertical: 16,
        ),

    child:  SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child:  Text(
              'MedicRecall Mini-Mock 1 Exam Instructions: \n',
              style: TextStyle(fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 27), fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
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
              style: TextStyle(fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 18), color: Colors.black),
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
              style: TextStyle(fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 23), fontWeight: FontWeight.bold, color: Colors.black),
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
                text: 'Part 1: Ranking Questions (Q1-13).',
                style: TextStyle(fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 18), decoration:TextDecoration.underline, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text:' In this part you are presented with scenarios followed by a number of possible options. For each scenario you are required to rank each option in order from the most '
                    'appropriate to the least appropriate given the circumstances described in the scenario. \n',
                    style: TextStyle(fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 18),decoration:TextDecoration.none, color: Colors.black)),
                ]),
             textAlign: TextAlign.center,
            ),
          )),
           Center(
            child: 
            SizedBox(
              width: 800,
              child: 
           Text.rich( 
              TextSpan(
                text: 'Part 2: Rating Questions (Q14-25).',
                style: TextStyle(fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 18), decoration:TextDecoration.underline, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text:' In this part you are presented with scenarios followed by a number of possible options. For each scenario select the 3 options which together are the most '
              'appropriate responses to the situation given the circumstances described. \n',
                    style: TextStyle(fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 18),decoration:TextDecoration.none, color: Colors.black)),
                ]),
             textAlign: TextAlign.center,
            ),
          )),
          Center(
            child: 
            SizedBox(
              width: 800,
              child: 
          Text(
              'The paper contains 25 questions in total. You have 45 minutes to complete the exam. This is to '
              'simulate the amount of time you will have to complete the exam on the day. \n',
              style: TextStyle(fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 18), color: Colors.black),
            textAlign: TextAlign.center,
            ),
          )),
          SizedBox(
            height: 20),
           Center(
                child:
                SizedBox(
                  height: 50,
                  width: 500,
                  child:  ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MiniMockExam2(),
                      ),
                    );
                  },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.green
                    ), child: Text('Begin Exam', style: TextStyle(color:Colors.white, fontSize:AdaptiveTextSize().getadaptiveTextSize(context, 20),)),
                  )
                )
           )
        ],
      ),
    ),
  ),
       );
}));
 }
}

