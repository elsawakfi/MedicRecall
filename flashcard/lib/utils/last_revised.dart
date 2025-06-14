import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';

class LastRevised {
  
  static Future<TopicStats> getStats({bool includeSubtopics=true}) async {

    if (FirebaseWrapper.auth().currentUser == null) {
    return TopicStats(seenCards: {"Effective Communication" : 1}, totalCards: {"Effective Communication" : 1}, timesSeen: {"Effective Communication" : 1}, dateLastRevised: {"Effective Communication": DateTime.now()});
    }

    Map<String, int> seenCards = {};
    Map<String, int> totalCards = {};
    Map<String, int> timesSeen = {};
    Map<String, DateTime> dateLastRevised = {};

    CollectionReference flashcardRef =
        FirebaseWrapper.firestore().collection('flashcards');
    String userID = (await FirebaseWrapper.firestore().collection("users").where("userID", isEqualTo: FirebaseWrapper.auth().currentUser!.uid).get()).docs.last.id;
    CollectionReference seenRef = FirebaseWrapper.firestore()
        .collection("users/$userID/flashcardsSeen");
    QuerySnapshot seen = await seenRef.get();
    QuerySnapshot all =
        await flashcardRef.where("owner", isEqualTo: "all").get();
    QuerySnapshot userCards =
        await flashcardRef.where("owner", isEqualTo: userID).get();

    for (var doc in seen.docs) {
      DocumentSnapshot card = await flashcardRef.doc(doc["cardID"]).get();
      if (card.exists) {
        Map<String, dynamic> data = card.data() as Map<String, dynamic>;
        _incrementMap(seenCards, data["topic"].toString());
        _updateDate(dateLastRevised, data["topic"], doc["lastSeen"].toDate());
        _limitMin(timesSeen, data["topic"], doc["score"][0] ?? 0);
        if (data["subtopic"] != "" && includeSubtopics) {
          _incrementMap(seenCards, data["subtopic"].toString());
          _updateDate(dateLastRevised, data["subtopic"], doc["lastSeen"].toDate());
          _limitMin(timesSeen, data["subtopic"], doc["score"][0] ?? 0);
        }
      }
    }
                 
    for (var doc in all.docs + userCards.docs) { // This loads all the cards during the dashboard screen loading process...
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _incrementMap(totalCards, data["topic"].toString());
        if (data["subtopic"] != "" && includeSubtopics) {
          _incrementMap(totalCards, data["subtopic"].toString());
        }
      }
    }

    return TopicStats(seenCards: seenCards, totalCards: totalCards, timesSeen: timesSeen, dateLastRevised: dateLastRevised);

  }

  // N.B. Do not include subtopics in stats
  static Map<String, DateTime> nextReviewDateByTopic(TopicStats topicStats) {
    Map<String, DateTime> datesByTopic = {};
    Map<DateTime, int> eventsOnEachDate = {};

    // Remove the time and only keep the date
    DateTime todayTrimmed = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    // Keys = times repeated
    // value = coefficient to add to calculation
    Map<int, int> timeRepeatedCoefficient = {0: 0, 1: 2, 2: 4, 3: 8, 4: 16}; // anything >4 will default to 32 when this map is accessed

    for (String topicID in topicStats.totalCards.keys) {

      // Calculate next review date
      DateTime nextReviewDate = todayTrimmed;
      DateTime? dateTopicLastRevised = topicStats.dateLastRevised[topicID];
      // If the topic has never been revised, it will be added to today on the calendar
      if (dateTopicLastRevised != null) {
        // Trim the hours and seconds
        dateTopicLastRevised = DateTime(dateTopicLastRevised.year, dateTopicLastRevised.month, dateTopicLastRevised.day);


        // Spaced Repition Algorithm = Last Review Date + 3 days + coefficient for number of times seen
        int daysToNextReviewDate = 3 + (timeRepeatedCoefficient[topicStats.timesSeen[topicID] ?? 0] ?? 32);
        DateTime tempNextReviewDate = dateTopicLastRevised.add(Duration(days: daysToNextReviewDate));
        // check we aren't putting anything in the past
        if (tempNextReviewDate.isAfter(todayTrimmed)) {
          nextReviewDate = tempNextReviewDate;
        }

      }

      final maxPerColumn = 2;
      while ((eventsOnEachDate[nextReviewDate] ?? 0) >= maxPerColumn) {
        
        nextReviewDate = nextReviewDate.add(Duration(days: 1));
      }

      _updateDate(datesByTopic, topicID, nextReviewDate);
      _incrementMap<DateTime>(eventsOnEachDate, nextReviewDate);

    }

    return datesByTopic;

  }

  static void _incrementMap<T>(Map<T, int> map, T key) {
    if (map.containsKey(key)) {
      map.update(key, (i) => map[key]! + 1);
      return;
    }
    map[key] = 1;
  }

  static void _updateDate(Map<String, DateTime> map, String key, DateTime newDate) {
    if (map[key] == null) {
      map[key] = newDate;
    } else {
      if (map[key]!.isBefore(newDate)) {
        map[key] = newDate;
      }
    }
  }

  // Sets the value of a map ensuring it does not override a smaller value
  static void _limitMin(Map<String, int> map, String key, int value) {
    if (map[key] == null) {
      map[key] = value;
    } else {
      if (value < map[key]!) {
        map[key] = value;
      }
    }
  }

  // ---------------------------------- STREAKS PAGE --------------------------------------
  static Future<void> recordLogin() async {

    if (FirebaseWrapper.auth().currentUser == null) {
      return;
    }

    DateTime today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    // check today has not already been logged
    StreakStats stats = await loadStreakStats();
    if (stats.daysLoggedIn.contains(today)) {
      return;
    }

    String userID = (await FirebaseWrapper.firestore().collection("users").where("userID", isEqualTo: FirebaseWrapper.auth().currentUser!.uid).get()).docs.last.id;
    CollectionReference loginsRef = FirebaseWrapper.firestore().collection("users/$userID/daysLoggedIn");
    loginsRef.add({"date": Timestamp.fromDate(today)});

  }

  // increments the totalDecksSeen field
  static Future<void> logFlashCardDeck() async {

    if (FirebaseWrapper.auth().currentUser == null) {
      return;
    }

    String userID = (await FirebaseWrapper.firestore().collection("users").where("userID", isEqualTo: FirebaseWrapper.auth().currentUser!.uid).get()).docs.last.id;
    DocumentReference<Map<String, dynamic>> userRef = FirebaseWrapper.firestore().doc("users/$userID");
    var snapshot = await userRef.get();
    int currentTotal = (snapshot.data()??{})["totalDecksSeen"] ?? 0;
    userRef.update({"totalDecksSeen": currentTotal + 1});
  }

  static Future<StreakStats> loadStreakStats() async {

    if (FirebaseWrapper.auth().currentUser == null) {
      return StreakStats(numberOfDecksRevised: 0, daysLoggedIn: []);
    }

    String userID = (await FirebaseWrapper.firestore().collection("users").where("userID", isEqualTo: FirebaseWrapper.auth().currentUser!.uid).get()).docs.last.id;
    
    // user logins
    Query<Map<String, dynamic>> loginsRef = FirebaseWrapper.firestore().collection("users/$userID/daysLoggedIn").orderBy("date", descending: true);
    var snapshot = await loginsRef.get();

    List<DateTime> daysLoggedIn = [];

    for (var doc in snapshot.docs) {
      Timestamp timestamp = doc.data()["date"];
      daysLoggedIn.add(timestamp.toDate());
    }

    // total decks seen
    var userInfo = await FirebaseWrapper.firestore().doc("users/$userID").get();
    int decksSeen = (userInfo.data()??{})["totalDecksSeen"] ?? 0;

    // exam date
    Timestamp? timestamp = (userInfo.data()??{})["TestDay"];
    DateTime? examDate;
    if (timestamp != null) {
      examDate = timestamp.toDate();
    } 
    
    return StreakStats(numberOfDecksRevised: decksSeen, daysLoggedIn: daysLoggedIn, examDate: examDate);

  }

}

class TopicStats {

  final Map<String, int> seenCards;
  final Map<String, int> totalCards;
  final Map<String, int> timesSeen;
  final Map<String, DateTime> dateLastRevised;

  TopicStats({required this.seenCards, required this.totalCards, required this.timesSeen, required this.dateLastRevised});

}

class StreakStats {
  
  final int numberOfDecksRevised;
  final List<DateTime> daysLoggedIn; // ordered most recent to least recent
  final DateTime? examDate; // can be null if the user has not set a date

  StreakStats({required this.numberOfDecksRevised, required this.daysLoggedIn, this.examDate});

  int howManyDaysInARow() {
    // starts at today
    DateTime mostRecent = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    int total = 0;
    for (DateTime day in daysLoggedIn) { // go through the list back to front
      // if each day going back from today is included in dayLoggedIn, add 1 to the total
      if (day.isAtSameMomentAs(mostRecent)) {
        total++;
        mostRecent = mostRecent.subtract(Duration(days: 1));
      } else {
        return total;
      }
      
    }
    return total;
  }

  List<bool> last7Days() {
    // starts at today
    DateTime today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    List<bool> revised = [];
    for (DateTime day = today; day.isAfter(today.subtract(Duration(days: 7))); day = day.subtract(Duration(days: 1))) {
      revised.add(daysLoggedIn.contains(day));
    }
    return revised;
  }

}