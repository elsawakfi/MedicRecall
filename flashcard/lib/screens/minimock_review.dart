import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
// import 'package:flashcard_x/screens/minimock_exams.dart';

import '../utils/timer.dart';
import '../widgets/app_bar.dart';
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

  Widget _buildQuestionButton(int questionNumber) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * 0.2; // 20% of screen width
    double buttonHeight = 50;

    bool isFlagged = widget.flaggedQuestions.length > questionNumber &&
        widget.flaggedQuestions[questionNumber] == true;
    return SizedBox(
      width: buttonWidth.clamp(60, 100), // Ensure fixed width
      height: buttonHeight, // Ensure fixed height
      child: ElevatedButton(
        onPressed: () => _returnToMiniMock(context, questionNumber),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          padding: EdgeInsets.all(8),
          alignment: Alignment.center,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isFlagged) Icon(Icons.flag, color: Colors.black),
            if (isFlagged) SizedBox(width: 4),
            Text(
              '${questionNumber + 1}',
              style: TextStyle(
                // color: Theme.of(context).textTheme.bodyMedium?.color,
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Flagging Widget for the Multiple Choice Questions
  Widget _buildMultipleChoiceButton(int questionNumber) {
    bool isFlagged = widget.flaggedQuestions.length >
            widget.rankingLength + questionNumber &&
        widget.flaggedQuestions[widget.rankingLength + questionNumber] == true;
    return ElevatedButton(
      onPressed: () =>
          _returnToMiniMock(context, widget.rankingLength + questionNumber),
      style: ElevatedButton.styleFrom(
        padding: isFlagged
            ? EdgeInsets.symmetric(vertical: 15, horizontal: 24)
            : EdgeInsets.symmetric(vertical: 15, horizontal: 35),
        minimumSize: Size(60, 60),
        alignment: Alignment.center,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isFlagged) Icon(Icons.flag, color: Colors.black),
          if (isFlagged) SizedBox(width: 4),
          Text(
            '${widget.rankingLength + questionNumber + 1}',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
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
      },
      onTimerComplete: () {},
    );
    _timerController.startTimer(); // Start defined timer
  }

  @override
  void dispose() {
    _timerController
        .stopTimer(); // REQUIRED! Makes sure timer doesn't continue when page is left
    super.dispose();
  }

  // Function to pop this screen and return the value (reduces dry code)
  void _returnToMiniMock(BuildContext context, int questionNumber) {
    Navigator.pop(context,
        questionNumber // As the question list is an array (starts at index 0), 2 = Q3
        );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Complete Mini Mock?",
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            "Are you sure you want to submit your answers?",
            style: TextStyle(color: Colors.black),
          ),
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
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _returnToMiniMock(context, questionLength - 1);
          }
        },
        child: Scaffold(
            drawer: const DrawMain(),
            appBar: CustomAppBar(
              title: 'Review Page',
              mobileTitle: 'Review',
              actions: [
                LayoutBuilder(builder: (context, constraints) {
                  double maxScreenWidth = MediaQuery.of(context).size.width;
                  double maxPreferredWidth = 960; // 1920/2
                  double offset = (maxPreferredWidth < maxScreenWidth)
                      ? -(maxScreenWidth - maxPreferredWidth) / 2
                      : 0;
                  return Transform.translate(
                      offset: Offset(offset, 0),
                      child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: MediaQuery.of(context).size.width < 600
                              ? 100
                              : 210,
                          height: 40.31,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Color.fromARGB(255, 222, 221, 222),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
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
                                          Icon(Icons.access_time_rounded,
                                              color: Colors.black),
                                          SizedBox(width: 8),
                                          Text(_displayTime,
                                              style: TextStyle(
                                                color: (remainingSeconds <= 600)
                                                    ? Colors.white
                                                    : Color.fromARGB(
                                                        255, 0, 0, 0),
                                                fontSize: 18.5,
                                                fontWeight: FontWeight.w500,
                                              ))
                                        ]))));
                })
              ],
            ),
            body: LayoutBuilder(builder: (context, constraints) {
              double maxScreenWidth = constraints.maxWidth * 0.7;
              double maxPreferredWidth = 960; // 1920/2

              return Center(
                  child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          )
                        ],
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: maxScreenWidth > maxPreferredWidth
                            ? maxScreenWidth
                            : maxPreferredWidth,
                        minHeight: constraints
                            .maxHeight, // Ensure container takes full height
                      ),
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: Column(children: [
                          Expanded(
                              child: SingleChildScrollView(
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: ExpansionPanelList(
                                          elevation: 1,
                                          expandIconColor: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                          expandedHeaderPadding:
                                              EdgeInsets.all(4.0),
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
                                              backgroundColor: Theme.of(context)
                                                  .appBarTheme
                                                  .backgroundColor,
                                              headerBuilder:
                                                  (context, isOpen) => ListTile(
                                                title: Text(
                                                    'Ranking Questions (Question 1 - ${widget.rankingLength})'),
                                              ),
                                              body: Center(
                                                child: Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  spacing:
                                                      10.0, //Spacing between buttons
                                                  runSpacing:
                                                      10.0, //Vertical spacing between rows
                                                  children: List.generate(
                                                    widget.rankingLength,
                                                    (index) => Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child:
                                                          _buildQuestionButton(
                                                        index,
                                                      ), // Build button for multiple-choice questions
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Multiple Choice Questions Panel
                                            ExpansionPanel(
                                                isExpanded: _isOpen[1],
                                                canTapOnHeader: true,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .appBarTheme
                                                        .backgroundColor,
                                                headerBuilder:
                                                    (context, isOpen) =>
                                                        ListTile(
                                                          title: Text(
                                                              'Multiple Choice Questions (Question ${widget.rankingLength + 1} - $questionLength)'),
                                                        ),
                                                body: Center(
                                                    child: Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  spacing: 10.0,
                                                  runSpacing: 10.0,
                                                  children: List.generate(
                                                    widget.multiChoiceLength,
                                                    (index) => Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: _buildQuestionButton(
                                                          index +
                                                              widget
                                                                  .rankingLength), // Use the new method
                                                    ),
                                                  ),
                                                )))
                                          ])))),
                          const SizedBox(height: 20),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: MiniMockHelpButton())),
                                const SizedBox(width: 16),
                                SizedBox(
                                  height: 50,
                                  width: 50,

                                  //final double buttonWidth = 56.0; // Define buttonWidth
                                  child: FloatingActionButton(
                                    heroTag: UniqueKey(),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    clipBehavior: Clip.none,
                                    backgroundColor: const Color.fromARGB(
                                        255, 222, 221, 222),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(Icons.arrow_back,
                                        color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                    height:
                                        MediaQuery.of(context).size.width < 600
                                            ? 40
                                            : 50,
                                    width: 150,
                                    child: ElevatedButton.icon(
                                        onPressed: () {
                                          _showCompletionDialog(context);
                                        },
                                        icon: Icon(Icons.check_outlined,
                                            color: Colors.white),
                                        label: Text('Complete',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors
                                                .green, // Green button color
                                            foregroundColor:
                                                Colors.white, // Text/Icon color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      50), // Rounded corners
                                            ))))
                              ])
                        ]),
                      )));
            })));
  }
}
