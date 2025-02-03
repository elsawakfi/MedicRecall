import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/utils/algo.dart';
import 'package:flashcard_x/widgets/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Manages the generation and scheduling of study sessions
class StudySessionManager {
  // Constants for event colors
  static const Color kMiniMockColor = Color.fromARGB(255, 138, 201, 38);
  static const Color kFullMockColor = Color.fromARGB(255, 120, 202, 210);
  static const Color kOfficialPaperColor = Color.fromARGB(255, 163, 68, 174);
  static const Color kFlashcardColor = Color.fromARGB(255, 255, 202, 58);

  // Firebase references
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  late CollectionReference _eventsCollectionRef;

  /// Retrieves timestamps of last seen topics for a user
  Future<List<Timestamp>?> getTimestamps(String userId) async {
    try {
      DocumentSnapshot userDoc = await _userCollectionRef.doc(userId).get();
      if (!userDoc.exists) {
        if (kDebugMode) {
          print('User document does not exist');
        }
        return null;
      }

      final data = userDoc.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('topicLastSeen')) {
        return null;
      }

      return List<Timestamp>.from(data['topicLastSeen']);
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving timestamps: $e');
      }
      return null;
    }
  }

  /// Retrieves selected study resources for a user
  Future<List<String>?> getSelectedResources(String userId) async {
    try {
      DocumentSnapshot userDoc = await _userCollectionRef.doc(userId).get();
      if (!userDoc.exists) {
        if (kDebugMode) {
          print('User document does not exist');
        }
        return null;
      }

      final data = userDoc.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('selectedResources')) {
        return null;
      }

      return List<String>.from(data['selectedResources']);
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving selected resources: $e');
      }
      return null;
    }
  }

  /// Helper function to find the nearest available date for an event
  DateTime findNearestFreeDate(
      DateTime targetDate,
      int maxDaysToMove,
      DateTime testDay,
      DateTime today,
      Map<DateTime, List<Event>> generatedEvents) {
    if (generatedEvents[targetDate] == null) return targetDate;

    for (int i = 1; i <= maxDaysToMove; i++) {
      // Try future date first
      DateTime futureDate = DateTime(
          targetDate.year, targetDate.month, targetDate.day + i, 0, 0, 0, 0);
      if (generatedEvents[futureDate] == null && futureDate.isBefore(testDay)) {
        return futureDate;
      }

      // Then try past date
      DateTime pastDate = DateTime(
          targetDate.year, targetDate.month, targetDate.day - i, 0, 0, 0, 0);
      if (generatedEvents[pastDate] == null && pastDate.isAfter(today)) {
        return pastDate;
      }
    }
    return targetDate;
  }

  /// Generates study sessions based on user preferences and test date
  Future<Map<DateTime, List<Event>>> generateStudySessions(User user) async {
    try {
      Map<DateTime, List<Event>> generatedEvents = {};

    QuerySnapshot querySnapshot =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    var userId = querySnapshot.docs.last.id;
    //var databaseFlashcards = await Algo().getFlashcards(user.uid);
    DateTime testDay = querySnapshot.docs.last['TestDay'].toDate();
    // Get topics and related data from the database or pass them as arguments
    List<String>? selectedResources = await getSelectedResources(userId);

    DateTime firstStudyDay = querySnapshot.docs.last['firstStudyDay'].toDate();

    // Start study sessions from today (aka. the day u start study session)
    int daysUntilTest =
        (testDay.difference(firstStudyDay).inHours / 24).round();
    // Loop through topics to generate study sessions

      final userDoc = querySnapshot.docs.last;
      final userData = userDoc.data() as Map<String, dynamic>;

      if (selectedResources == null || selectedResources.isEmpty) {
        if (kDebugMode) {
          print('No resources selected');
        }
        return {};
      }

      // Initialize dates
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);
      final normalizedTestDay =
          DateTime(testDay.year, testDay.month, testDay.day, 0, 0, 0, 0);

      if (!normalizedTestDay.isAfter(today)) {
        if (kDebugMode) {
          print('Test day must be in the future');
        }
        return{};
        }


      // Schedule Mini-mocks
      if (selectedResources.contains('Mini-mocks')) {
        await _scheduleMiniMocks(
            firstStudyDay, normalizedTestDay, daysUntilTest, generatedEvents);
      }

      // Schedule Official papers
      if (selectedResources.contains('Official paper')) {
        final repetitions =
            (userData['selectedRepetition'] as num?)?.toInt() ?? 1;
        await _scheduleOfficialPapers(firstStudyDay, normalizedTestDay, daysUntilTest,
            repetitions, generatedEvents);
      }

      // Schedule Flashcards
      if (selectedResources.contains('Flashcards')) {
        
        await _scheduleFlashcards(
            user.uid, firstStudyDay, normalizedTestDay, daysUntilTest, generatedEvents);
      }

      if (selectedResources.contains("Full-sized mock exam")){
        final repetitions =
            (userData['selectedRepetition'] as num?)?.toInt() ?? 1;
            
        await _scheduleFullMocks( firstStudyDay, normalizedTestDay, daysUntilTest,
         repetitions, generatedEvents);
      }

      return generatedEvents;
    } catch (e) {
      if (kDebugMode) {
        print('Error generating study sessions: $e');
      }
      return {};
    }
  }

  /// Schedule mini-mock events
  Future<void> _scheduleMiniMocks(DateTime firstStudyDay, DateTime testDay,
      int daysUntilTest, Map<DateTime, List<Event>> generatedEvents) async {
    // First mini mock
    DateTime firstMockDate = DateTime(firstStudyDay.year,firstStudyDay.month,firstStudyDay.day,0,0,0,0);
    if (generatedEvents[firstMockDate] == null) {
      generatedEvents[firstMockDate] = [
        Event(title: "First Mini Mock", color: kMiniMockColor)
      ];
    }

    // Second mini mock halfway
    if (daysUntilTest > 3) {
      DateTime halfwayDate = firstStudyDay.add(Duration(days: daysUntilTest ~/ 2));
      halfwayDate = DateTime(halfwayDate.year,halfwayDate.month,halfwayDate.day,0,0,0,0);
      if (generatedEvents[halfwayDate] == null) {
        generatedEvents[halfwayDate] = [
          Event(title: "Second Mini Mock", color: kMiniMockColor)
        ];
      }
    }
  }

  /// Schedule full mock exam events
  Future<void> _scheduleFullMocks(
      DateTime firstStudyDay,
      DateTime testDay,
      int daysUntilTest,
      int repetitions,
      Map<DateTime, List<Event>> generatedEvents) async {
    repetitions = repetitions.clamp(1, 6);
    for (int i = 0; i < repetitions; i++) {
      int interval = ((daysUntilTest / 3) - 2 + (i * 4)).round();
      if (interval >= daysUntilTest) continue;

      DateTime mockExamDate = firstStudyDay.add(Duration(days: interval));
      mockExamDate = DateTime(mockExamDate.year,mockExamDate.month,mockExamDate.day,0,0,0,0);
     

      while (generatedEvents[mockExamDate] != null) {
         
        mockExamDate =  DateTime(mockExamDate.year,mockExamDate.month,mockExamDate.day+1,0,0,0,0);
      }
      if (testDay.isAfter(mockExamDate)){
      generatedEvents[mockExamDate] = [
          Event(title: "Full-sized Mock Exam ${i + 1}", color: kFullMockColor)
        ];
      
    }}
  }

  /// Schedule official paper events
  Future<void> _scheduleOfficialPapers(
      DateTime today,
      DateTime testDay,
      int daysUntilTest,
      int repetitions,
      Map<DateTime, List<Event>> generatedEvents) async {
    repetitions = repetitions.clamp(1, 6);
    for (int i = 0; i < repetitions; i++) {
      int interval = (daysUntilTest * i / repetitions).round();
      if (interval >= daysUntilTest) continue;

      DateTime officialPaperDate = today.add(Duration(days: interval));
      officialPaperDate = DateTime(officialPaperDate.year,officialPaperDate.month,officialPaperDate.day,0,0,0,0);

      while (generatedEvents[officialPaperDate] != null) {
         officialPaperDate = DateTime(officialPaperDate.year,officialPaperDate.month,officialPaperDate.day+1,0,0,0,0);
      }
      if(testDay.isAfter(officialPaperDate)){
          generatedEvents[officialPaperDate] = [
          Event(title: "Official Paper ${i + 1}", color: kOfficialPaperColor)
        ];
      }
    }
  }

  /// Schedule flashcard events
  Future<void> _scheduleFlashcards(
      String userId,
      DateTime today,
      DateTime testDay,
      int daysUntilTest,
      Map<DateTime, List<Event>> generatedEvents) async {
    try {
      final CollectionReference<Map<String, dynamic>> flashcards =
          FirebaseFirestore.instance.collection('flashcards');
      final List<String> topics = [];
      List<String> unscheduledTopics = [];

      // Collect seen flashcard topics
      final seenFlashcards = await Algo().getFlashcards(userId);
      for (final flashcard in seenFlashcards) {
       if(!unscheduledTopics.contains(flashcard["topic"])){
       unscheduledTopics.add(flashcard["topic"]);
            
            DateTime nextReviewDate =
                DateTime(today.year, today.month, today.day + 1, 0, 0, 0, 0);
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
          }}
        

      // Collect unseen flashcard topics
      final QuerySnapshot<Map<String, dynamic>> flashcardDeck =
          await flashcards.get();
      for (final doc in flashcardDeck.docs) {
        final Map<String, dynamic> flashcard = doc.data();
         if(!unscheduledTopics.contains(flashcard["topic"])){
         unscheduledTopics.add(flashcard["topic"]);

            DateTime nextReviewDate =
                DateTime(today.year, today.month, today.day + 1, 0, 0, 0, 0);
            if (daysUntilTest > 31 && daysUntilTest < 60) {
              while (generatedEvents[nextReviewDate] != null) {
                nextReviewDate = DateTime(nextReviewDate.year,
                    nextReviewDate.month, nextReviewDate.day + 1, 0, 0, 0, 0);
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
      }}

      

  
    } catch (e) {
      if (kDebugMode) {
        print('Error processing flashcards: $e');
      }
    }
  }

  /// Save generated events to the database
  Future<void> saveStudySessionsToDB(
      User user, Map<DateTime, List<Event>> events) async {
    try {
      final QuerySnapshot u =
          await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
      if (u.docs.isEmpty) {
        if (kDebugMode) {
          print('No user document found');
        }
        return;
      }

      final String id = u.docs.last.id;
      _eventsCollectionRef =
          FirebaseFirestore.instance.collection('users/$id/events');

      for (final date in events.keys) {
        final List<String> eventTitles =
            events[date]!.map((e) => e.title).toList();
        await _eventsCollectionRef.add({
          "date": date,
          "events": eventTitles,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving study sessions: $e');
      }
    }
  }

  /// Start a study session with selected resources
  void startStudySession(List<String> selectedResources) {
    try {
      if (selectedResources.isEmpty) {
        if (kDebugMode) {
          print('No resources selected for study session');
        }
        return;
      }

      if (kDebugMode) {
        print('Starting study session with resources: $selectedResources');
      }

      // TODO: Implement the study session logic
    } catch (e) {
      if (kDebugMode) {
        print('Error starting study session: $e');
      }
    }
  }
}
