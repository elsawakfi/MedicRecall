import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/utils/algo.dart';
import 'package:flashcard_x/widgets/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        return List<Timestamp>.from(userDoc['topicLastSeen']);
      } else {
        if (kDebugMode) {
          print('User document does not exist');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving timestamps: $e');
      }
      return null;
    }
  }

  Future<List<String>?> getSelectedResources(String userId) async {
    try {
      DocumentSnapshot userDoc = await _userCollectionRef.doc(userId).get();
      if (userDoc.exists) {
        return List<String>.from(userDoc['selectedResources']);
      } else {
        if (kDebugMode) {
          print('User document does not exist');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving selected resources: $e');
      }
      return null;
    }
  }

  // Generate study sessions based on user data and test day
  Future<Map<DateTime, List<Event>>> generateStudySessions(User user) async {
    Map<DateTime, List<Event>> generatedEvents = {};

    QuerySnapshot querySnapshot =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    var userId = querySnapshot.docs.last.id;
    DateTime testDay = querySnapshot.docs.last['TestDay'].toDate();
    List<String>? selectedResources = await getSelectedResources(userId);

    int daysUntilTest = (testDay.difference(DateTime.now()).inHours / 24).round();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);

    // Helper function to find the nearest free date
    DateTime findNearestFreeDate(DateTime targetDate, int maxDaysToMove) {
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
      return targetDate; // Return original if no free date found
    }

    if (selectedResources!.contains('Mini-mocks')) {
      // First mini mock on today
      DateTime firstMockDate = today;
      firstMockDate = findNearestFreeDate(firstMockDate, 1); // Try to keep it close to today
      
      if (generatedEvents[firstMockDate] == null) {
        generatedEvents[firstMockDate] = [];
      }
      generatedEvents[firstMockDate]!.add(
          Event(title: "First Mini Mock", 
              color: Color.fromARGB(255, 138, 201, 38)));

      // Second mini mock halfway to test
      DateTime halfwayDate = DateTime(
          now.year, now.month, now.day + (daysUntilTest ~/ 2), 0, 0, 0, 0);
      halfwayDate = findNearestFreeDate(halfwayDate, 4); // More flexible with the halfway date
      
      if (generatedEvents[halfwayDate] == null) {
        generatedEvents[halfwayDate] = [];
      }
      generatedEvents[halfwayDate]!.add(
          Event(title: "Second Mini Mock", 
              color: Color.fromARGB(255, 138, 201, 38)));
    }

    if (selectedResources.contains('Full-sized mock exam')) {
      int repetitions = querySnapshot.docs.last['selectedRepetition'];

      List<int> intervals = [];
      for (int i = 0; i < repetitions; i++) {
        intervals.add(((daysUntilTest / 3) - 2 + (i * 4)).round());
      }

      for (int interval in intervals) {
        DateTime mockExamDate = DateTime(
            now.year, now.month, now.day + interval, 0, 0, 0, 0);
        mockExamDate = findNearestFreeDate(mockExamDate, 2); // Allow up to 2 days movement
        
        if (generatedEvents[mockExamDate] == null) {
          generatedEvents[mockExamDate] = [];
        }
        generatedEvents[mockExamDate]!.add(
            Event(title: "Full-sized Mock Exam ${intervals.indexOf(interval) + 1}",
                color: Color.fromARGB(255, 120, 202, 210)));
      }
    }

    if (selectedResources.contains('Official paper')) {
      // int repetitions = 3;
      int repetitions = querySnapshot.docs.last['selectedRepetition'];

      // get the days until the test + intervals
      List<int> intervals = [];
      for (int i = 0; i < repetitions; i++) {
        intervals.add((daysUntilTest * i / repetitions).round());
      }

      for (int interval in intervals) {
        DateTime officialPaperDate = DateTime(
            now.year, now.month, now.day + interval, 0, 0, 0, 0);
        officialPaperDate = findNearestFreeDate(officialPaperDate, 3); // Allow up to 3 days movement
        
        if (generatedEvents[officialPaperDate] == null) {
          generatedEvents[officialPaperDate] = [];
        }
        generatedEvents[officialPaperDate]!.add(
            Event(title: "Official Paper ${intervals.indexOf(interval) + 1}",
                color: Color.fromARGB(255, 163, 68, 174)));
      }
    }

    if (selectedResources.contains("Flashcards")) {
      try {
        final CollectionReference<Map<String, dynamic>> flashcards =
            FirebaseFirestore.instance.collection('flashcards');
        final List<String> contains = [];

        // Get all documents in the collection
        final QuerySnapshot<Map<String, dynamic>> flashcardDeck =
            await flashcards.get();
        
        // Handle previously seen flashcards first
        final seenFlashcards = await Algo().getFlashcards(user.uid);
        for (final flashcard in seenFlashcards) {
          if (!contains.contains(flashcard["topic"])) {
            contains.add(flashcard["topic"]);
            
            // Calculate initial review date
            DateTime nextReviewDate = DateTime(
                now.year, now.month, now.day, 0, 0, 0, 0);
            
            // Determine flexibility based on days until test
            int maxDaysToMove = 1; // Default to 1 day
            if (daysUntilTest > 60) {
              maxDaysToMove = 3;
            } else if (daysUntilTest > 31) {
              maxDaysToMove = 2;
            }
            
            // Find a free date within the allowed range
            nextReviewDate = findNearestFreeDate(nextReviewDate, maxDaysToMove);
            
            if (testDay.isAfter(nextReviewDate)) {
              generatedEvents[nextReviewDate] = [];
              generatedEvents[nextReviewDate]!.add(
                  Event(title: "${flashcard["topic"]} Flashcards",
                      color: Color.fromARGB(255, 255, 202, 58)));
            }
          }
        }

        // Handle unseen flashcards next
        for (final doc in flashcardDeck.docs) {
          final Map<String, dynamic> flashcard = doc.data();

          if (!contains.contains(flashcard["topic"])) {
            contains.add(flashcard["topic"]);
            
            // Calculate initial review date
            DateTime nextReviewDate = DateTime(
                now.year, now.month, now.day, 0, 0, 0, 0);
            
            // Determine flexibility based on days until test
            int maxDaysToMove = 1; // Default to 1 day
            if (daysUntilTest > 60) {
              maxDaysToMove = 3;
            } else if (daysUntilTest >= 30) {
              maxDaysToMove = 2;
            }
            
            // Find a free date within the allowed range
            nextReviewDate = findNearestFreeDate(nextReviewDate, maxDaysToMove);
            
            if (testDay.isAfter(nextReviewDate)) {
              generatedEvents[nextReviewDate] = [];
              generatedEvents[nextReviewDate]!.add(
                  Event(title: "${flashcard["topic"]} Flashcards",
                      color: Color.fromARGB(255, 255, 202, 58)));
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error processing flashcards: $e');
        }
      }
    }
    return generatedEvents;
  }

  // Save generated events to the database
  Future<void> saveStudySessionsToDB(
      User user, Map<DateTime, List<Event>> events) async {
    try {
      final QuerySnapshot u =
          await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
      final String id = u.docs.last.id;

      _eventsCollectionRef =
          FirebaseFirestore.instance.collection('users/$id/events');
          
      for (final date in events.keys) {
        final List<String> eventTitles = events[date]!.map((e) => e.title).toList();
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
}
