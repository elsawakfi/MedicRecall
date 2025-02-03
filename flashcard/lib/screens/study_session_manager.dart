import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flashcard_x/main.dart';
//import 'package:flashcard_x/screens/minimock_feedback.dart';
import 'package:flashcard_x/utils/algo.dart';
//import 'feed_screen.dart';
import 'package:flashcard_x/widgets/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'calendar_screen.dart';
// import 'button_screen.dart';

class StudySessionManager {
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

  late CollectionReference _eventsCollectionRef;
  Future<List<Timestamp>?> getTimestamps(String userId) async {
    try {
      DocumentSnapshot userDoc = await _userCollectionRef.doc(userId).get();
      if (userDoc.exists) {
        List<Timestamp> times = List<Timestamp>.from(userDoc['topicLastSeen']);
        return times;
        // Use the selected resources as needed
      } else {
        if (kDebugMode) {
          print('User document does not exist');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving selected resources: $e');
      }
    }
    return null;
  }

  Future<List<String>?> getSelectedResources(String userId) async {
    try {
      DocumentSnapshot userDoc = await _userCollectionRef.doc(userId).get();
      if (userDoc.exists) {
        List<String> selectedResources =
            List<String>.from(userDoc['selectedResources']);
        return selectedResources;
        // Use the selected resources as needed
      } else {
        if (kDebugMode) {
          print('User document does not exist');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving selected resources: $e');
      }
    }
    return null;
  }

  // Generate study sessions based on user data and test day
  Future<Map<DateTime, List<Event>>> generateStudySessions(User user) async {
    Map<DateTime, List<Event>> generatedEvents = {};

    QuerySnapshot querySnapshot =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    var userId = querySnapshot.docs.last.id;
    //var databaseFlashcards = await Algo().getFlashcards(user.uid);
    final data = querySnapshot.docs.last.data() as Map<String, dynamic>; // Turn snapshot into a data type that can be searched to see if testDay exists
    if (!data.containsKey('TestDay')) return generatedEvents;
    DateTime testDay = querySnapshot.docs.last['TestDay'].toDate();
    // Get topics and related data from the database or pass them as arguments
    List<String>? selectedResources = await getSelectedResources(userId);

    DateTime firstStudyDay = querySnapshot.docs.last['firstStudyDay'].toDate();

    
  
    // Start study sessions from today (aka. the day u start study session)
    int daysUntilTest =
        (testDay.difference(firstStudyDay).inHours / 24).round();
    // Loop through topics to generate study sessions


      if (selectedResources!.contains('Mini-mocks')) {
      //The dates need to be zeroed out in the time field otherwise they
      //can't be added to the calendar
      
      DateTime halfwayDate =  DateTime(firstStudyDay.year, firstStudyDay.month, firstStudyDay.day + (daysUntilTest~/2), 0, 0, 0, 0);
    
      if(generatedEvents[halfwayDate] == null ){
          generatedEvents[halfwayDate] = [];
      }
      generatedEvents[halfwayDate]!.add(Event(title: "Second Mini Mock", color: Color.fromARGB(255, 138, 201, 38)));

      //Need to 0 out the time part of the DateTime variable
      DateTime studyDay = DateTime(firstStudyDay.year, firstStudyDay.month, firstStudyDay.day, 0, 0, 0, 0);
      if (generatedEvents[studyDay] == null) {
        generatedEvents[studyDay] = [];
      }

      generatedEvents[studyDay]!.add(Event(title: "First Mini Mock", color: Color.fromARGB(255, 138, 201, 38)));

    }

    if (selectedResources.contains('Full-sized mock exam')) {
      int repetitions = querySnapshot.docs.last['selectedRepetition'];

      List<int> intervals = [];
      for (int i = 0; i < repetitions; i++) {
        intervals.add(((daysUntilTest / 3) - 2 + (i * 4)).round());
      }

      for (int interval in intervals) {
        DateTime mockExamDate = DateTime(firstStudyDay.year, firstStudyDay.month, firstStudyDay.day + interval, 0, 0, 0, 0);
        
        while (generatedEvents[mockExamDate] != null) {
          mockExamDate = mockExamDate.add(Duration(days: 1));
        }
        generatedEvents[mockExamDate] = [];
        generatedEvents[mockExamDate]!.add(Event(title: "Full-sized Mock Exam ${intervals.indexOf(interval) + 1}", color: Color.fromARGB(255, 120, 202, 210)));
      }
    }

    if (selectedResources.contains('Official paper')) {
      int repetitions = querySnapshot.docs.last['selectedRepetition'];

      // get the days until the test + intervals
      List<int> intervals = [];
      for (int i = 0; i < repetitions; i++) {
        intervals.add((daysUntilTest * i / repetitions).round());
      }

      for (int interval in intervals) {
        DateTime officialPaperDate =
            DateTime(firstStudyDay.year, firstStudyDay.month, firstStudyDay.day + interval, 0, 0, 0, 0);
        while (generatedEvents[officialPaperDate] != null) {
          officialPaperDate = officialPaperDate.add(Duration(days:1));
          
        }

        generatedEvents[officialPaperDate] = [];
        generatedEvents[officialPaperDate]!.add(Event(title: "Official Paper ${intervals.indexOf(interval) + 1}", color: Color.fromARGB(255, 163, 68, 174)));

      }
    }

    if (selectedResources.contains("Flashcards")) {
      try {
        CollectionReference<Map<String, dynamic>> flashcards =
            FirebaseFirestore.instance.collection('flashcards');
        List<String> contains = [];

        QuerySnapshot<Map<String, dynamic>> flashcardDeck =
            await flashcards.get();
       
        //These flashcards will be ones that the user has never looked at,
        //so we will prioritise these in the calendar
        for (var doc in flashcardDeck.docs) {
          Map<String, dynamic> flashcard = doc.data();

          if (!contains.contains(flashcard["topic"])) {
            contains.add(flashcard["topic"]);
            DateTime nextReviewDate =
                DateTime(firstStudyDay.year, firstStudyDay.month, firstStudyDay.day + 2, 0, 0, 0, 0);
            if (daysUntilTest >= 30 && daysUntilTest < 60) {
              while (generatedEvents[nextReviewDate] != null) {
                nextReviewDate = DateTime(nextReviewDate.year,
                    nextReviewDate.month, nextReviewDate.day + 2, 0, 0, 0, 0);
              }
            }
            if (daysUntilTest > 60) {
              while (generatedEvents[nextReviewDate] != null) {
                nextReviewDate = DateTime(nextReviewDate.year,
                    nextReviewDate.month, nextReviewDate.day + 3, 0, 0, 0, 0);
              }
            }
            if (daysUntilTest < 30) {
              while (generatedEvents[nextReviewDate] != null) {
                nextReviewDate = DateTime(nextReviewDate.year,
                    nextReviewDate.month, nextReviewDate.day + 1, 0, 0, 0, 0);
              }
            }
            if (testDay.isAfter(nextReviewDate)) {
              generatedEvents[nextReviewDate] = [];
              generatedEvents[nextReviewDate]!
                  .add(Event(title: flashcard["topic"] + " Flashcards",color: Color.fromARGB(255, 255, 202, 58)));
            }
          }
        }

        //the getFlashcards method retrieves flashcards that the user
        //HAS looked at
        var seenFlashcards = await Algo().getFlashcards(user.uid);
        for (var flashcard in seenFlashcards) {
          if (!contains.contains(flashcard["topic"])) {
            contains.add(flashcard["topic"]);

            DateTime nextReviewDate =
                DateTime(firstStudyDay.year, firstStudyDay.month, firstStudyDay.day + 0, 0, 0, 0, 0);
            if (daysUntilTest > 31 && daysUntilTest < 60) {
              while (generatedEvents[nextReviewDate] != null) {
                nextReviewDate = DateTime(nextReviewDate.year,
                    nextReviewDate.month, nextReviewDate.day + 2, 0, 0, 0, 0);
              }
            }
            if (daysUntilTest > 60) {
              while (generatedEvents[nextReviewDate] != null) {
                nextReviewDate = DateTime(nextReviewDate.year,
                    nextReviewDate.month, nextReviewDate.day + 3, 0, 0, 0, 0);
              }
            }
            if (daysUntilTest < 30) {
              while (generatedEvents[nextReviewDate] != null) {
                nextReviewDate = DateTime(nextReviewDate.year,
                    nextReviewDate.month, nextReviewDate.day + 1, 0, 0, 0, 0);
              }
            }

            if (testDay.isAfter(nextReviewDate)) {
              //Once a free day is used, the corresponding flashcard topic is added
              generatedEvents[nextReviewDate] = [];
              generatedEvents[nextReviewDate]!
                  .add(Event(title: flashcard["topic"] + " Flashcards", color: Color.fromARGB(255, 255, 202, 58)));
            }
          }
        }
      } catch (e) {
        print("Error\n");
        print(e);
      }
    }
    return generatedEvents;
  }

//IS THIS FUNCTION NEEDED IF WE USE THE CLIENTS FORMULA?????
  int calculateDaysToNextReview(int topicCount, Timestamp lastSeen) {
    Map<int, int> dateToColourMap = {0: 1, 1: 2, 2: 4, 3: 8, 4: 16, 5: 32};
    int daysSinceLastReview =
        (Timestamp.now().seconds - lastSeen.seconds) ~/ (60 * 60 * 24);
    int daysToNextReviewDate =
        (((dateToColourMap[topicCount]!) + (lastSeen.seconds / 86400))
                .toInt()) -
            Timestamp.now().seconds ~/ 86400;
    if (daysSinceLastReview > 14) {
      daysToNextReviewDate = 1;
      return daysToNextReviewDate;
    } else {
      return 14 - daysSinceLastReview;
    }
  }

  void startStudySession(List<String> selectedResources) {
    // Implement the logic to start the study session with the selected resources
  }

  // Save generated events to the database
  Future<void> saveStudySessionsToDB(
      User user, Map<DateTime, List<Event>> events) async {
    QuerySnapshot u =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    String id = u.docs.last.id;

    _eventsCollectionRef =
        FirebaseFirestore.instance.collection('users/$id/events');
    for (var date in events.keys) {
      List<String> eventTitles = events[date]!.map((e) => e.title).toList();
      await _eventsCollectionRef.add({"date": date, "events": eventTitles});
    }
  }
}
