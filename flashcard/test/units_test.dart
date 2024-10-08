import 'package:flutter_test/flutter_test.dart';

class Exampleflashcard {
  late final String question;
  late final String answer;
  late final String resource;
  late int score;

  Exampleflashcard(
      {required this.question, required this.answer, required this.resource, required this.score});

}
void main() {
  List flashcards = [
    Exampleflashcard(
        question: "What should be your number one priority in any scenario",
        answer: "Patient safety, dignity or comfort \n"
            "\n"
            "If this is compromised, you must take prompt action as your first priority \n",
        resource: "Good Medical Practice Paragraph 25",
        score:0
    ),

    Exampleflashcard(
        question: "How many times should you attempt a procedure (e.g. cannulation) before asking another doctor to try?",
        answer: "Generally recommended that after 2 failed attempts, you ask another colleague to try (this depends on hospital guidelines)",
        resource: "RESOURCE 2",
        score:0
    ),

    Exampleflashcard(
        question: "What should you do if a patient has a condition or is undergoing treatment that may affect their ability to drive (e.g. epilepsy)",
        answer: "Explain that their condition may affect their ability to drive and tell them that they have a legal duty to inform the DVLA or DVA \n"
            "\n"
            "Tell the patient that you may be obliged to disclose relevant medical information about them, in confidence, to the DVLA or DVA if they continue to drive when they are not fit to do so \n"
            "\n"
            "Make a note of any advice you have given to a patient about their fitness to drive in their medical record. \n ",
        resource: "RESOURCE 3",
        score:0
    ),
  ];
  test("one should be one",(){
    int expectedNumber = 1;
    expect(expectedNumber, 1);
  }
  );

  test("prevCard", () {

    int currentCard = 0;
    void prevCard() {
      currentCard = (currentCard - 1 >= 0) ? currentCard - 1 : flashcards.length - 1;
    }
    expect(currentCard, 0);
    prevCard();
    expect(currentCard, 2);
    prevCard();
    expect(currentCard, 1);
    prevCard();
    expect(currentCard, 0);
    printOnFailure('test "prevCard" is Failure');
  });

  test("nextCard", () {
    int currentCard = 0;
    void nextCard() {
      currentCard = currentCard + 1 < flashcards.length ? currentCard + 1 : 0;
    }
    expect(currentCard, 0);
    nextCard();
    expect(currentCard, 1);
    nextCard();
    expect(currentCard, 2);
    nextCard();
    expect(currentCard, 0);
  }

  );
}