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

 Widget _buildQuestionButton(int questionNumber) {
  bool isFlagged = widget.flaggedQuestions.length > questionNumber 
                   && widget.flaggedQuestions[questionNumber] == true;
  return ElevatedButton.icon(
    onPressed: () => _returnToFullMock(context, questionNumber),
    icon: isFlagged 
      ? const Icon(Icons.flag, color: Colors.black) 
      : const SizedBox.shrink(),
    label: Text('${questionNumber + 1}',
    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
    fontSize: 20,),
  ),
  
   style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Increase the padding for a larger button
      minimumSize: Size(100, 30), // Make the button larger with a minimum size (width, height)
    alignment: Alignment.center,
   ) );
}
  



  @override
  void initState(){
    super.initState();
    questionLength = widget.rankingLength + widget.multiChoiceLength;
    _isOpen = List.generate(2, (index) => false);
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
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) {
        _returnToFullMock(context, questionLength - 1);
      }
    },
    child: Scaffold(
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
          color: Color.fromARGB(255, 222, 221, 222),
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
              color: Color.fromARGB(255, 0, 0, 0),
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
          decoration: 
          BoxDecoration(
            boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                  )
                  ],
            color:   Color.fromARGB(255, 255, 255, 255),
            ),
          
          constraints: BoxConstraints(
            maxWidth: maxScreenWidth > maxPreferredWidth ? maxScreenWidth : maxPreferredWidth,
          ),
          padding: EdgeInsets.all(16),
             child: SizedBox(
              height: constraints.maxHeight,
              child: Column(children: [
                Expanded(child: 
                SingleChildScrollView(
                  child: Align(alignment: Alignment.center,
                  child: Column(children: [
                  ExpansionPanelList(
                    elevation: 1,
                    expandIconColor: Theme.of(context).textTheme.bodyMedium?.color,
                    expandedHeaderPadding: EdgeInsets.all(4.0),
                    expansionCallback: (i, isOpen) {
                      setState(() {
                        _isOpen[i] = !_isOpen[i];
                      });
                    },
        
                  children: [
                    // Ranking Questions Panel
                    ExpansionPanel(
                      isExpanded: _isOpen[0],
                      canTapOnHeader: true,
                      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                      headerBuilder: (context, isOpen) => ListTile(
                        title: Text('Ranking Questions (Question 1 - ${widget.rankingLength})'),
                      ),
                      body: Center(
                      child: Wrap(
                         alignment: WrapAlignment.center,
                           spacing: 6.0,
                         runSpacing: 10.0,
                        children: List.generate(
                          widget.rankingLength,
                          (index) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: _buildQuestionButton(index),
                            ),
                          ),
                        ),
                      ),
                    ),

                        ExpansionPanel(
                          isExpanded: _isOpen[1],
                          canTapOnHeader: true,
                          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                          headerBuilder: (context, isOpen) => ListTile(
                            title: Text(
                              'Multiple Choice Questions (Question ${widget.rankingLength + 1} - $questionLength)'),
                              ),
                    body: Center(
                      child: Wrap(
                         alignment: WrapAlignment.center,
                         spacing: 6.0,
                         runSpacing: 10.0,
                      children: List.generate(
                        widget.multiChoiceLength,
                        (index) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          //  child: _buildQuestionButton(index),
                          child: ElevatedButton.icon(
                            onPressed: () => _returnToFullMock(context, widget.rankingLength + index),
                            icon: Visibility(
                              visible: (widget.flaggedQuestions.length > widget.rankingLength + index) 
                                      ? widget.flaggedQuestions[widget.rankingLength + index] 
                                      : false,
                              child: const Icon(Icons.flag, color: Colors.black),
                              
                            ),
                            label: Text('${widget.rankingLength + index + 1}',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 20,),
                          ),
                           style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Increase the padding for a larger button
                              minimumSize: Size(100, 30), // Make the button larger with a minimum size (width, height)
                            alignment: Alignment.center,
                            ),
  
                          ),
                          
                        ),
                      ),
                    ),
                  ))],
                ),
              ],
            ),
          ),
        ),
      ),
                      
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Align(
                  //   alignment: Alignment.centerLeft,
                    const MiniMockHelpButton(),
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
                      icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
                      label: Text('Back',  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 222, 221, 222),
                      ),
                    ),
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
            ),
            ],
            ),
            ),
      ),);
})));}}
