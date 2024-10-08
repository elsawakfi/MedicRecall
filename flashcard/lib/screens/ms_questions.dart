import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_x/screens/ms_single.dart';
import 'package:flutter/material.dart';

import 'mark_scheme.dart';

// Here we need to cycle through the firestore and make a list of MSI's.
// THe MSIs are based on one type. (Ranking questions)

// stores the list of maps of values for a singular mark scheme entry
List<Map<String, dynamic>> allQuestions = []; // all ms entries on fb
List<int> typeQuestions = []; // questions that correspond to the type we want
List<String> msIDs = [];
var questionTypes = {"rating": 0, "multiple choice": 1, "ranking": 2};

// take the question as a string and search allquestions for it
// once we found it, then retrieve its other properties, as per MSI defn
// send as an MSI object to ms_single.
// this generates the page of the question, answer, etc.


//firebase data:
MSInfo generateMSInfo(int questionIndex, int index) {
  final foundQuestion = allQuestions[questionIndex];
  final answer = foundQuestion['answer'];
  final explanation = foundQuestion['explanation'];
  final type = foundQuestion['type'];
  final id = foundQuestion['id'];
  final situation = foundQuestion['situation'];
  final action = foundQuestion['action'];
  final bool = foundQuestion['bool'];//official or unofficial
  return MSInfo((index + 1).toString(), answer, explanation, type, id,situation,action,bool);

}

int questionComparison(Map<String, dynamic> a, Map<String, dynamic> b) { // What the hell does this function do? -Sam
  final typeA = questionTypes[a["type"]];
  final typeB = questionTypes[b["type"]];
  final numA = int.parse(a["question"].toString());
  final numB = int.parse(b["question"].toString());

  if (typeA! < typeB!) {
    return -1;
  } else if (typeA > typeB) {
    return 1;
  } else {
    if (numA < numB) {
      return -1;
    } else if (numA > numB) {
      return 1;
    }
  }
  return 0;
}

Future<void> msiTypeList(String msType) async {
  // take the type from the selection by the user
  CollectionReference typeRef = FirebaseFirestore.instance
      .collection("markscheme"); // collecting data from the markscheme folder
  QuerySnapshot typeSnapshot = await typeRef.get();

  if (allQuestions.isEmpty) {
    for (var doc in typeSnapshot.docs) {
      var question = doc.data() as Map<String, dynamic>;
      var fullNum = question["question"].toString(); //fullNum gets the question field in the Map of the question, which looks like "QX/114 - official"

      question["question"] =
          fullNum.toString().substring(1, fullNum.indexOf('/', 1)); //returns a string from the start of fullNum until it finds a '/'
      question["id"] = doc.reference.id;
      allQuestions.add(question);
    }
    allQuestions.sort(questionComparison);
  }

  typeQuestions = [];
  for (var i = 0; i < allQuestions.length; i++) {
    if (allQuestions[i]["type"] == msType) {
      typeQuestions.add(i);
    }
  }
}

class MSI extends StatefulWidget {
  //Mark scheme information

  //final MSInfo msinfo; // initialise the field that holds the mark scheme info, passed in by the user

  // in constructor, require a type to be handed over
  const MSI({
    Key? key,
    required this.qtype,
  }) : super(key: key);

  // MSInfo is required

  final String qtype; //declare a field holding the type of question

  @override
  State<MSI> createState() => _MSIState();
}

class _MSIState extends State<MSI> {
  @override
  initState() {
    // init state runs before build method thanks to addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //questions = []; // this is so we dont re-add questions to the listbuilder
      await msiTypeList(widget.qtype);
      //await msiTypeList("rating");
      //print(widget.qtype);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final builder = typeQuestions.isNotEmpty
        ? GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: typeQuestions.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MSSingle(
                  msiSingle: generateMSInfo(typeQuestions[index], index),
                  allQuestions: allQuestions,
                  typeQuestions: typeQuestions,
                  currentIndex: index,
                ),
              ),
            );
          },
          child: Card(
            key: ValueKey("Question ${index + 1}"),
            child: Container(
              decoration: const BoxDecoration(
                // border: Border.all(color: Colors.black),
              ),
              child: Center(
                child: Text(
                  "Q${index + 1}",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        );
      },
    )
        : const Center(child: CircularProgressIndicator());

    return Scaffold(
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
                  child: Text(widget.qtype[0].toUpperCase() + widget.qtype.substring(1)),
                  ),
              ],
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        body: builder);
  }
}
