
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flashcard_x/utils/algo.dart';
import 'package:flashcard_x/widgets/event.dart';
import 'package:flutter/foundation.dart';

void main(){
   String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "";
    }
  }
  late Widget mockDialog; 
  Map<DateTime, List<Event>> generatedEvents = {};
  late Map<DateTime?, List<Event>> selectedEvents = {};
  List<String> selectedResources = [];
  int repetitions; 
  List <String>excluded = []; 
  DateTime today = DateTime.now();
  DateTime firstStudyDay = DateTime(today.year,today.month,today.day,0,0,0,0);
  DateTime testDay = DateTime(today.year,today.month+1,today.day,0,0,0,0); 
  setUp((){
    //Reset all the options that would be stored in the database
    selectedResources = [];
    excluded = [];
    generatedEvents = {};
    selectedEvents = {};
    repetitions = 0; 
  const Color kMiniMockColor = Color.fromARGB(255, 138, 201, 38);
  const Color kFullMockColor = Color.fromARGB(255, 120, 202, 210);
  const Color kOfficialPaperColor = Color.fromARGB(255, 163, 68, 174);
  // const Color kFlashcardColor = Color.fromARGB(255, 255, 202, 58);
  const Color kSJTPaperColor = Color.fromARGB(255, 255, 133, 58);
    Future<bool> _isExcludedDay(DateTime date, List<String> excludedDays) async {
      String dayName = _getDayName(date.weekday);
      return excludedDays.contains(dayName);
    }
  
    Future<DateTime> findNearestFreeDate(
      DateTime targetDate,
      int maxDaysToMove,
      DateTime testDay,
      DateTime today,
      Map<DateTime, List<Event>> generatedEvents) async {
    // Check if target date is valid
    if (generatedEvents[targetDate] == null &&
        !await _isExcludedDay(targetDate, excluded)) {
      return targetDate;
    }

    // First try searching forward from the target date
    DateTime nextDate = targetDate;
    while (nextDate.isBefore(testDay)) {
      nextDate = nextDate.add(const Duration(days: 1));
      if (generatedEvents[nextDate] == null &&
          !await _isExcludedDay(nextDate, excluded)) {
        return nextDate;
      }
    }

    // If no future date found, try searching backward
    DateTime prevDate = targetDate;
    while (prevDate.isAfter(today)) {
      prevDate = prevDate.subtract(const Duration(days: 1));
      if (generatedEvents[prevDate] == null &&
          !await _isExcludedDay(prevDate, excluded)) {
        return prevDate;
      }
    }

    // If we reach here, try the start date itself as a last resort
    if (generatedEvents[today] == null &&
        !await _isExcludedDay(today, excluded)) {
      return today;
    }

    // If absolutely no valid date found, return null to indicate failure
    return today; // The calling methods will check if this date is valid
  }
    Future<void> _scheduleMiniMocks(DateTime firstStudyDay, DateTime testDay,
      int daysUntilTest, Map<DateTime, List<Event>> generatedEvents) async {

    // First mini mock - try to schedule on first study day
    DateTime firstMockDate = DateTime(
        firstStudyDay.year, firstStudyDay.month, firstStudyDay.day, 0, 0, 0, 0);

    // Only check for excluded day, don't look for nearest free date yet
    if (!await _isExcludedDay(firstMockDate, excluded)) {
      // If first day is not excluded, use it
      if (generatedEvents[firstMockDate] == null) {
        generatedEvents[firstMockDate] = [
          Event(title: "First Mini Mock", color: kMiniMockColor)
        ];
      }
    } else {
      // If first day is excluded, then find nearest free date
      // firstMockDate = await findNearestFreeDate(
      //     firstMockDate, 7, testDay, firstStudyDay, generatedEvents);
      if (!firstMockDate.isAfter(testDay) &&
          !firstMockDate.isBefore(firstStudyDay) &&
          generatedEvents[firstMockDate] == null &&
          !await _isExcludedDay(firstMockDate, excluded)) {
        generatedEvents[firstMockDate] = [
          Event(title: "First Mini Mock", color: kMiniMockColor)
        ];
      }
    }

    // Second mini mock halfway through study period
    if (daysUntilTest > 3 && generatedEvents[firstMockDate] != null) {
      DateTime halfwayDate =
          firstStudyDay.add(Duration(days: daysUntilTest ~/ 2));
      halfwayDate = DateTime(
          halfwayDate.year, halfwayDate.month, halfwayDate.day, 0, 0, 0, 0);
      halfwayDate = await findNearestFreeDate(
          halfwayDate, 7, testDay, firstStudyDay, generatedEvents);

      if (!halfwayDate.isAfter(testDay) &&
          halfwayDate.isAfter(firstMockDate) &&
          generatedEvents[halfwayDate] == null &&
          !await _isExcludedDay(halfwayDate, excluded)) {
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
   

    // Track last scheduled mock to maintain spacing
    DateTime? lastMockDate;

    for (int i = 0; i < repetitions; i++) {
      // Calculate intervals to spread mocks evenly, but ensure last mock is at least 2 days before test
      int interval = (daysUntilTest * (i + 1) / (repetitions + 1)).round();

      // Stop if we're too close to the test day
      if (interval >= daysUntilTest - 2) continue;

      DateTime targetDate = firstStudyDay.add(Duration(days: interval));
      targetDate = DateTime(
          targetDate.year, targetDate.month, targetDate.day, 0, 0, 0, 0);

      // Ensure minimum spacing between mocks
      if (lastMockDate != null) {
        int minSpacing = (daysUntilTest / repetitions * 0.5).round();
        if (targetDate.difference(lastMockDate).inDays < minSpacing) {
          targetDate = lastMockDate.add(Duration(days: minSpacing));
        }
      }

      // Set max days to move to avoid getting too close to test day
      int maxDaysToMove =
          min(7, (testDay.difference(targetDate).inDays - 2).clamp(1, 7));
      DateTime mockExamDate = await findNearestFreeDate(targetDate,
          maxDaysToMove, testDay, firstStudyDay, generatedEvents);

      // Ensure mock is not on test day and at least 1 day before
      if (!mockExamDate.isAfter(testDay.subtract(const Duration(days: 1))) &&
          mockExamDate.isAfter(firstStudyDay) &&
          generatedEvents[mockExamDate] == null &&
          !await _isExcludedDay(mockExamDate, excluded)) {
        generatedEvents[mockExamDate] = [
          Event(title: "Full-sized Mock Exam ${i + 1}", color: kFullMockColor)
        ];
        lastMockDate = mockExamDate;
      }
    }
  }

  /// Schedule official paper events
  Future<void> _scheduleOfficialPapers(
      DateTime today,
      DateTime testDay,
      int daysUntilTest,
      int repetitions,
      Map<DateTime, List<Event>> generatedEvents) async {
    repetitions = repetitions.clamp(1, 6);
    

    // Track the last scheduled paper date to maintain proper spacing
    DateTime? lastPaperDate;

    for (int i = 0; i < repetitions; i++) {
      // Calculate intervals to spread papers evenly, but ensure last paper is at least 2 days before test
      int interval = (daysUntilTest * i / repetitions).round();
      if (interval >= daysUntilTest - 2) continue;

      DateTime targetDate = today.add(Duration(days: interval));
      targetDate = DateTime(
          targetDate.year, targetDate.month, targetDate.day, 0, 0, 0, 0);

      // If this is not the first paper, ensure minimum spacing from the last one
      if (lastPaperDate != null) {
        int minSpacing = (daysUntilTest / repetitions * 0.5)
            .round(); // At least half the ideal spacing
        if (targetDate.difference(lastPaperDate).inDays < minSpacing) {
          targetDate = lastPaperDate.add(Duration(days: minSpacing));
        }
      }

      // Set max days to move to avoid getting too close to test day
      int maxDaysToMove =
          min(7, (testDay.difference(targetDate).inDays - 2).clamp(1, 7));
      DateTime officialPaperDate = await findNearestFreeDate(
          targetDate, maxDaysToMove, testDay, today, generatedEvents);

      // Ensure paper is not on test day and at least 1 day before
      if (!officialPaperDate
              .isAfter(testDay.subtract(const Duration(days: 1))) &&
          !officialPaperDate.isBefore(today) &&
          generatedEvents[officialPaperDate] == null &&
          !await _isExcludedDay(officialPaperDate, excluded)) {
        generatedEvents[officialPaperDate] = [
          Event(
              title: "Official MSRA Practice Paper ${i+1}",
              color: kOfficialPaperColor)
        ];
        lastPaperDate = officialPaperDate;
      }
    }
  }

  

  Future<void> _scheduleSJTPaper(DateTime firstStudyDay, DateTime testDay,
      int daysUntilTest, Map<DateTime, List<Event>> generatedEvents) async {
    

    // Always schedule at 75% through the study period
    DateTime SJTDate =
        firstStudyDay.add(Duration(days: (daysUntilTest * 3 / 4).round()));
    SJTDate = DateTime(SJTDate.year, SJTDate.month, SJTDate.day, 0, 0, 0, 0);

    // Check if the calculated date is excluded
    if (await _isExcludedDay(SJTDate, excluded) ||
        generatedEvents.containsKey(SJTDate)) {
      // Find the nearest available date
      SJTDate = await findNearestFreeDate(
          SJTDate, 7, testDay, firstStudyDay, generatedEvents);
    }

    // Ensure the selected date is valid before scheduling
    if (!SJTDate.isAfter(testDay) &&
        !SJTDate.isBefore(firstStudyDay) &&
        !await _isExcludedDay(SJTDate, excluded) &&
        generatedEvents[SJTDate] == null) {
      generatedEvents[SJTDate] = [
        Event(title: "Official SJT Practice Paper", color: kSJTPaperColor)
      ];
    }
  }

  //Do not think we will be able to test flashcards... but will see. 

  // /// Schedule flashcard events
  // Future<void> _scheduleFlashcards(
  //     DateTime today,
  //     DateTime testDay,
  //     int daysUntilTest,
  //     Map<DateTime, List<Event>> generatedEvents) async {
  //   try {
  //     final CollectionReference<Map<String, dynamic>> flashcards =
  //         FirebaseFirestore.instance.collection('flashcards');
  //     List<String> unscheduledTopics = [];

  //     // Helper function to get review interval based on study duration
  //     int getReviewInterval(int daysUntilTest) {
  //       if (daysUntilTest >= 60) return 3;
  //       if (daysUntilTest >= 30) return 2;
  //       return 1;
  //     }

  //     // Schedule seen flashcards
  //     final seenFlashcards = await Algo().getFlashcards(userId);
  //     for (final flashcard in seenFlashcards) {
  //       if (!unscheduledTopics.contains(flashcard["topic"])) {
  //         unscheduledTopics.add(flashcard["topic"]);

  //         DateTime targetDate = DateTime(today.year, today.month,
  //             today.day + getReviewInterval(daysUntilTest), 0, 0, 0, 0);
  //         DateTime nextReviewDate = await findNearestFreeDate(
  //             targetDate, 7, testDay, today, generatedEvents);

  //         // Only schedule if we found a valid date that's not today (fallback)
  //         if (!nextReviewDate.isAfter(testDay) &&
  //             nextReviewDate.isAfter(today) &&
  //             generatedEvents[nextReviewDate] == null &&
  //             !await _isExcludedDay(nextReviewDate, excluded)) {
  //           generatedEvents[nextReviewDate] = [
  //             Event(
  //                 title: "${flashcard["topic"]} Flashcards",
  //                 color: kFlashcardColor)
  //           ];
  //         }
  //       }
  //     }

  //     // Schedule unseen flashcards
  //     final QuerySnapshot<Map<String, dynamic>> flashcardDeck =
  //         await flashcards.get();
  //     for (final doc in flashcardDeck.docs) {
  //       final Map<String, dynamic> flashcard = doc.data();
  //       if (!unscheduledTopics.contains(flashcard["topic"])) {
  //         unscheduledTopics.add(flashcard["topic"]);

  //         DateTime targetDate = DateTime(today.year, today.month,
  //             today.day + getReviewInterval(daysUntilTest), 0, 0, 0, 0);
  //         DateTime nextReviewDate = await findNearestFreeDate(
  //             targetDate, 7, testDay, today, generatedEvents);

  //         // Only schedule if we found a valid date that's not today (fallback)
  //         if (!nextReviewDate.isAfter(testDay) &&
  //             nextReviewDate.isAfter(today) &&
  //             generatedEvents[nextReviewDate] == null &&
  //             !await _isExcludedDay(nextReviewDate, excluded)) {
  //           generatedEvents[nextReviewDate] = [
  //             Event(
  //                 title: "${flashcard["topic"]} Flashcards",
  //                 color: kFlashcardColor)
  //           ];
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error processing flashcards: $e');
  //     }
  //   }
  // }
    Future<Map<DateTime, List<Event>>> generateStudySessions(List<String> selectedResources,
    DateTime firstStudyDay,
    DateTime testDay,
    int repetitions ) async {
      // print("Generating Study Session\n");
      Map<DateTime, List<Event>> generatedEvents = {};

      // Start study sessions from today (aka. the day u start study session)
      int daysUntilTest =
          (testDay.difference(firstStudyDay).inHours / 24).round();
      // Loop through topics to generate study sessions

      if (selectedResources.isEmpty) {
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
        return {};
      }

      // Schedule Mini-mocks
      if (selectedResources.contains('Mini-mocks')) {
        await _scheduleMiniMocks(
            firstStudyDay, normalizedTestDay, daysUntilTest, generatedEvents);
      }

      // Schedule Official papers
      if (selectedResources.contains('Official MSRA Practice Paper')) {
        await _scheduleOfficialPapers(firstStudyDay, normalizedTestDay,
            daysUntilTest, repetitions, generatedEvents);
      }

      // Schedule Flashcards
      // if (selectedResources.contains('Flashcards')) {
      //   await _scheduleFlashcards( firstStudyDay, normalizedTestDay,
      //       daysUntilTest, generatedEvents);
      // }

      if (selectedResources.contains("Full-sized Mock Exam")) {
        await _scheduleFullMocks(firstStudyDay, normalizedTestDay,
            daysUntilTest, repetitions, generatedEvents);
      }

      if (selectedResources.contains("Official SJT Practice Paper")) {
        await _scheduleSJTPaper(
            firstStudyDay, normalizedTestDay, daysUntilTest, generatedEvents);
      }

      return generatedEvents;
    }

    mockDialog = MaterialApp(
      home:StatefulBuilder(builder: (context, setState){
        return AlertDialog(
          title: const Text("Mock Generate Study Session Dialog"),
          content: Column(
            ),
          actions: [
            TextButton(
              key: const ValueKey("Generate Study Session"),
              onPressed: () async{
                  generatedEvents = await generateStudySessions(selectedResources, firstStudyDay, testDay, repetitions);
                  selectedEvents.addAll(generatedEvents);
              },
              child: const Text("Confirm")
            ),
          ],
        );
      }));


      
  });
  
  
  testWidgets("Empty selected resources generates no events", (WidgetTester tester) async{
      await tester.pumpWidget(mockDialog);
      await tester.pumpAndSettle();

      Event exam = Event(title: "Test Day", color: const Color.fromARGB(255, 255, 89, 94));
      selectedEvents[testDay] = [];
      selectedEvents[testDay]!.add(exam);

      final findConfirm = find.byKey(const ValueKey("Generate Study Session"));

      await tester.tap(findConfirm);
      await tester.pumpAndSettle();

      
      expect(generatedEvents.isEmpty,true);
      expect(selectedEvents.toString().contains("Test Day"),true);
      expect(selectedEvents.length == 1,true);
  });

  testWidgets("Selecting one resource only adds that one", (WidgetTester tester) async{
      await tester.pumpWidget(mockDialog);
      await tester.pumpAndSettle();
      repetitions = 2;

      Event exam = Event(title: "Test Day", color: const Color.fromARGB(255, 255, 89, 94));
      selectedEvents[testDay] = [];
      selectedEvents[testDay]!.add(exam);

      //Assume this is the only resource that the user selected from the countdown button
      selectedResources.add("Full-sized Mock Exam");

      final findConfirm = find.byKey(const ValueKey("Generate Study Session"));

      await tester.tap(findConfirm);
      await tester.pumpAndSettle();

      
      expect(generatedEvents.isEmpty,false);
      expect(generatedEvents.toString().contains("Full-sized Mock Exam"),true);
      expect(selectedEvents.toString().contains("Test Day"),true);
      expect(selectedEvents.length == 1+repetitions,true);
  });

  testWidgets("Mini mocks scheduled correctly",(WidgetTester tester) async{
      await tester.pumpWidget(mockDialog);
      await tester.pumpAndSettle();
      Event exam = Event(title: "Test Day", color: const Color.fromARGB(255, 255, 89, 94));
      selectedEvents[testDay] = [];
      selectedEvents[testDay]!.add(exam);
      final findConfirm = find.byKey(const ValueKey("Generate Study Session"));
      selectedResources.add("Mini-mocks");
      //This should add two mini mocks, one today and one halfway to the exam date
      await tester.tap(findConfirm);
      await tester.pumpAndSettle();
      
      DateTime normalised = DateTime(today.year,today.month,today.day,0,0,0,0);
      int daysUntilTest =
          (testDay.difference(normalised).inDays);
      DateTime halfwayDate = DateTime(normalised.year,normalised.month,(today.day+daysUntilTest~/2),0,0,0,0);
      expect(selectedEvents[normalised]?.first.title.contains("First Mini Mock"),true);
      expect(selectedEvents[halfwayDate]?.first.title.contains("Second Mini Mock"),true);
      expect(selectedEvents.length == 3, true); //Should have test day and two mini mocks 
  });

  testWidgets("Full mocks and Official papers based on repetitions variable",(WidgetTester tester) async{
      await tester.pumpWidget(mockDialog);
      await tester.pumpAndSettle();
      final findConfirm = find.byKey(const ValueKey("Generate Study Session"));
      repetitions = 3; 
      selectedResources = ["Official MSRA Practice Paper","Full-sized Mock Exam"];
      Event exam = Event(title: "Test Day", color: const Color.fromARGB(255, 255, 89, 94));
      selectedEvents[testDay] = [];
      selectedEvents[testDay]!.add(exam);
      await tester.tap(findConfirm);
      await tester.pumpAndSettle();
      expect(selectedEvents.length == 7,true); //3 mini mock, 3 official papers + 1 test day
      expect(selectedEvents.toString().contains("Official MSRA Practice Paper 3"),true);
      expect(selectedEvents.toString().contains("Official MSRA Practice Paper 2"),true);
      expect(selectedEvents.toString().contains("Official MSRA Practice Paper 1"),true);
      expect(selectedEvents.toString().contains("Full-sized Mock Exam 1"),true);
      expect(selectedEvents.toString().contains("Full-sized Mock Exam 2"),true);
      expect(selectedEvents.toString().contains("Full-sized Mock Exam 3"),true);
      expect(selectedEvents.toString().indexOf("Official MSRA Practice Paper 1"), 
      lessThan(selectedEvents.toString().indexOf("Official MSRA Practice Paper 2")));
      expect(selectedEvents.toString().indexOf("Official MSRA Practice Paper 2"), 
      lessThan(selectedEvents.toString().indexOf("Official MSRA Practice Paper 3")));
      expect(selectedEvents.toString().indexOf("Full-sized Mock Exam 1"), 
      lessThan(selectedEvents.toString().indexOf("Full-sized Mock Exam 2")));
      expect(selectedEvents.toString().indexOf("Full-sized Mock Exam 2"), 
      lessThan(selectedEvents.toString().indexOf("Full-sized Mock Exam 3")));
  });

  testWidgets("Excluded days have no events scheduled on them",(WidgetTester tester)async{
      await tester.pumpWidget(mockDialog);
      await tester.pumpAndSettle();
      final findConfirm = find.byKey(const ValueKey("Generate Study Session"));
      repetitions = 3; 
      excluded = ["Tuesday"];
      selectedResources = ["Official MSRA Practice Paper","Full-sized Mock Exam","Mini-mocks","Official SJT Practice Paper"];
      Event exam = Event(title: "Test Day", color: const Color.fromARGB(255, 255, 89, 94));
      selectedEvents[testDay] = [];
      selectedEvents[testDay]!.add(exam);
      await tester.tap(findConfirm);
      await tester.pumpAndSettle();
      DateTime iterate = DateTime(today.year,today.month,today.day,0,0,0,0);
      expect(selectedEvents.isNotEmpty,true);
      while(iterate.isBefore(testDay)){
        if (_getDayName(iterate.weekday) == excluded.first && iterate != testDay){
          expect(selectedEvents[iterate]?.isEmpty ,null);
        }
        iterate = iterate.add(Duration(days: 1));
      }
  });
  }
  