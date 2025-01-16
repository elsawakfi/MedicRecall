import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/main.dart';
import 'package:flashcard_x/utils/algo.dart';
import 'feed_screen.dart';
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
    //var databaseFlashcards = await Algo().getFlashcards(user.uid); 
    DateTime testDay = querySnapshot.docs.last['TestDay'].toDate();
    // Get topics and related data from the database or pass them as arguments
    List<String>? selectedResources = await getSelectedResources(userId);
   
    int daysUntilTest =
        (testDay.difference(DateTime.now()).inHours / 24).round();
    // Loop through topics to generate study sessions
    
   CollectionReference<Map<String, dynamic>> flashcards =
      FirebaseFirestore.instance.collection('flashcards');

    // Get all documents in the collection
    QuerySnapshot<Map<String, dynamic>> flashcardDeck = await flashcards.get();
    // Iterate over each document
    
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in flashcardDeck.docs) {
        Map<String, dynamic> flashcard = doc.data();
        print(flashcard["topic"]);
        int topicCount = 0;
        List<String> containsTopic = [];
        if (containsTopic.contains(flashcard["topic"])){}
        else{
          
          print("\n");
        containsTopic.add(flashcard["topic"]);
        int daysToNextReviewDate = calculateDaysToNextReview(topicCount, flashcard["lastSeen"]);
         DateTime nextReviewDate =
          DateTime.now().add(Duration(days: daysToNextReviewDate));
       
       //For now will seperate events by at least one day, need to clarify with Dr. Harris how he wants flashcards to work 
       if (daysToNextReviewDate <= 1 ){
              DateTime now = DateTime.now();
              nextReviewDate = DateTime(now.year, now.month, now.day+2, 0, 0, 0, 0);
              while(generatedEvents[nextReviewDate]!=null){
                  nextReviewDate = DateTime(nextReviewDate.year, nextReviewDate.month, nextReviewDate.day+2, 0, 0, 0, 0);
       }
       }
       if (daysToNextReviewDate == 14 ){
              DateTime now = DateTime.now();
              nextReviewDate = DateTime(now.year, now.month, now.day+14, 0, 0, 0, 0);
              while(generatedEvents[nextReviewDate]!=null){
                  nextReviewDate = DateTime(nextReviewDate.year, nextReviewDate.month, nextReviewDate.day+2, 0, 0, 0, 0);
       }
       }
       else{
        while(generatedEvents[nextReviewDate]!=null){
                  nextReviewDate = DateTime(nextReviewDate.year, nextReviewDate.month, nextReviewDate.day+2, 0, 0, 0, 0);
       }}

       if (testDay.isAfter(nextReviewDate)){
        //Once a free day is used, the corresponding flashcard topic is added
        generatedEvents[nextReviewDate] = [];
        generatedEvents[nextReviewDate]!.add(Event(title: flashcard["topic"]+" Flashcards"));
       }   
    }}
      
      
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
    int daysToNextReviewDate = (((dateToColourMap[topicCount]!) + (lastSeen.seconds/86400)).toInt()) - Timestamp.now().seconds~/86400;
    if (daysSinceLastReview > 14){
      daysToNextReviewDate = 1;
      return daysToNextReviewDate;
    }
    else{
      return 14 - daysSinceLastReview;
    }
  
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
