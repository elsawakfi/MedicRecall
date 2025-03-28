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
  List<bool> _isOpen = [true, true];
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

  void _showCompletionDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Complete Mini Mock?"),
        content: const Text("Are you sure you want to submit your answers?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              widget.miniMockWidget.examEnd(); // Proceed with completion
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
              child: const Text(
                'Review',
                style: TextStyle(fontSize: 22,),
            ),
          )],
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
          child: LayoutBuilder(builder: (context, constraints) {
          if (MediaQuery.of(context).size.width >= 600){
          return Text(
            'Time Remaining: $_displayTime',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 18.5,
              fontWeight: FontWeight.w500,
             ));
          } else {
            return Center(
              child: Text('$_displayTime',
                style: TextStyle(
                  color: (remainingSeconds <= 600)
                      ? Colors.white
                      : Color.fromARGB(255, 0, 0, 0),
                  fontSize: 18.5,
                  fontWeight: FontWeight.w500,
                )));
          }
        })),)
],
   ),
    body: LayoutBuilder( builder: (context, constraints) {
      double maxScreenWidth = constraints.maxWidth * 0.5;
      double maxPreferredWidth = 960; // 1920/2

      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
           constraints: BoxConstraints(
          maxWidth: maxScreenWidth > maxPreferredWidth ? maxScreenWidth : maxPreferredWidth,
          minHeight: constraints.maxHeight, // Ensure container takes full height
        ),
          padding: EdgeInsets.all(16),
  
            child: Column( children: [
              Expanded(
          // child: Expanded( //Wrapping in a scrollable widget
          child: SingleChildScrollView(
              child: Align(alignment: Alignment.center,
              child:
      // ExpansionPanelList(
        //child: SingleChildScrollView(
          // child: Column(
          //   children: [
            //  ExpansionPanelList(
          //  mainAxisAlignment: MainAxisAlignment.center,
          //  children: [
           //   Spacer(),
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
                              children: List.generate(3, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index);
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
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+3);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+3],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 4}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+6);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+6],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 7}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+10);
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
                              children: List.generate(3, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+13);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+13],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 14}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+16);
                                    },
          
                                    icon: Visibility( visible: widget.flaggedQuestions[index+17],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 17}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+19);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+20],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 20}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+22);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+22],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 23}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),
                            //SizedBox(height: 10),
                            /**Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(1, (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  width: 80, // Set the desired width
                                  height: 50, // Set the desired height
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _returnToMiniMock(context, index+24);
                                    },
                                    icon: Visibility( visible: widget.flaggedQuestions[index+24],
                                      child: Icon(Icons.flag, color: Colors.black),),
                                    label: Text(
                                      '${index + 25}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 20),
                                    ),
                                  ),
                                ),
                              )),
                            ),**/
                          ],
                        ),
                      ),
                      isExpanded: _isOpen[1],
                    ),
                  ],
                ),),),),
                const SizedBox(height: 20),
              // Spacer(),
              LayoutBuilder(builder: (context, constraints){
                return
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                  alignment: Alignment.centerLeft,
                    child: SizedBox( 
                      height: MediaQuery.of(context).size.width < 600 ? 40 : 50,
                      width: MediaQuery.of(context).size.width < 600 ? 40 : 50,
                      child: MiniMockHelpButton())),
                  const SizedBox(width: 16),
                  Container(
                    height: MediaQuery.of(context).size.width < 600 ? 40 : 50,
                    width: MediaQuery.of(context).size.width < 600 ? 40 : 50,

                    //final double buttonWidth = 56.0; // Define buttonWidth
                   child: FloatingActionButton(
      heroTag: UniqueKey(),
      onPressed: (){
      Navigator.pop(context);
      },
      clipBehavior: Clip.none,
      backgroundColor: const Color.fromARGB(255, 222, 221, 222), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
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
                        label: Text('Complete',  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16)
                        ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Green button color
                            foregroundColor: Colors.white, // Text/Icon color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50), // Rounded corners
                      )
                         )
                  ))
              ]);}),
              
            ],
            ),
             
            ),
            );
})));
}}