import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
// import 'package:flashcard_x/screens/minimock_exams.dart';

import '../utils/timer.dart';
import '../widgets/minimock_help_button.dart';

class AdaptiveTextSize {
      const AdaptiveTextSize();

      getadaptiveTextSize(BuildContext context, dynamic value) {
    // 720 is medium screen height
        return (value / 720) * MediaQuery.of(context).size.height;
      }
    }

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
  List<bool> _isOpen = [true, true];
  late int questionLength;

  late TimerController _timerController;
  String _displayTime = '';
  late int remainingSeconds;

  Widget _buildMultipleChoiceButton(int questionNumber) {
    bool isFlagged = widget.flaggedQuestions.length > widget.rankingLength + questionNumber &&
                     widget.flaggedQuestions[widget.rankingLength + questionNumber] == true;
    return ElevatedButton.icon(
      onPressed: () => _returnToFullMock(context, widget.rankingLength + questionNumber),
      icon: isFlagged ? Icon(Icons.flag, color: const Color.fromARGB(255, 0, 0, 0)) : Container(),
      label: Text(
        '${widget.rankingLength + questionNumber + 1}',
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 20,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: isFlagged
          ? EdgeInsets.symmetric(vertical: 16, horizontal: 17) // Smaller padding for flagged questions
          : EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Larger padding for non-flagged questions
        minimumSize: Size(90, 30),
        alignment: Alignment.center,
      ),
    );
  }

 Widget _buildQuestionButton(int questionNumber) {
  bool isFlagged = widget.flaggedQuestions.length > questionNumber 
                   && widget.flaggedQuestions[questionNumber] == true;
  return ElevatedButton.icon(
    onPressed: () => _returnToFullMock(context, questionNumber),
    icon: isFlagged ? Icon(Icons.flag, color: const Color.fromARGB(255, 0, 0, 0)) : Container(),
    label: Text(
      '${questionNumber + 1}',
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 20,
      ),
    ),
   style: ElevatedButton.styleFrom(
     padding: isFlagged
       ? EdgeInsets.symmetric(vertical: 16, horizontal: 17) // Smaller padding for flagged questions
          : EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Larger padding for non-flagged questions
      minimumSize: Size(90, 30), // Make the button larger with a minimum size (width, height)
      alignment: Alignment.center,
   ) );
}
  



  @override
  void initState(){
    super.initState();
    questionLength = widget.rankingLength + widget.multiChoiceLength;
    // _isOpen = List.generate(2, (index) => true);
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

  void _showCompletionDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Complete Full-sized Mock?"),
        content: const Text("Are you sure you want to submit your answers?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              widget.fullMockWidget.examEnd(); // Proceed with completion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("Confirm"),
          ),
        ],
      );
    },
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
    appBar: CustomAppBar(
      title: 'Review Page',
      mobileTitle: 'Review',
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: MediaQuery.of(context).size.width < 600 ? 120 : 210,
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
            child: (MediaQuery.of(context).size.width >= 600)
                ? Text('Time Remaining: $_displayTime',
                style: TextStyle(
                  color: (remainingSeconds <= 600)
                      ? Colors.white
                      : Color.fromARGB(255, 0, 0, 0),
                  fontSize: 18.5,
                  fontWeight: FontWeight.w500,
                ))
                : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded, color: Colors.black),
                  SizedBox(width: 8),
                  Text(_displayTime,
                      style: TextStyle(
                        color: (remainingSeconds <= 600)
                            ? Colors.white
                            : Color.fromARGB(255, 0, 0, 0),
                        fontSize: 18.5,
                        fontWeight: FontWeight.w500,
                      ))])
          ))
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
              )],
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
                  child: 
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
                            child: _buildQuestionButton(index), // Build button for multiple-choice questions
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
                            child: _buildMultipleChoiceButton(index), // Use the new method
                          ),
                        ),
                      
                  )))]
                )))),
              const SizedBox(height: 20),
              LayoutBuilder(builder: (context, constraints) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed from end
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          child: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0), size: AdaptiveTextSize().getadaptiveTextSize(context, 20)),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: MediaQuery.of(context).size.width < 600 ? 40 : 50,
                        width: 150,
                        child:
                          ElevatedButton.icon(
                            onPressed: () {
                              _showCompletionDialog(context);
                            },
                            icon: Icon(Icons.check_outlined, color: Theme.of(context).textTheme.bodyMedium?.color),
                            label: Text('Complete',  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Green button color
                              foregroundColor: Colors.white, // Text/Icon color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50), // Rounded corners
                          ))))
                      ]);
              })
              ]))
        ));
    })));
}}