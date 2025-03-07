import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
// import 'package:flashcard_x/screens/minimock_exams.dart';

import '../utils/timer.dart';
import '../widgets/minimock_help_button.dart';

class FullMockReview extends StatefulWidget {
  final int rankingLength;
  final int multiChoiceLength;
  final dynamic fullMockWidget;
  final List<dynamic> flaggedQuestions; 
  final String displayTime;
  final int remainingSeconds;

  const FullMockReview({
    super.key,
    required this.fullMockWidget,
    required this.rankingLength,
    required this.multiChoiceLength,
    required this.flaggedQuestions,
    required this.remainingSeconds,
    required this.displayTime,
  });

  @override
  State<FullMockReview> createState() => FullMockReviewState();
}

class FullMockReviewState extends State<FullMockReview> {
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
  void _returnToFullMock(BuildContext context, int questionNumber){
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
      _returnToFullMock(context, questionLength-1);
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
              dividerColor: Colors.transparent,
              expandIconColor: Theme.of(context).textTheme.bodyMedium?.color,
              expandedHeaderPadding: EdgeInsets.all(4.0),
              expansionCallback: (i, isOpen) {
                setState(() {
                  _isOpen[i] = !_isOpen[i];
                });
              },
                children: [
                    ExpansionPanel(
                      canTapOnHeader: true,
                      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                      headerBuilder: (context, isOpen) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Ranking Questions (Question 1 - ${widget.rankingLength})',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
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
                                      _returnToFullMock(context, index);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 1}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
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
                                      _returnToFullMock(context, index+5);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+5],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 6}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
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
                                      _returnToFullMock(context, index+10);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+10],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 11}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
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
                                      _returnToFullMock(context, index+10);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+15],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 16}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
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
                                      _returnToFullMock(context, index+20);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+20],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 21}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
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
                      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                      headerBuilder: (context, isOpen) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Multiple Choice Questions (Question ${widget.rankingLength + 1} - $questionLength)',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
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
                                      _returnToFullMock(context, index+25);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+25],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 26}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
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
                                      _returnToFullMock(context, index+30);
                                    },
          
                                    icon: Visibility( visible: widget.flaggedQuestions[index+30],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 31}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
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
                                      _returnToFullMock(context, index+40);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+40],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 41}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
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
                                      _returnToFullMock(context, index+45);
                                    },
          
                                    icon: Visibility( visible: widget.flaggedQuestions[index+45],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 46}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
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
                  const SizedBox(width: 16),
                  Container(
                    width: 160,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color.fromARGB(255, 235, 230, 239),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: const Offset(0, 6), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 98, 86, 139)),
                      label: Text('Back',  style: TextStyle(color: Color.fromARGB(255, 98, 86, 139), fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 235, 230, 239),
                      ),
                    )
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child:
                      ElevatedButton.icon(
                        onPressed: () {
                          widget.fullMockWidget.examEnd();
                        },
                        icon: Icon(Icons.check_outlined, color: Theme.of(context).textTheme.bodyMedium?.color),
                        label: Text('Complete Exam',  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16)),
                      )
                  ),
                ],
              )
            ],
        )));
    })));
  }
}