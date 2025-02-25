import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/screens/minimock_exams.dart';

import '../utils/timer.dart';
import '../widgets/minimock_help_button.dart';

class MiniMockReview extends StatefulWidget {
  final int rankingLength;
  final int multiChoiceLength;
  final dynamic miniMockWidget;
  final List<dynamic> flaggedQuestions; 
  final String displayTime;
  final int remainingSeconds;

  const MiniMockReview({
    super.key,
    required this.miniMockWidget,
    required this.rankingLength,
    required this.multiChoiceLength,
    required this.flaggedQuestions,
    required this.remainingSeconds,
    required this.displayTime,
  });

  @override
  State<MiniMockReview> createState() => MiniMockReviewState();
}

class MiniMockReviewState extends State<MiniMockReview> {
  List<bool> _isOpen = [false, false];
  late int questionLength;

  late TimerController _timerController;
  String _displayTime = '';
  late int remainingSeconds;

  @override
  void initState(){
    super.initState();
    questionLength = widget.rankingLength + widget.multiChoiceLength;
    _displayTime = widget.displayTime;
    remainingSeconds = widget.remainingSeconds;
    _timerController = TimerController(
      startTime: widget.remainingSeconds, //measured in seconds
      onTimeUpdate: (time) {
        setState(() {
          _displayTime = time;
          remainingSeconds -= 1;
        });
      }, onTimerComplete: () {  },
    );
    _timerController.startTimer(); // Start defined timer
  }

  @override
  void dispose() {
    _timerController.stopTimer(); // REQUIRED! Makes sure timer doesn't continue when page is left
    super.dispose();
  }

  // Function to pop this screen and return the value (reduces dry code)
  void _returnToMiniMock(BuildContext context, int questionNumber){
    Navigator.pop(
        context,
        questionNumber // As the question list is an array (starts at index 0), 2 = Q3
    );
  }

  @override
Widget build(BuildContext context) {
  return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result){
    if (!didPop){
      _returnToMiniMock(context, questionLength-1);
    }
  },
    child:Scaffold(
    drawer: const DrawMain(),
    appBar: AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
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
      ]),
      centerTitle: true,
      leading: Builder(
        builder: (context) => GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: const Icon(Icons.menu),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
        width: 210,
        height: 40.31,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color.fromARGB(255, 235, 230, 239),
          boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Time Remaining: $_displayTime',
            style: TextStyle(
              color: Color.fromARGB(255, 98, 86, 139),
              fontSize: 18.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        )),
      ],
    ),
    body: LayoutBuilder( builder: (context, constraints) {
      double maxScreenWidth = constraints.maxWidth * 0.5;
      double maxPreferredWidth = 960; // 1920/2
      return Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxScreenWidth > maxPreferredWidth ? maxScreenWidth : maxPreferredWidth,
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
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
                          style: TextStyle(color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight .bold)),
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
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 1}',
                                      style: TextStyle(color: Colors.white,
                                      fontSize: 20,
        ),
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
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+5);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+5],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
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
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+10);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+10],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
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
                          child: Text('Multiple Choice Questions (Question ${widget.rankingLength + 1} - $questionLength)',
                          style: TextStyle(color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight .bold)),
                          
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
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+13);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+13],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
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
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+19);
                                    },
          
                                    icon: Visibility( visible: widget.flaggedQuestions[index+19],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
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
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+24);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+24],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
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
              Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MiniMockHelpButton(),
                  ),
                  const SizedBox(width: 20),
                   SizedBox(
                    height: 50,
                    width: 120,
                    child:
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        label: Text('Back',  style: TextStyle(color: Colors.white, fontSize: 16)),
                      )
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child:
                      ElevatedButton.icon(
                        onPressed: () {
                          widget.miniMockWidget.examEnd();
                        },
                        icon: Icon(Icons.check_outlined, color: Colors.white),
                        label: Text('Complete Exam',  style: TextStyle(color: Colors.white, fontSize: 16)),
                      )
                  ),
                ],
              )
            ],
        )));
    })));
  }
}