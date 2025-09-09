import 'dart:math';
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
  static const Color kSJTPaperColor = Color.fromARGB(255, 255, 133, 58);

  // Firebase references
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  late CollectionReference _eventsCollectionRef;
  late List<(String,DateTime)> initialReviews = [];
  List<String> excludedDays = [];

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

  Future<void> getExcludedDays(String userId) async{
    try {
      QuerySnapshot querySnapshot =
          await _userCollectionRef.where("userID", isEqualTo: userId).get();
      if (querySnapshot.docs.isEmpty) return ;

      var userData = querySnapshot.docs.last.data() as Map<String, dynamic>;
      if (!userData.containsKey('excludedDays')) return ;
      excludedDays = List<String>.from(userData['excludedDays']);
      print(excludedDays);
    }
    catch (e) {
      if (kDebugMode) {
        print('Error checking excluded day: $e');
      }
  }}

  /// Helper function to check if a date falls on an excluded day
  Future<bool> _isExcludedDay(DateTime date, String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await _userCollectionRef.where("userID", isEqualTo: userId).get();
      if (querySnapshot.docs.isEmpty) return false;
      var userData = querySnapshot.docs.last.data() as Map<String, dynamic>;
      if (!userData.containsKey('excludedDays')) return false;
      String dayName = _getDayName(date.weekday);
      return excludedDays.contains(dayName);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking excluded day: $e');
      }
      return false;
    }
  }

  /// Helper function to convert weekday number to name
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

  /// Helper function to find the nearest available date for an event
  Future<DateTime> findNearestFreeDate(
      DateTime targetDate,
      int maxDaysToMove,
      DateTime testDay,
      DateTime today,
      Map<DateTime, List<Event>> generatedEvents,
      String userId,
      {int requiredSpacing = 0}) async {
    // First check if the target date is already available
    if ((generatedEvents[targetDate] == null &&
        (!await _isExcludedDay(targetDate, userId) || !excludedDays.contains(_getDayName(targetDate.weekday))))
        ||
        (requiredSpacing != 0 && !excludedDays.contains(_getDayName(targetDate.weekday)))) {
          //if it is for a flashcard review session, we aren't fussed about there being other events on that day
      return targetDate;
    }

    // Try to find a date forward (preferred direction)
    DateTime nextDate = targetDate;
    int daysForward = 0;
    while (nextDate.isBefore(testDay) && daysForward < maxDaysToMove) {
      nextDate = nextDate.add(const Duration(days: 1));
      daysForward++;
      
      // Check if this date respects both availability and required spacing
      if (generatedEvents[nextDate] == null &&
          (!await _isExcludedDay(nextDate, userId) || !excludedDays.contains(_getDayName(nextDate.weekday)))) {
        // If we need to maintain spacing, check adjacent days
        if (requiredSpacing > 0) {
          bool hasAdjacentEvent = false;
          
          // Check days before based on spacing
          for (int i = 1; i <= requiredSpacing; i++) {
            DateTime checkDate = nextDate.subtract(Duration(days: i));
            if (generatedEvents[checkDate] != null) {
              hasAdjacentEvent = true;
              break;
            }
          }
          
          // Check days after based on spacing
          if (!hasAdjacentEvent) {
            for (int i = 1; i <= requiredSpacing; i++) {
              DateTime checkDate = nextDate.add(Duration(days: i));
              if (checkDate.isAfter(testDay)) break;
              if (generatedEvents[checkDate] != null) {
                hasAdjacentEvent = true;
                break;
              }
            }
          }
          
          if (!hasAdjacentEvent) {
            return nextDate;
          }
          // Continue searching if this date doesn't meet spacing requirements
          continue;
        }
        
        return nextDate;
      }
    }

    // If no future date found within maxDaysToMove, try searching backward
    DateTime prevDate = targetDate;
    int daysBackward = 0;
    while (prevDate.isAfter(today) && daysBackward < maxDaysToMove) {
      prevDate = prevDate.subtract(const Duration(days: 1));
      daysBackward++;
      
      // Check if this date respects both availability and required spacing
      if (generatedEvents[prevDate] == null &&
          !await _isExcludedDay(prevDate, userId) && !excludedDays.contains(_getDayName(nextDate.weekday))) {
        // If we need to maintain spacing, check adjacent days
        if (requiredSpacing > 0) {
          bool hasAdjacentEvent = false;
          
          // Check days before based on spacing
          for (int i = 1; i <= requiredSpacing; i++) {
            DateTime checkDate = prevDate.subtract(Duration(days: i));
            if (checkDate.isBefore(today)) break;
            if (generatedEvents[checkDate] != null) {
              hasAdjacentEvent = true;
              break;
            }
          }
          
          // Check days after based on spacing
          if (!hasAdjacentEvent) {
            for (int i = 1; i <= requiredSpacing; i++) {
              DateTime checkDate = prevDate.add(Duration(days: i));
              if (generatedEvents[checkDate] != null) {
                hasAdjacentEvent = true;
                break;
              }
            }
          }
          
          if (!hasAdjacentEvent) {
            return prevDate;
          }
          // Continue searching if this date doesn't meet spacing requirements
          continue;
        }
        
        return prevDate;
      }
    }

    // If we reach here, try the start date itself as a last resort
    if (generatedEvents[today] == null &&
        !await _isExcludedDay(today, userId) && !excludedDays.contains(_getDayName(today.weekday))) {
      return today;
    }

    // If absolutely no valid date found, return the original target date
    // The calling methods will need to check if this date is actually usable
    return targetDate;
  }

  /// Helper function to get review interval based on study duration
  int getReviewInterval(int daysUntilTest) {
    if (daysUntilTest > 91) return 4; // Spacing coefficient of 4 for >91 days until exam
    if (daysUntilTest > 60) return 3;  // Spacing coefficient of 3 for 61-90 days until exam
    if (daysUntilTest > 30) return 2;   // Spacing coefficient of 2 for 31-60 days until exam
    return 1;  // Spacing coefficient of 1 for 0-30 days until exam
  }

  /// Generates study sessions based on user preferences and test date
  Future<Map<DateTime, List<Event>>> generateStudySessions(User user) async {
    await getExcludedDays(user.uid);
    try {
      Map<DateTime, List<Event>> generatedEvents = {};

      QuerySnapshot querySnapshot =
          await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
      var userId = querySnapshot.docs.last.id;
      final data = querySnapshot.docs.last.data() as Map<String,
          dynamic>; // Turn snapshot into a data type that can be searched to see if testDay exists
      if (!data.containsKey('TestDay')) return generatedEvents;
      DateTime testDay = querySnapshot.docs.last['TestDay'].toDate();
      testDay = DateTime(testDay.year,testDay.month,testDay.day,0,0,0,0);
      // Get topics and related data from the database or pass them as arguments
      List<String>? selectedResources = await getSelectedResources(userId);

      DateTime firstStudyDay =
          querySnapshot.docs.last['firstStudyDay'].toDate();

     firstStudyDay = DateTime(firstStudyDay.year,firstStudyDay.month,firstStudyDay.day,0,0,0,0);

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
        return {};
      }

      // Schedule Mini-mocks
      if (selectedResources.contains('Mini-mocks')) {
        await _scheduleMiniMocks(
            firstStudyDay, normalizedTestDay, daysUntilTest, generatedEvents);
      }

      // Schedule Official papers
      if (selectedResources.contains('Official MSRA Practice Paper')) {
        final repetitions =
            (userData['officialMSRARepetitions'] as num?)?.toInt() ?? 1;
        await _scheduleOfficialPapers(firstStudyDay, normalizedTestDay,
            daysUntilTest, repetitions, generatedEvents);
      }
      if (selectedResources.contains("Full-sized Mock Exam")) {
        final repetitions =
            (userData['fullSizedMockRepetitions'] as num?)?.toInt() ?? 1;

        await _scheduleFullMocks(firstStudyDay, normalizedTestDay,
            daysUntilTest, repetitions, generatedEvents);
      }

      if (selectedResources.contains("Official SJT Practice Paper")) {
        // Get the user's SJT repetitions setting
        int? sjtRepetitions;
        try {
          var userDataSnapshot = await _userCollectionRef
              .where("userID", isEqualTo: user.uid)
              .get();
          if (userDataSnapshot.docs.isNotEmpty) {
            var userData = userDataSnapshot.docs.first.data() as Map<String, dynamic>;
            if (userData.containsKey('sjtRepetitions')) {
              sjtRepetitions = userData['sjtRepetitions'] as int;
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error getting SJT repetitions: $e");
          }
        }
        
        // Ensure sjtRepetitions has been set by the user
        if (sjtRepetitions == null) {
          if (kDebugMode) {
            print("SJT repetition count not found in user data");
          }
          // Skip scheduling SJT papers if repetitions not specified
          return generatedEvents;
        }
        
        await _scheduleSJTPaper(
            firstStudyDay, normalizedTestDay, daysUntilTest, generatedEvents, sjtRepetitions);
      }

      // Schedule Flashcards
      if (selectedResources.contains('Flashcards')) {
        await _scheduleFlashcards(user.uid, today, normalizedTestDay,
            daysUntilTest, generatedEvents);
        
        await _scheduleAllFlashcards(userId, today, testDay, daysUntilTest, generatedEvents);
        
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
    final userId = auth.currentUser!.uid;

    // First mini mock - try to schedule on first study day
    DateTime firstMockDate = DateTime(
        firstStudyDay.year, firstStudyDay.month, firstStudyDay.day, 0, 0, 0, 0);

    // Only check for excluded day, don't look for nearest free date yet
    if (!await _isExcludedDay(firstMockDate, userId)) {
      // If first day is not excluded, use it
      if (generatedEvents[firstMockDate] == null) {
        generatedEvents[firstMockDate] = [
          Event(title: "First Mini Mock", color: kMiniMockColor)
        ];
      }
    } else {
      // If first day is excluded, then find nearest free date
      firstMockDate = await findNearestFreeDate(
          firstMockDate, 7, testDay, firstStudyDay, generatedEvents, userId);
      if (!firstMockDate.isAfter(testDay) &&
          !firstMockDate.isBefore(firstStudyDay) &&
          generatedEvents[firstMockDate] == null &&
          !await _isExcludedDay(firstMockDate, userId)) {
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
          halfwayDate, 7, testDay, firstStudyDay, generatedEvents, userId);

      if (!halfwayDate.isAfter(testDay) &&
          halfwayDate.isAfter(firstMockDate) &&
          generatedEvents[halfwayDate] == null &&
          !await _isExcludedDay(halfwayDate, userId)) {
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
    final userId = auth.currentUser!.uid;

    // Track last scheduled mock to maintain spacing
    DateTime? lastMockDate;

    for (int i = 1; i <= repetitions; i++) {
      int interval = (daysUntilTest * (i/ repetitions)).round() - 3;
      // Stop if we're too close to the test day
      //if (interval >= daysUntilTest - 2) continue;

      //Commented out the above as Dr. Harris does want this to be scheduled closer to the test day

      DateTime targetDate = DateTime(
          firstStudyDay.year, firstStudyDay.month, firstStudyDay.day+interval, 0, 0, 0, 0);



//NOT SURE ABOUT THE NECESSITY OF THE FOLLOWING FUNCTIONS ...
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
          maxDaysToMove, testDay, firstStudyDay, generatedEvents, userId);

      // Ensure mock is not on test day and at least 1 day before
      if (!mockExamDate.isAfter(testDay.subtract(const Duration(days: 1))) &&
          mockExamDate.isAfter(firstStudyDay) &&
          generatedEvents[mockExamDate] == null &&
          !await _isExcludedDay(mockExamDate, userId)) {
        generatedEvents[mockExamDate] = [
          Event(title: "Full-sized Mock Exam $i", color: kFullMockColor)
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
    final userId = auth.currentUser!.uid;

    // Track the last scheduled paper date to maintain proper spacing
    DateTime? lastPaperDate;

    

    for (int i = 1; i <= repetitions; i++) {
      // Calculate intervals to spread papers evenly, but ensure last paper is at least 2 days before test
      int interval = (daysUntilTest * (i / repetitions)).round() - 1;
      
      
      //if (interval >= daysUntilTest - 2) continue;
      //Again think we need to ignore this to adhere to Dr. Will's new algorithms
      


      DateTime targetDate = DateTime(
          today.year, today.month, today.day+interval, 0, 0, 0, 0);




  //NOT SURE ABOUT THE NEXT TWO BLOCKS OF CODE AS WELL ...
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
          targetDate, maxDaysToMove, testDay, today, generatedEvents, userId);

      // Ensure paper is not on test day and at least 1 day before
      if (!officialPaperDate
              .isAfter(testDay.subtract(const Duration(days: 1))) &&
          !officialPaperDate.isBefore(today) &&
          generatedEvents[officialPaperDate] == null &&
          !await _isExcludedDay(officialPaperDate, userId)) {
        generatedEvents[officialPaperDate] = [
          Event(
              title: "Official MSRA Practice Paper $i",
              color: kOfficialPaperColor)
        ];
        lastPaperDate = officialPaperDate;
      }
    }
  }

  Future<void> _scheduleSJTPaper(DateTime firstStudyDay, DateTime testDay,
    int daysUntilTest, Map<DateTime, List<Event>> generatedEvents,
    [int repetitions = 1]) async {
  final userId = auth.currentUser!.uid;

  // Calculate the minimum spacing between SJT papers based on study duration
  int minSpacing = max(7, daysUntilTest ~/ (repetitions * 2)); // At least 7 days apart
  
  // Track the last scheduled paper date to maintain proper spacing
  DateTime? lastPaperDate;
  
  for (int i = 0; i < repetitions; i++) {
    // Distribute papers evenly throughout the study period
    // For single paper, keep the 75% position, otherwise distribute evenly
    double position = repetitions == 1 
        ? 0.75 // Original 75% position for single paper
        : (i + 1) / (repetitions + 1); // Distribute evenly for multiple papers
        
    // Calculate target date based on position in study timeline
    DateTime targetDate = firstStudyDay.add(
        Duration(days: (daysUntilTest * position).round()));
    targetDate = DateTime(targetDate.year, targetDate.month, targetDate.day, 0, 0, 0, 0);
    
    // If this is not the first paper, ensure minimum spacing from the last one
    if (lastPaperDate != null) {
      // Ensure minimum spacing between papers
      if (targetDate.difference(lastPaperDate).inDays < minSpacing) {
        targetDate = lastPaperDate.add(Duration(days: minSpacing));
      }
    }
    
    // Check if the calculated date is excluded or already has an event
    if (await _isExcludedDay(targetDate, userId) ||
        generatedEvents.containsKey(targetDate)) {
      // Find the nearest available date
      targetDate = await findNearestFreeDate(
          targetDate, 7, testDay, firstStudyDay, generatedEvents, userId);
    }
    
    // Ensure the selected date is valid before scheduling
    if (!targetDate.isAfter(testDay) &&
        !targetDate.isBefore(firstStudyDay) &&
        !await _isExcludedDay(targetDate, userId) &&
        generatedEvents[targetDate] == null) {
      
      // Create numbered or single title based on repetitions
      String title = repetitions > 1 
          ? "Official SJT Practice Paper ${i+1}" 
          : "Official SJT Practice Paper";
          
      generatedEvents[targetDate] = [
        Event(title: title, color: kSJTPaperColor)
      ];
      
      // Update the last paper date
      lastPaperDate = targetDate;
    }
  }
}

  Future<void> _scheduleNextReviewForTopic(DateTime nextReviewDate,String userId,
      DateTime today,
      DateTime testDay,
      int daysUntilTest,
      Map<DateTime, List<Event>> generatedEvents,String topic) async{
                    // Only schedule if we found a valid date
                        if (!nextReviewDate.isAfter(testDay.subtract(const Duration(days: 1))) &&
                            nextReviewDate.isAfter(today) &&
                            !await _isExcludedDay(nextReviewDate, userId)) {
                          
                          generatedEvents.putIfAbsent(nextReviewDate, () => []);

                          if (!generatedEvents[nextReviewDate]!
                            .any((e) => e.title == "$topic Flashcards")) {
                            generatedEvents[nextReviewDate]!.add(
                            Event(title: "$topic Flashcards", color: kFlashcardColor),
                          );
                        }
                           
                            
                      }
  }

  Future<void> _scheduleFlashcards(
      String userId,
      DateTime today,
      DateTime testDay,
      int daysUntilTest,
      Map<DateTime, List<Event>> generatedEvents) async {
    try {
      final CollectionReference<Map<String, dynamic>> flashcards =
          FirebaseFirestore.instance.collection('flashcards');
          CollectionReference topicRef =
     FirebaseFirestore.instance.collection("topics");
    QuerySnapshot topicSnapshot = await topicRef.orderBy('order').get();

      // Get the required spacing between flashcard reviews based on study duration
      int requiredSpacing = getReviewInterval(daysUntilTest);
      if (kDebugMode) {
        print('Flashcard scheduling with days until test: $daysUntilTest');
        print('Required spacing between flashcards: $requiredSpacing days');
      }
      
      // First collect all topics that need to be scheduled
      Set<String> allTopics = {};
      for (var doc in topicSnapshot.docs){
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String topic = data['topic'];
        allTopics.add(topic);
      }
     
      // Schedule flashcards with consistent spacing
      DateTime currentTargetDate = today.add(const Duration(days: 1)); // Start one day after today
      
      for (var topic in allTopics) {
        // Skip if we're too close to the test day
        if (currentTargetDate.isAfter(testDay.subtract(const Duration(days: 1)))) {
          break;
        }
        
        // Find a suitable date that respects our spacing requirements
        DateTime scheduledDate = currentTargetDate;
        if(excludedDays.contains(_getDayName(scheduledDate.weekday))){
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        // Only schedule if we found a valid date
        if (!scheduledDate.isAfter(testDay.subtract(const Duration(days: 1))) &&
            scheduledDate.isAfter(today) &&
            !excludedDays.contains(_getDayName(scheduledDate.weekday))) {
            
          // Check if this date already has an event
          if (generatedEvents[scheduledDate] == null || generatedEvents[scheduledDate] != null) {
            generatedEvents.putIfAbsent(scheduledDate, () => []);
            generatedEvents[scheduledDate]!.add(
              Event(title: "$topic Flashcards", color: kFlashcardColor)
            );

            initialReviews.add((topic,scheduledDate));
           
            
            // Move to the next date with proper spacing
            currentTargetDate = scheduledDate.add(Duration(days: requiredSpacing + 1));
            
            if (kDebugMode) {
              // print('Scheduled $topic on ${scheduledDate.toIso8601String()}, next target: ${currentTargetDate.toIso8601String()}');
            }
          } else  {
            // This date already has another event, move to the next day
          
            currentTargetDate = scheduledDate.add(const Duration(days: 1));
            //  await findNearestFreeDate(
            //     currentTargetDate, 7, testDay, today, generatedEvents, userId,
            //     requiredSpacing: requiredSpacing);
          }
        } else {
          // If we couldn't find a date, move on to the next day
          currentTargetDate = currentTargetDate.add(const Duration(days: 1));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing flashcards: $e');
      }
    }
   
  }

  /// Schedule flashcard events
  Future<void> _scheduleAllFlashcards(
      String userId,
      DateTime today,
      DateTime testDay,
      int daysUntilTest,
      Map<DateTime, List<Event>> generatedEvents) async {
      List<int> spacing = [6,10,16,24,36];
      for (var tuple in initialReviews){
        DateTime nextReview = tuple.$2;
        for (int i in spacing){
          nextReview = nextReview.add(Duration(days: i));
          if(nextReview.isAfter(testDay) || nextReview.isAtSameMomentAs(testDay)){
            break;
          }
          else{
            if (excludedDays.contains(_getDayName(nextReview.weekday))){
              int separation = 1 + Random().nextInt(getReviewInterval(daysUntilTest));
              if(generatedEvents[nextReview.subtract(Duration(days:separation))] == null){
                nextReview = nextReview.subtract(Duration(days:separation));
              }
              else if(generatedEvents[nextReview.add(Duration(days:separation))] == null){
                   nextReview = nextReview.add(Duration(days:separation));
              }
              else{

              if(
              (generatedEvents[nextReview.subtract(Duration(days:separation))]!.length 
                <
              generatedEvents[nextReview.add(Duration(days:separation))]!.length)
                 || 
              generatedEvents[nextReview.subtract(Duration(days:separation))] == null){
                nextReview = nextReview.subtract(Duration(days:separation));
              }else{
              nextReview = nextReview.add(Duration(days:separation));
              }
              }}

            if(generatedEvents[nextReview] != null && generatedEvents[nextReview]!.length == 2){
            
             nextReview = nextReview.add(Duration(days:1));
                
            }
            generatedEvents.putIfAbsent(nextReview, () => []);

            if (!generatedEvents[nextReview]!
                .any((e) => e.title == "${tuple.$1} Flashcards")) {
              generatedEvents[nextReview]!.add(
                Event(title: "${tuple.$1} Flashcards", color: kFlashcardColor),
              );
            }
             
            }
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
