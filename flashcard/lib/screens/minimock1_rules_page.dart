import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/screens/minimock_exams.dart';


class MiniMock1Rules extends StatefulWidget {
  const MiniMock1Rules({super.key});

  @override
  State<MiniMock1Rules> createState() => MiniMock1RulesState();
}

class MiniMock1RulesState extends State<MiniMock1Rules> {
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
                    child: const Text('Mini-Mock Exam 1',
                    
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
        /**body:
        Padding(padding: 
        const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'MedicRecall Mini-Mock 1 Exam Instructions: \n',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              )
            ),
            const SizedBox(height: 10),
            Container( 
              margin: const EdgeInsets.only(left: 5, right: 5),
              width: 300,
              child: Text(
              'In this test, you will be presented with typical scenarios that Foundation Year Two (FY2) Doctors '
              'encounter , and you will be asked questions about dealing with them. When answering questions, '
              'please consider yourself to be a FY2 Doctor unless stated otherwise and answer based on what you '
              'should do in each scenario.\n',
              style: TextStyle(fontSize: 21),
              textAlign: TextAlign.center,
            ),),
            const Text(
              'The paper is divided into two parts: ',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),

            Text.rich( 
              TextSpan(
                text: 'Part 1: Rating Questions (Q1-13).',
                style: TextStyle(fontSize: 21, decoration:TextDecoration.underline,),
                children: <TextSpan>[
                  TextSpan(text:' In this part you are presented with scenarios followed by a number of possible options. For each scenario you are required to rank each option in order from the most '
                    'appropriate to the least appropriate given the circumstances described in the scenario. \n',
                    style: TextStyle(fontSize: 21,decoration:TextDecoration.none)),
                ],),
            ),
            Text.rich( 
              TextSpan(
                text: 'Part 1: Ranking Questions (Q14-25).',
                style: TextStyle(fontSize: 21, decoration:TextDecoration.underline,),
                children: <TextSpan>[
                  TextSpan(text:' In this part you are presented with scenarios followed by a number of possible options. For each scenario select the 3 options which together are the most '
              'appropriate responses to the situation given the circumstances described. \n',
                    style: TextStyle(fontSize: 21,decoration:TextDecoration.none)),
                ],),
            ),
          
            const Text(
              'The paper contains 25 questions in total. You have 45 minutes to complete the exam. This is to '
              'simulate the amount of time you will have to complete the exam on the day. \n',
              style: TextStyle(fontSize: 21),
            ),
              Center(
                child: ElevatedButton.icon(
                  onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MiniMockExam1(),
                      ),
                    );
                  },
                  // icon: Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text('Begin', style: TextStyle(color: Colors.white, fontSize: 18)),
                ))
          ])
        )**/
       body: SafeArea(
  child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: const Text(
              'MedicRecall Mini-Mock 1 Exam Instructions: \n',
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
                text: 'Part 1: Ranking Questions (Q1-13).',
                style: TextStyle(fontSize: 21, decoration:TextDecoration.underline,),
                children: <TextSpan>[
                  TextSpan(text:' In this part you are presented with scenarios followed by a number of possible options. For each scenario you are required to rank each option in order from the most '
                    'appropriate to the least appropriate given the circumstances described in the scenario. \n',
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
                text: 'Part 2: Rating Questions (Q14-25).',
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
              'The paper contains 25 questions in total. You have 45 minutes to complete the exam. This is to '
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
                        builder: (context) => const MiniMockExam1(),
                      ),
                    );
                  },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.green
                    ),
                    child: Text('Begin Exam', style: TextStyle(color:Colors.white, fontSize: 20))
                )))
          
        ],
      ),
    ),
  ),
));

  }
}

