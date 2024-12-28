import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/widgets/event.dart';
import 'package:flutter/foundation.dart';
// import 'calendar_screen.dart';
// import 'button_screen.dart';

class StudySessionManager {
  final CollectionReference _userCollectionRef = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

  late CollectionReference _eventsCollectionRef;

  Future<List<String>?> getSelectedResources(String userId) async {
    try {
      DocumentSnapshot userDoc = await _userCollectionRef.doc(userId).get();
      if (userDoc.exists) {
        List<String> selectedResources = List<String>.from(userDoc['selectedResources']);
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

    QuerySnapshot querySnapshot = await _userCollectionRef
        .where("userID", isEqualTo: user.uid)
        .get();
    var userId = querySnapshot.docs.last.id;
    DateTime testDay = querySnapshot.docs.last['TestDay'].toDate();
    // Get topics and related data from the database or pass them as arguments
    var topicCount = querySnapshot.docs.last["topicCount"];
    var topicLastSeen = querySnapshot.docs.last["topicLastSeen"];
    List<String>? selectedResources = await getSelectedResources(userId);
    // String studyMaterial = querySnapshot.docs.last["studyMaterial"];

    int daysUntilTest =
        (testDay.difference(DateTime.now()).inHours / 24).round();
    // Loop through topics to generate study sessions
    for (var i = 0; i < topicCount.length; i++) {
      // Calculate when the topic should be revised next
      int daysToNextReviewDate =
          calculateDaysToNextReview(topicCount[i], topicLastSeen[i]);
      DateTime nextReviewDate =
          DateTime.now().add(Duration(days: daysToNextReviewDate));

      if (daysToNextReviewDate >= 0 &&
          testDay.isAfter(nextReviewDate)) {

       DateTime nextReview = DateTime(nextReviewDate.year, nextReviewDate.month, nextReviewDate.day, 0, 0, 0, 0);
      //If the user wants to use flashcards and the next review date is in the future but before the exam
      //the following code executes 
        if (selectedResources!.contains("Flashcards")){
       
       //This while loop searches for a day where the user has nothing else in their schedule
       // Idea: "I want to do flashcards on the weekends"
       while(generatedEvents[nextReview]!=null){
          nextReview = DateTime(nextReview.year, nextReview.month, nextReview.day+1, 0, 0, 0, 0);
       }

        //Once a free day is used, the corresponding flashcard topic is added
        generatedEvents[nextReview] = [];
        generatedEvents[nextReview]!.add(Event(title: "Flashcards for Topic ${i + 1}"));
        //Need to push the last seen to the database? Or do we wait for the user 
        //to actually do the flashcards before we add another study session?
       }    
      
    }
    }
    
    if (selectedResources!.contains('Mini-mocks')){
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);
      if (generatedEvents[today] == null) {
        generatedEvents[today] = [];
      }
      generatedEvents[today]!.add(Event(title: "First Mini Mock"));

      DateTime halfwayDate = testDay.subtract(Duration(days: (daysUntilTest / 2).round()));
      if (generatedEvents[halfwayDate] == null){
        generatedEvents[halfwayDate] = [];
      }
      generatedEvents[halfwayDate]!.add(Event(title: "Second Mini Mock"));
    }

    return generatedEvents;
  }

  int calculateDaysToNextReview(int topicCount, Timestamp lastSeen) {
    Map<int, int> dateToColourMap = {0: 1, 1: 2, 2: 4, 3: 8, 4: 16, 5: 32};
    int daysSinceLastReview = (Timestamp.now().seconds - lastSeen.seconds) ~/ (60 * 60 * 24);
    if (daysSinceLastReview > 30){
      return dateToColourMap[topicCount]! + 1;
    }
    return dateToColourMap[topicCount]! + daysSinceLastReview;

  }

  void startStudySession(List<String> selectedResources) {
    // Implement the logic to start the study session with the selected resources
  }

  // Save generated events to the database
  Future<void> saveStudySessionsToDB(User user, Map<DateTime, List<Event>> events) async {
    QuerySnapshot u = await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    String id = u.docs.last.id;

    _eventsCollectionRef = FirebaseFirestore.instance.collection('users/$id/events');
    for (var date in events.keys) {
      List<String> eventTitles = events[date]!.map((e) => e.title).toList();
      await _eventsCollectionRef.add({"date": date, "events": eventTitles});
    }
  }
}
