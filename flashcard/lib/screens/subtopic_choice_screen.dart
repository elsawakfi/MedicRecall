// choose the study type for the feedscreen

import 'package:flashcard_x/utils/page_transition.dart';
import 'package:flashcard_x/widgets/design_main.dart';
import 'package:flutter/material.dart';

import 'feed_screen.dart';

class SubtopicChoice extends StatefulWidget {
  const SubtopicChoice(
      {Key? key, required this.flashcardSet, required this.subtopics})
      : super(key: key);
  final String flashcardSet;
  final List<String> subtopics;

  @override
  State<SubtopicChoice> createState() =>
      // ignore: no_logic_in_create_state
      _SubtopicChoiceState(flashcardSet, subtopics);
}

class _SubtopicChoiceState extends State<SubtopicChoice> {
  String flashcardSet;
  List<String> subtopics;
  List<String> selectedSubtopics = [];
  List<Map<String, dynamic>> subtopicButtonData = [];
  bool selectAllSelected = false;

  _SubtopicChoiceState(this.flashcardSet, this.subtopics);

  @override
  void initState() {
    makeSubtopicButtonData();
    super.initState();
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () => Navigator.pop(context),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Important"),
      content: const Text("No subtopics have been selected"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void reviseCards() {
    if (subtopics.isEmpty) {
      Navigator.push(
        context,
        ExpandRoute(
            page: const Feed(
          subtopics: [],
          count: 1,
          // choice: "revise",
        )),
      );
    } else if (selectedSubtopics.isEmpty) {
      showAlertDialog(context);
    } else {
      Navigator.push(
        context,
        ExpandRoute(
            page: Feed(
          subtopics: selectedSubtopics,
          count: 1,
          // choice: "revise",
        )),
      );
    }
  }

  void newCards() {
    if (subtopics.isEmpty) {
      Navigator.push(
        context,
        ExpandRoute(
            page: const Feed(
          subtopics: [],
          count: 1,
          // choice: "new",
        )),
      );
    } else if (selectedSubtopics.isEmpty) {
      showAlertDialog(context);
    } else {
      Navigator.push(
        context,
        ExpandRoute(
            page: Feed(
          subtopics: selectedSubtopics,
          count: 1,
          // choice: "new",
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DesignMain.appBarMain("Choice", context),
        body: SingleChildScrollView(
            child: Column(children: [
              Container(
                height: 30,
              ),
              const Text(
                "Select what you want to study",
                style: TextStyle(fontSize: 18),
              ),
            Visibility(
              visible: subtopics.isEmpty,
              child: const Text(
                "No subtopics available to choose",
                style: TextStyle(
                  fontSize: 14,
                ),
              )),
            SizedBox(
              width: 600,
              child: Column(
              children: [
                Visibility(
                  visible: subtopics.isNotEmpty,
                  child: ListTile(
                      // In many cases, the key isn't mandatory
                      title: const Text("Select All"),
                      trailing: Stack(
                        children: [
                          Visibility(
                            visible: !selectAllSelected,
                            child: IconButton(
                              key: const ValueKey('Select All'),
                              icon: const Icon(Icons.check_box_outline_blank),
                              onPressed: () {
                                selectAllSelected = true;
                                selectedSubtopics = [];
                                for (int i = 0;
                                    i < subtopicButtonData.length;
                                    i++) {
                                  subtopicButtonData[i]["selected"] = true;
                                  selectedSubtopics
                                      .add(subtopicButtonData[i]["subtopic"]);
                                }
                                setState(() {});
                              },
                            ),
                          ),
                          Visibility(
                            visible: selectAllSelected,
                            child: IconButton(
                              icon: const Icon(Icons.check_box_outlined),
                              onPressed: () {
                                selectAllSelected = false;
                                selectedSubtopics = [];
                                for (int i = 0;
                                    i < subtopicButtonData.length;
                                    i++) {
                                  subtopicButtonData[i]["selected"] = false;
                                }
                                setState(() {});
                              },
                            ),
                          )
                        ],
                      )
                  ),
                ),
                ListView.builder(
                  itemCount: subtopicButtonData.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                        // In many cases, the key isn't mandatory
                        key: UniqueKey(),
                        title: Text(subtopicButtonData[index]["subtopic"]),
                        trailing: Stack(
                          children: [
                            Visibility(
                              visible: !subtopicButtonData[index]["selected"],
                              child: IconButton(
                                key: const ValueKey('subtopic button'),
                                icon: const Icon(Icons.check_box_outline_blank),
                                onPressed: () {
                                  setState(() {
                                    subtopicButtonData[index]["selected"] =
                                        true;
                                  });
                                  selectedSubtopics.add(
                                      subtopicButtonData[index]["subtopic"]);
                                  if (selectedSubtopics.length ==
                                      subtopics.length) {
                                    selectAllSelected = true;
                                  }
                                },
                              ),
                            ),
                            Visibility(
                              visible: subtopicButtonData[index]["selected"],
                              child: IconButton(
                                icon: const Icon(Icons.check_box_outlined),
                                onPressed: () {
                                  setState(() {
                                    subtopicButtonData[index]["selected"] =
                                        false;
                                  });
                                  selectedSubtopics.remove(
                                      subtopicButtonData[index]["subtopic"]);
                                  if (selectedSubtopics.length <
                                      subtopics.length) {
                                    selectAllSelected = false;
                                  }
                                },
                              ),
                            )
                          ],
                        ));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      height: 50.0,
                      width: 170,
                      child: ElevatedButton(
                        key: const ValueKey('new cards'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(
                                  color: Color.fromRGBO(0, 160, 227, 1))),
                          padding: const EdgeInsets.all(10.0),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromRGBO(0, 160, 227, 1),
                        ),
                        //onPressed: (){Feed(flashcardSet: flashcardSet, subtopics: subtopics, choice: 'new',);},
                        onPressed: newCards,
                        child: const Text("New Cards",
                            style: TextStyle(fontSize: 15)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      height: 50.0,
                      width: 170,
                      child: ElevatedButton(
                        key: const ValueKey('Revise'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(
                                  color: Color.fromRGBO(0, 160, 227, 1))),
                          padding: const EdgeInsets.all(10.0),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromRGBO(0, 160, 227, 1),
                        ),
                        onPressed: reviseCards,
                        child: const Text("Revise",
                            style: TextStyle(fontSize: 15)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ])));
  }

  void makeSubtopicButtonData() {
    for (String subtopic in subtopics) {
      subtopicButtonData.add({"subtopic": subtopic, "selected": false});
    }
  }
}
