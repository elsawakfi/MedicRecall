// this is where we decide the order and what cards are shows to the user

import 'package:cloud_firestore/cloud_firestore.dart';

class Algo {
  bool containsCard(String cardID, List<Map<String, dynamic>> cards) {
    for (var card in cards) {
      //for each card in cards
      if (card["id"] == cardID) {
        //if card can be found
        return true;
      }
    }
    return false; //otherwise
  }

  int weight(Map<String, dynamic> a) {
    return ifTheyGetItWrong(a) * whenToShowNext(a);
  }

  int whenToShowNext(Map<String, dynamic> a) {
    //var whenToShowA = a["lastSeen"] + (2 * a["timesSeen"]);
    int whenToShow = ((a["score"] / 2) * (2 + ((a["score"] - 1) * 2)));
    if (whenToShow > 6) {
      whenToShow = 6;
    }
    return whenToShow;
  }

  int ifTheyGetItWrong(Map<String, dynamic> a) {
    if (a["gotRight"] == false) {
      return -1;
    }
    return 1;
  }

  Future<List<Map<String, dynamic>>> getFlashcards(String userID) async {
    CollectionReference flashcardRef = FirebaseFirestore.instance
        .collection('flashcards'); //get flashcards from firebase

    CollectionReference usersRef =
    FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot = await usersRef
        .where("userID", isEqualTo: userID)
        .get(); //flashcard ordering is unique to users

    var userDocId = querySnapshot.docs.first.id;

    CollectionReference flashcardsSeenRef = FirebaseFirestore.instance
        .collection("users/$userDocId/flashcardsSeen"); //recognise flashcard as seen

    List<Map<String, dynamic>> flashcards = [];

    QuerySnapshot seenCards = await flashcardsSeenRef.get();

    List<Future<DocumentSnapshot>> futures = [];
    List<int> scores = [];
    List<Timestamp> lastSeen = [];
    List<int> timesSeen = [];
    List<bool> gotRight = [];
    for (var doc in seenCards.docs) {
      futures.add(flashcardRef.doc(doc["cardID"]).get());
      scores.add(doc["score"][0]);
      lastSeen.add(doc["lastSeen"]);
      timesSeen.add(doc["timesSeen"]);
      gotRight.add(doc["gotRight"]);
    }

    List<DocumentSnapshot> queries = await Future.wait(futures);
    for (var i = 0; i < queries.length; i++) {
      DocumentSnapshot doc = queries[i];
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data["id"] = doc.id;
        data["score"] = scores[i];
        data["lastSeen"] = lastSeen[i];
        data["timesSeen"] = timesSeen[i];
        data["gotRight"] = gotRight[i];
        flashcards.add(data);
      }
    }
    return flashcards;
  }

  Future<List<Map<String, dynamic>>> newCards(
      List<String> subtopics, String userID) async {
    CollectionReference flashcardRef =
        FirebaseFirestore.instance.collection('flashcards');
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot =
        await usersRef.where("userID", isEqualTo: userID).get();

    var userDocId = querySnapshot.docs.first.id;

    CollectionReference flashcardsSeenRef = FirebaseFirestore.instance
        .collection("users/$userDocId/flashcardsSeen");

    List<Map<String, dynamic>> flashcards = [];//yes

    QuerySnapshot flashcardsSnapshotAll =
        await flashcardRef.where("owner", isEqualTo: "all").get();//not to
    QuerySnapshot flashcardsSnapshotUser =
        await flashcardRef.where("owner", isEqualTo: userID).get();
    QuerySnapshot flashcardsSeen = await flashcardsSeenRef.get();

    for (var card in flashcardsSnapshotAll.docs + flashcardsSnapshotUser.docs) {
      var id = card.id;

      bool exists = false;
      for (var cardSeen in flashcardsSeen.docs) {
        if (id == cardSeen["cardID"]) {
          exists = true;
        }
      } //to not

      if (!exists) {
        Map<String, dynamic> data = card.data() as Map<String, dynamic>;
        data["id"] = card.id;
        flashcards.add(data);
      }
    }

    List<Map<String, dynamic>> filteredCards = [];

    if (subtopics.isNotEmpty) {
      for (var flashcard in flashcards) {
        if (subtopics.contains(flashcard["subtopic"]) ||
            subtopics.contains(flashcard["topic"]) &&
                flashcard["subtopic"] == "") {
          filteredCards.add(flashcard);
        }
      }
    } else {
      filteredCards = flashcards;
    }

    filteredCards.shuffle();
    return filteredCards;
  }

  Future<List<Map<String, dynamic>>> getCards(
      List<String> subtopics, String userID) async {

    var flashcards = await getFlashcards(userID);

    List<Map<String, dynamic>> filteredCards = [];

    Map<int, int> scoreToDay = {0: 0, 1: 2, 2: 4, 3: 8, 4: 16, 5: 32, 6: 64, 7: 128};

    if (subtopics.isNotEmpty) {

      for (var flashcard in flashcards) {

        if (subtopics.contains(flashcard["subtopic"]) ||
            subtopics.contains(flashcard["topic"]) &&
                flashcard["subtopic"] == "") {

          //var monthDifference= flashcard["lastSeen"]
          Timestamp lastSeenTimestamp = flashcard["lastSeen"];

          //howLongAgoSeenSeconds records how many seconds ago the card has last been seen.
          var howLongAgoSeenSeconds =
              (Timestamp.now().seconds - lastSeenTimestamp.seconds);
          //howLongAgoSeenDays stores how many days ago the card has last been seen.
          var howLongAgoSeenDays = howLongAgoSeenSeconds / (60 * 60 * 24);
          if (flashcard["score"] < 0) {
          } else {

            //checks if score is within the scoreToDay range
            if (flashcard["score"] < scoreToDay.length) {
              //checks if the card is ready to be revised
              if (howLongAgoSeenDays > scoreToDay[flashcard["score"]]!) {
                filteredCards.add(flashcard);
              }
            } else {
              //checks if the card is ready to be revised when over the scoreToDay limit
              if (howLongAgoSeenDays >
                  scoreToDay[flashcard[scoreToDay.length - 1]]!) {
                filteredCards.add(flashcard);

              }
            }

          }

        }

      }

    } else {
      for (var flashcard in flashcards) {
        Timestamp lastSeenTimestamp = flashcard["lastSeen"];
        //howLongAgoSeenSeconds records how many seconds ago the card has last been seen.
        var howLongAgoSeenSeconds =
            (Timestamp.now().seconds - lastSeenTimestamp.seconds);
        //howLongAgoSeenDays stores how many days ago the card has last been seen.
        var howLongAgoSeenDays = howLongAgoSeenSeconds / (60 * 60 * 24);
        if (flashcard["score"] < 0) {
        } else {
          //checks if score is within the scoreToDay range
          if (flashcard["score"] < scoreToDay.length) {
            //checks if the card is ready to be revised
            if (howLongAgoSeenDays > scoreToDay[flashcard["score"]]!) {
              filteredCards.add(flashcard);
            }
          } else {
            //checks if the card is ready to be revised if over the scoreToDay limit
            if (howLongAgoSeenDays >
                scoreToDay[flashcard[scoreToDay.length - 1]]!) {
              filteredCards.add(flashcard);
            }
          }
        }
      }
    }

    //filteredCards.sort((a,b) => weight(a).compareTo(weight(b)));

    return filteredCards;
  }

  Future<int?> getScore(String userID, List<String> subtopics) async {
    var flashcards = await getFlashcards(userID);
    int? score = 0;
    for (var flashcard in flashcards) {
      if ((subtopics.contains(flashcard["subtopic"]) ||
          subtopics.contains(flashcard["topic"]) &&
              flashcard["subtopic"] == "") && flashcard["timesSeen"] < 2 && flashcard["gotRight"] == true) {
        score = score! + 1;
      }
    }
    return score;
  }
}
