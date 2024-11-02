import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/pageLayout.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';

class MiniMockFeedback extends StatefulWidget {
  const MiniMockFeedback({super.key});

  @override
  State<MiniMockFeedback> createState() => MinimockFeedbackState();
}

class MinimockFeedbackState extends State<MiniMockFeedback> {
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
                    child: const Text('Mini-Mock Exam 2',
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
}
