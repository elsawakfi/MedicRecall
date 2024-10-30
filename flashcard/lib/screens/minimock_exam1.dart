import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';


class MiniMockExam1 extends StatefulWidget {
  const MiniMockExam1({Key? key}) : super(key: key);

  @override
  State<MiniMockExam1> createState() => MiniMockExam1State();
}

class MiniMockExam1State extends State<MiniMockExam1> {
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
            // centerTitle: true,
            // leading: Builder(
            //     builder: (context) => GestureDetector(
            //       onTap: () => Scaffold.of(context).openDrawer(),
            //       child: const Icon(
            //         Icons.menu,
                  ),
                ))));
                // ElevatedButton(
                //   onPressed: (){

                // },
                // child: ,)
  }
}