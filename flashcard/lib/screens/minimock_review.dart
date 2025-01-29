import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/screens/minimock_exams.dart';

class MiniMockReview extends StatefulWidget {
  final int rankingLength;
  final int multiChoiceLength;
  final dynamic miniMockWidget;

  const MiniMockReview({
    super.key,
    required this.miniMockWidget,
    required this.rankingLength,
    required this.multiChoiceLength,
  });

  @override
  State<MiniMockReview> createState() => MiniMockReviewState();
}

class MiniMockReviewState extends State<MiniMockReview> {
  List<bool> _isOpen = [false, false];
  @override
Widget build(BuildContext context) {
  return Scaffold(
    drawer: const DrawMain(),
    appBar: AppBar(
      elevation: 0,
      title: Align(
        alignment: const Alignment(-0.05, 0),
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
              child: const Text('Review'),
            ),
          ],
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: const Icon(Icons.menu),
        ),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
            ExpansionPanelList(
              elevation: 1,
              expandedHeaderPadding: EdgeInsets.all(4.0),
              expansionCallback: (i, isOpen) {
                setState(() {
                  _isOpen[i] = !_isOpen[i];
                });
              },
                children: [
                    ExpansionPanel(
                      canTapOnHeader: true,
                      backgroundColor: Colors.white,
                      headerBuilder: (context, isOpen) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Ranking Questions (Question 1 - ${widget.rankingLength})',
                          style: TextStyle(color: Colors.black)),
                        );
                      },
                      body: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 100, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const MiniMockExam1(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(color: Colors.white,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 100, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const MiniMockExam1(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '${index + 6}',
                                      style: TextStyle(color: Colors.white,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 100, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const MiniMockExam1(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '${index + 11}',
                                      style: TextStyle(color: Colors.white,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),
                      isExpanded: _isOpen[0],
                    ),
                    ExpansionPanel(
                      canTapOnHeader: true,
                      backgroundColor: Colors.white,
                      headerBuilder: (context, isOpen) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Multiple Choice Questions (Question ${widget.rankingLength + 1} - ${widget.multiChoiceLength + widget.rankingLength})',
                          style: TextStyle(color: Colors.black)),
                          
                        );
                      },
                      body: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 100, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const MiniMockExam1(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '${index + 14}',
                                      style: TextStyle(color: Colors.white,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 100, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const MiniMockExam1(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '${index + 20}',
                                      style: TextStyle(color: Colors.white,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(1, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 100, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const MiniMockExam1(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '${index + 25}',
                                      style: TextStyle(color: Colors.white,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),
                      isExpanded: _isOpen[1],
                    ),
                  ],
                ),
              ],
            ),   
        ],
      ),
    ),
    floatingActionButton:SizedBox(
      height: 50,
      width: 200,
      child: 
        FloatingActionButton.extended(onPressed: () {
          widget.miniMockWidget.examEnd();
      }, label: Text('Complete Exam',  style: TextStyle(color: Colors.white, fontSize: 16)))),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
}
}