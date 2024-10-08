import 'package:flashcard_x/screens/ms_comments.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


import 'mark_scheme.dart';
import 'ms_questions.dart';

void msiSinglePrinter(MSInfo msinfo) {
  //maybe just use list of strings instead of msis
  if (kDebugMode) {
    print("begin");
  }
  if (kDebugMode) {
    print(msinfo.toString());
  }
  if (kDebugMode) {
    print("end");
  }
}

/*
Future<String> getmsID(String question) async{
  return ("sample msID");
}


 */

class MSSingle extends StatefulWidget {
  final MSInfo msiSingle;
  final List<Map<String, dynamic>> allQuestions; // all ms entries on fb
  final List<int> typeQuestions;
  final int currentIndex;

  const MSSingle({Key? key, required this.msiSingle, required this.allQuestions, required this.typeQuestions, required this.currentIndex}) : super(key: key);

  @override

  State<MSSingle> createState() => _MSSingleState();
}

class _MSSingleState extends State<MSSingle> {
  bool areSectionsVisible = false;
  @override
  initState() {
    // init state runs before build method thanks to addPostFrameCallback

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //questions = []; // this is so we dont re-add questions to the listbuilder
      msiSinglePrinter(widget.msiSingle);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    //Fetches data from Firebase if contains "official" then displays official if contains "un" then displays unofficial
    bool isOfficial = widget.msiSingle.bool.contains('official');
    bool isUnofficial = widget.msiSingle.bool.contains('un');

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Align(
            alignment: const Alignment(-0.06, 0),
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
                  child: const Text("Mark Scheme"),
                ),
              ],
            ),
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        body: SafeArea(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              children: [

                //Displays logic
                if (isOfficial) const LabelWidget(labelText: 'Official'),
                if (isUnofficial) const LabelWidget(labelText: 'Unofficial'),

                Row(
                  children: const [
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),

                const SizedBox(height: 40),
                Container(
                    width: double.infinity,
                    height: 120,
                    margin: const EdgeInsets.only(
                        bottom: 10.0, left: 30.0, right: 30.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                        child: SingleChildScrollView(
                      // allow for scrolling if its a long question
                      child: Center(
                          child: Text(widget.msiSingle.situation,

                              //get the question from the map
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              )
                          )
                      ),
                    )
                    )
                ),
                const SizedBox(height: 40),

                Container(
                    width: double.infinity,
                    height: 70,
                    margin: const EdgeInsets.only(
                        bottom: 10.0, left: 30.0, right: 30.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                        child: SingleChildScrollView(
                          // allow for scrolling if its a long question
                          child: Center(
                              child: Text(widget.msiSingle.action,
                                  //get the question from the map
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  )
                              )
                          ),
                        )
                    )
                ),
                const SizedBox(height: 40),
                Builder(
                  builder: (BuildContext context) {
                  return Visibility(
                  visible: areSectionsVisible,
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    margin: const EdgeInsets.only(
                        bottom: 10.0, left: 30.0, right: 30.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                        child: SingleChildScrollView(
                      // allow for scrolling if its a long question
                      child: Center(
                          child: Text(widget.msiSingle.answer,
                              //get the question from the map
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ))),
                    )
                    )
                    ),
                );
    }
    ),
                const SizedBox(height: 40),
                Builder(
                  builder: (BuildContext context) {
                  return Visibility(
                  visible: areSectionsVisible,
                  child: Container(
            width: double.infinity,
            height: 150,
            margin: const EdgeInsets.only(
                bottom: 10.0, left: 30.0, right: 30.0),
            padding: const EdgeInsets.symmetric(
                horizontal: 30.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(10.0),
            ),
                child: Center(
                child: SingleChildScrollView(
                  // allow for scrolling if its a long question
                  child: Center(
                      child: Text(widget.msiSingle.explanation,
                          //get the question from the map
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ))),
                )
            )
        ),
      );
    }
    ),
                const SizedBox(height: 40),
              ],
            )),
          ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        areSectionsVisible = !areSectionsVisible;
                      });
                    },
                    child: Text(areSectionsVisible ? 'Hide Answer' : 'Show Answer',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column( children: [Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(onPressed: () { //PREVIOUS
                          var atStart = widget.currentIndex - 1 == -1;
                          if (kDebugMode) {
                            print(widget.currentIndex);
                          }
                          if (kDebugMode) {
                            print(typeQuestions.length);
                          }
                          var index = widget.currentIndex - 1;
                          SchedulerBinding.instance.addPostFrameCallback((_) { //Schedule a callback for after the current frame updates to prevent double-popping if the user clicks the button too fast
                            Navigator.pop(context);
                          });
                          if(!atStart){
                            Navigator.pushReplacement( //need to use this to use the PageRouteBuilder
                                context,
                                PageRouteBuilder( //allows us to specify the duration of transition animations
                                    pageBuilder: (context, animation1, animation2) => MSSingle(
                                      msiSingle: generateMSInfo(
                                          typeQuestions[index], index),
                                      allQuestions: allQuestions,
                                      typeQuestions: typeQuestions,
                                      currentIndex: index,
                                    ),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero
                                ));
                          }},
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.grey.withOpacity(0.38),
                            backgroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green, width: 2),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(100))),
                          ),
                          child: const Text(" Prev ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        TextButton(onPressed: () { //NEXT
                          var atEnd = widget.currentIndex + 1 == typeQuestions.length;
                          if (kDebugMode) {
                            print(widget.currentIndex);
                          }
                          if (kDebugMode) {
                            print(typeQuestions.length);
                          }
                          var index = widget.currentIndex + 1;
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            Navigator.pop(context);
                          });
                          if(!atEnd){
                            Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (context, animation1, animation2) => MSSingle(
                                      msiSingle: generateMSInfo(
                                          typeQuestions[index], index),
                                      allQuestions: allQuestions,
                                      typeQuestions: typeQuestions,
                                      currentIndex: index,
                                    ),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero
                                ));
                          }},
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.grey.withOpacity(0.38),
                            backgroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green, width: 2),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(100))),
                          ),
                          child: const Text(" Next ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.grey.withOpacity(0.38),
                          backgroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green, width: 2),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(100))),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MsComments(msID: widget.msiSingle.id)));
                        },
                        key: const ValueKey('Comments'),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Text('Comments',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ]),
                  ),
        ])));
  }
}
class LabelWidget extends StatelessWidget {
  final String labelText;

  const LabelWidget({Key? key, required this.labelText}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //Information displayed when the mouse hovers over official or unofficial
    String tooltipMessage;
    if (labelText.contains('Official')) {
      tooltipMessage = 'Answer as per the official rationale released by the UKFPO';
    } else {
      tooltipMessage = 'Answer as per our unofficial mark scheme';
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltipMessage,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: labelText.contains('Official') ? Colors.blue : Colors.blue,
          child: Text(
            labelText,
            style: const TextStyle(color: Colors.white),
          ),
        ),

      ),
    );
  }
}
