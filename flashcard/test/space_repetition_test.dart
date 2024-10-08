import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

class ExampleFlashcard {
  late final String question;
  late final String answer;
  late final String resource;
  late int score;
  late Timestamp lastSeen;

  ExampleFlashcard(
      {required this.question, required this.answer, required this.resource, required this.score, required this.lastSeen});
}

void main() {
  List flashcards = [
    ExampleFlashcard(
        question: "What should be your number one priority in any scenario",
        answer: "Patient safety, dignity or comfort \n"
            "\n"
            "If this is compromised, you must take prompt action as your first priority \n",
        resource: "Good Medical Practice Paragraph 25",
        score: 0,
        lastSeen: Timestamp.now()
    ),

    ExampleFlashcard(
        question: "How many times should you attempt a procedure (e.g. cannulation) before asking another doctor to try?",
        answer: "Generally recommended that after 2 failed attempts, you ask another colleague to try (this depends on hospital guidelines)",
        resource: "RESOURCE 2",
        score: 1,
        lastSeen: Timestamp.now()
    ),

    ExampleFlashcard(
        question: "What should you do if a patient has a condition or is undergoing treatment that may affect their ability to drive (e.g. epilepsy)",
        answer: "Explain that their condition may affect their ability to drive and tell them that they have a legal duty to inform the DVLA or DVA \n"
            "\n"
            "Tell the patient that you may be obliged to disclose relevant medical information about them, in confidence, to the DVLA or DVA if they continue to drive when they are not fit to do so \n"
            "\n"
            "Make a note of any advice you have given to a patient about their fitness to drive in their medical record. \n ",
        resource: "RESOURCE 3",
        score: 0,
        lastSeen: Timestamp.now()
    ),
  ];

  List<Map<String,dynamic>> mappedFlashcards = [];
  // var count=0;
  for (ExampleFlashcard exampleflashcard in flashcards) {
    // count++;
    // print(count);
    Timestamp lastSeenTemp = exampleflashcard.lastSeen;
    var scoreTemp = exampleflashcard.score;
    Map<String, dynamic> mapTemp =
    {"lastSeen": lastSeenTemp,
      "score": scoreTemp};
    mappedFlashcards.add(mapTemp);
  }
  //print(_mappedFlashcards.length);
  List<double> howLongAgoDaysList=[];
  for (var mappedFlashcard in mappedFlashcards) {
    Timestamp lastSeenTimestamp = mappedFlashcard["lastSeen"];
    var howLongAgoSeenSeconds = (Timestamp
        .now()
        .seconds - lastSeenTimestamp.seconds);
    var howLongAgoSeenDays = howLongAgoSeenSeconds / (60 * 60 * 24);
    howLongAgoDaysList.add(howLongAgoSeenDays);
  }
  List<Map<String,dynamic>> filteredMappedCards=[];

    for (var index = 0; index<mappedFlashcards.length; index++){
      if (mappedFlashcards[index]["score"]==0){
        filteredMappedCards.add(mappedFlashcards[index]);
  } else{
        if (howLongAgoDaysList[index]>1){
          filteredMappedCards.add(mappedFlashcards[index]);
        }else{

        }
      }

  }
  //print(filteredMappedCards.length);
  test("did the cards get filtered", ()
  {
    expect(filteredMappedCards.length, 2);
  }
  );
}