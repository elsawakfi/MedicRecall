import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../widgets/countdown_button.dart';
import 'dashboard_screen.dart';

// Internal imports
import 'landing_screen.dart';
import 'sign_in_screen.dart';
import 'study_session_manager.dart';
import 'minimock_landing.dart';
import 'quiz_choice_screen.dart';
import 'feed_screen.dart';  // Contains AboveEverything widget
import '../widgets/drawer_widget.dart';
import '../widgets/event.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';

/*
Important note for devs

testDay is a dateTime object that represents the user's test day
It is used for both UI display and database storage
*/

bool loading = true;

// List of topics for study sessions and MSRA exam preparation
// Format: "Main category - Specific topic" 
// Used for generating and categorizing study sessions
List<String> topicsList = [
  "Patient focus - Maintaining patient focus",
  "Patient focus - Driving",
  "Patient focus - Intimate examination",
  "Patient focus - DNACPR",
  "Patient focus - Mental capacity",
  "Acting within your remit - Breaking bad news",
  "Acting within your remit - Consent for procedures",
  "Acting within your remit - Bleep",
  "Acting within your remit - Discharge",
  "Acting within your remit - Jobs",
  "Acting within your remit - Who's who",
  "Commitment to professionalism - Social media",
  "Commitment to professionalism - Professional practice",
  "Commitment to professionalism - Staffing",
  "Commitment to professionalism - Maintaining patient-doctor boundaries",
  "Commitment to professionalism - Clinical incidents",
  "Coping with pressure - Managing workload",
  "Coping with pressure - High-pressure scenarios",
  "Coping with pressure - Apology",
  "Coping with pressure - Handover",
  "Effective communication",
  "Team working - Working with FY1 colleagues",
  "Team working - Working with seniors",
  "Team working - Working with the MDT",
  "Team working - Common teamworking scenarios",
  "Confidentiality - Confidentiality",
  "Confidentiality - Child protection rules"
];

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  CalendarStateO createState() => CalendarStateO();
}

class CalendarStateO extends State<Calendar> {
  final StudySessionManager studySessionManager = StudySessionManager();
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  late Map<DateTime?, List<Event>> selectedEvents;
  CalendarFormat format = CalendarFormat.month;
  DateTime? testDay = DateTime.now();
  DateTime selectedDay = DateTime(2020, 1, 1);
  DateTime focusedDay = DateTime.now();
  final DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final TextEditingController _eventController = TextEditingController();
  bool testDayBool = false;
  
  //The CalendarFormat variable format allows the user to change their view of the calendar, into weekly, biweekly and monthly.
  // for some reason, events need to have their time as being midnight to be shown on the calendar. So need to set the today constant to be midnight today.
  // therefore today isn't just datetime.now it is calibrated to midnight.
  List<String> daysOfTheWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> revisionDays = [];

  CalendarStateO() {
    selectedEvents = {};
  }

  late CollectionReference _eventsCollectionRef;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  //UI Functions:

  List<Event> _getEventsfromDay(DateTime date) {
    date = DateTime(date.year, date.month, date.day);
    return selectedEvents[date] ??
        []; // returns the events of a specified day, [] if empty.
  }

  // generates events for revision plan and places topics and dates in an array
  Future<void> generateEvents(DateTime testDay, User user) async {
    // Get the user's document
    QuerySnapshot querySnapshot = await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    if (querySnapshot.docs.isEmpty) return;

    var userDoc = querySnapshot.docs.last.data() as Map<String, dynamic>;
    var topicCount = userDoc["topicCount"] as List<dynamic>;
    var topicLastSeen = userDoc["topicLastSeen"] as List<dynamic>;
    var topics = userDoc["topics"] as List<dynamic>;

    if (topics.isEmpty || topicCount.isEmpty || topicLastSeen.isEmpty) return;

    int daysUntilTest = testDay.difference(today).inDays;

    for (int i = 0; i < topics.length; i++) {
      double howLongAgoRevisedDays = (Timestamp.now().seconds - topicLastSeen[i].seconds) / 86400;
      Map<int, int> dateToColourMap = {0: ((howLongAgoRevisedDays.toInt()*4)+1), 1: 2, 2: 4, 3: 8, 4: 16, 5: 32, 6: 64, 7: 128};

      int daysToNextReviewDate = (((dateToColourMap[topicCount[i]]!) + (topicLastSeen[i].seconds/86400)).toInt()) - Timestamp.now().seconds~/86400;
      DateTime nextReviewDateObject = today.add(Duration(days: daysToNextReviewDate));
      DateTime standardisedDate = DateTime(nextReviewDateObject.year, nextReviewDateObject.month, nextReviewDateObject.day);

      if (daysToNextReviewDate >= 0 && topicCount[i] > 0 && daysToNextReviewDate < daysUntilTest) {
        String topicTitle = topics[i]["topic"].toString();
        if (selectedEvents[standardisedDate] != null) {
          selectedEvents[standardisedDate]?.add(
            Event(
              title: topicTitle,
              color: StudySessionManager.kFlashcardColor  // Use flashcard color for topic events
            )
          );
        } else {
          selectedEvents[standardisedDate] = [
            Event(
              title: topicTitle,
              color: StudySessionManager.kFlashcardColor  // Use flashcard color for topic events
            )
          ];
        }
      }
    }

    // Add Test Day event with red color
    if (selectedEvents[testDay] == null) {
      selectedEvents[testDay] = [
        Event(title: "Test Day", color: const Color.fromARGB(255, 255, 89, 94))
      ];
    } else {
      selectedEvents[testDay]?.add(
        Event(title: "Test Day", color: const Color.fromARGB(255, 255, 89, 94))
      );
    }

    updateEventsToDB(user); // add these events to the database, so they can be pulled later on.
  }

  //Calls generateEvents and sets the state to rebuild the UI with changes
  Future<void> generateEventsUIChange(DateTime testDay) async {
    await generateEvents(testDay, user);
    setState(() {});
  }

  Future<void> generateStudySessions(User user) async {
    try {
      // Get user document to check for selected resources
      QuerySnapshot userSnapshot = await _userCollectionRef
          .where("userID", isEqualTo: user.uid)
          .get();
          
      if (userSnapshot.docs.isEmpty) {
        print("No user document found for generating study sessions");
        return;
      }
      
      var userDoc = userSnapshot.docs.last.data() as Map<String, dynamic>;
      
      // Check if user has selected resources
      if (!userDoc.containsKey("selectedResources") || 
          !(userDoc["selectedResources"] is List) ||
          (userDoc["selectedResources"] as List).isEmpty) {
        print("No resources selected for study sessions");
        return;
      }
      
      // Generate study sessions using StudySessionManager
      var studySessions = await studySessionManager.generateStudySessions(user);
      
      if (studySessions.isNotEmpty) {
        // Merge new study sessions with existing events
        setState(() {
          for (var entry in studySessions.entries) {
            // Normalize date to avoid time comparison issues
            DateTime normalizedDate = DateTime(
              entry.key.year, entry.key.month, entry.key.day);
              
            if (selectedEvents.containsKey(normalizedDate)) {
              // Filter out any duplicate events
              List<Event> newEvents = entry.value.where((newEvent) => 
                !selectedEvents[normalizedDate]!.any((existingEvent) => 
                  existingEvent.title == newEvent.title)).toList();
                  
              selectedEvents[normalizedDate]!.addAll(newEvents);
            } else {
              selectedEvents[normalizedDate] = entry.value;
            }
          }
        });
        
        // Save to database
        await studySessionManager.saveStudySessionsToDB(user, studySessions);
        
        // Also update events in our Firebase events collection
        await updateEventsToDB(user);
        
        print("Successfully generated and saved ${studySessions.length} study session days");
      } else {
        print("No study sessions were generated");
      }
    } catch (e) {
      print("Error in generateStudySessions: $e");
    }
  }

  // DATABASE FUNCTIONS:
  Future<void> getUser() async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth.authStateChanges().first;
      if (tmp == null) {
        nav.push(MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ));
      } else {
        user = tmp;
      }
    } else {
      user = auth.currentUser!;
    }
  }

  // We pull the testDay if its in the database to be updated in the calendar UI
  Future<void> getTestDay() async {
    try {
      QuerySnapshot querySnapshot =
          await _userCollectionRef.where("userID", isEqualTo: user.uid).get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          testDayBool = true;
          testDay = null;
        });
        return;
      }

      var userFromDb = querySnapshot.docs.first;
      Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
      
      // Check if TestDay exists in Firestore document
      if (data.containsKey("TestDay") && data["TestDay"] != null) {
        setState(() {
          testDayBool = false;
          testDay = DateTime.fromMicrosecondsSinceEpoch(data["TestDay"].microsecondsSinceEpoch);
        });
      } else {
        // No test day in database
        setState(() {
          testDayBool = true;
          testDay = null;
        });
      }
    } catch (e) {
      print("Error retrieving test day: $e");
      setState(() {
        testDayBool = true;
        testDay = null;
      });
    }
  }

  //with UTD we want to update the date on the calendar, and change in firebase
  Future<void> updateTestDay(DateTime date) async {
    // Normalize both dates to avoid time-based mismatches
    date = DateTime(date.year, date.month, date.day);
    if (testDay != null) {
      testDay = DateTime(testDay!.year, testDay!.month, testDay!.day);
    }

    // Remove test day event from all dates to prevent duplicates
    selectedEvents.forEach((key, events) {
      events.removeWhere((event) => event.title == "Test Day");
      if (events.isEmpty) {
        selectedEvents.remove(key);
      }
    });

    // Update Firebase
    QuerySnapshot u = await _userCollectionRef.where("userID", isEqualTo: user?.uid).get();
    var id = u.docs.last.id;
    await _userCollectionRef.doc(id).update({
      "TestDay": date,
    });

    // Update local test day
    testDay = date;

    // Add test day event to the new date
    if (!selectedEvents.containsKey(date)) {
      selectedEvents[date] = [];
    }
    selectedEvents[date]?.add(
      Event(title: "Test Day", color: const Color.fromARGB(255, 255, 89, 94))
    );

    // Update events in Firebase
    await updateEventsToDB(user);

    // Update the focused day to show the new test day
    setState(() {
      focusedDay = date;
      selectedDay = date;
    });

    // Rebuild the entire screen to refresh countdown button
    if (context.mounted) {
      // Use a microtask to ensure state updates are complete
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const Calendar(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      });
    }
  }

  //updates the UI with the events collected from firebase
  Future<void> getEventsFromDB() async {
    try {
      QuerySnapshot u = await _userCollectionRef
          .where("userID", isEqualTo: user.uid)
          .get();
      
      if (u.docs.isEmpty) {
        print("No user document found!");
        return;
      }

      String id = u.docs.last.id;      
      _eventsCollectionRef =
          FirebaseFirestore.instance.collection('users/$id/events');

      var snapshots = await _eventsCollectionRef.get();
      
      // Clear existing events first to prevent duplicates
      selectedEvents.clear();
      
      for (var doc in snapshots.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('date') && data.containsKey('events')) {
          Timestamp? timestamp = data['date'] as Timestamp?;
          List<dynamic>? eventsList = data['events'] as List<dynamic>?;
          
          if (timestamp != null && eventsList != null) {
            DateTime date = timestamp.toDate();
            date = DateTime(date.year, date.month, date.day);
            
            // Filter out any existing Test Day events from the database
            eventsList.removeWhere((title) => title.toString() == "Test Day");
            
            List<String> events = eventsList.map((e) => e.toString()).toList();
            selectedEvents[date] = events.map((title) => Event(
              title: title,
              color: _getEventColor(title),
            )).toList();
          }
        }
      }

      // Add Test Day event if testDay is set
      if (testDay != null && !testDayBool) {
        DateTime normalizedTestDay = DateTime(testDay!.year, testDay!.month, testDay!.day);
        if (!selectedEvents.containsKey(normalizedTestDay)) {
          selectedEvents[normalizedTestDay] = [];
        }
        if (!selectedEvents[normalizedTestDay]!.any((e) => e.title == "Test Day")) {
          selectedEvents[normalizedTestDay]!.add(
            Event(title: "Test Day", color: const Color.fromARGB(255, 255, 89, 94))
          );
        }
      }
      
      // Force update UI
      setState(() {});
      
      print("Events loaded from database: ${selectedEvents.length} dates");
    } catch (e) {
      print("Error getting events from database: $e");
    }
  }

  Color _getEventColor(String title)  {
    List <String> flashcards = [
      "Team working",
      "Effective communication",
      "Acting within your remit",
      "Patient focus",
      "Commitment to professionalism",
      "Coping with pressure",
      "Confidentiality"
    ];
    if (title == "Test Day") return const Color.fromARGB(255, 255, 89, 94);
    if (title.contains("Mini Mock")) return StudySessionManager.kMiniMockColor;
    if (title.contains("Full-sized Mock")) return StudySessionManager.kFullMockColor;
    if (title.contains("Official MSRA Paper")) return StudySessionManager.kOfficialPaperColor;
    if (title.contains("Official SJT Practice Paper")) return StudySessionManager.kSJTPaperColor;
    
    for (String flashcard in flashcards){
        if(title.contains(flashcard)) return StudySessionManager.kFlashcardColor;
      }
    
    return Color.fromARGB(200, 0, 0, 100);
  }

  //When creating a new revision plan we update the database with the revision topics and dates in the calendar
  Future<void> updateEventsToDB(User user) async {
    for (var entry in selectedEvents.entries) {
      DateTime normalizedDate =
          DateTime(entry.key!.year, entry.key!.month, entry.key!.day);

      // Convert events to a list of strings
      List<String> updatedEvents = entry.value.map((e) => e.title).toList();

      if (updatedEvents.isEmpty) {
        await deleteSingleEvent(normalizedDate, "", user);
      } else {
        QuerySnapshot querySnapshot = await _eventsCollectionRef
            .where("date", isEqualTo: Timestamp.fromDate(normalizedDate))
            .get();

        if (querySnapshot.docs.isEmpty) {
          await _eventsCollectionRef.add({
            "date": Timestamp.fromDate(normalizedDate),
            "events": updatedEvents,
          });
        } else {
          String docId = querySnapshot.docs.first.id;
          await _eventsCollectionRef
              .doc(docId)
              .update({"events": updatedEvents});
        }
      }
    }
    setState(() {});
  }

  String _getEventType(String title) {
    title = title.toLowerCase();
    
    // The 5 main event types - using contains() to be more flexible
    if (title.contains('mini mock')) {
      return "mini_mock";
    }
    if (title.contains('full-sized mock') || title.contains('full mock')) {
      return "full_mock";
    }
    if (title.contains('flashcard')) {
      return "flashcard";
    }
    if (title.contains('official MSRA paper')) {
      return "official_MSRA_paper";
    }
    if (title.contains('official sjt practice paper')) {
      return "official_sjt_paper";
    }
    if (title.contains('test day')) {
      return "test_day";
    }
    // If it's not one of the 5 main events, show "feature not available"
    return "unknown";
  }

  void _showTestDayInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Your MSRA Test Day',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test Date: ${DateFormat('EEEE, MMMM d, y').format(testDay!)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Important Tips:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text('• Get a good night\'s sleep before the exam'),
                const Text('• Arrive at the test center 30 minutes early'),
                const Text('• Bring valid photo ID and test confirmation'),
                const Text('• No phones or electronic devices allowed'),
                const SizedBox(height: 20),
                const Text(
                  'Test Format:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text('• Professional Dilemma (PD): 95 minutes'),
                const Text('• Clinical Problem Solving (CPS): 75 minutes'),
                const Text('• Total questions: 188 (PD: 98, CPS: 90)'),
                const SizedBox(height: 20),
                const Text(
                  'Last-Minute Preparation:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text('• Review your weakest topics'),
                const Text('• Practice time management'),
                const Text('• Focus on understanding question patterns'),
                const Text('• Stay calm and confident!'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToEventDetails(Event event) async {
    String eventType = _getEventType(event.title);

    if (eventType == 'official_MSRA_paper') {
      final String url = 'https://medical.hee.nhs.uk/medical-training-recruitment/medical-specialty-training/publications/multi-specialty-recruitment-assessment-%28msra%29-practice-paper/section-1--professional-dilemma-pd';
      try {
        if (!await launcher.launch(url)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open the official MSRA paper website'),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the official MSRA paper website'),
            ),
          );
        }
      }
    } else if (eventType == 'official_sjt_paper'){
      final String url = 'https://foundationprogramme.nhs.uk/programmes/f2-stand-alone/f2sa2025-sjt/preparation-materials/';
      try {
        if (!await launcher.launch(url)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open the Official SJT Paper website'),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the Official SJT Paper website'),
            ),
          );
        }
      }
    } else if (eventType == 'mini_mock') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MiniMockLanding()),
      );
    } else if (eventType == 'flashcard') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(title: 'Dashboard'),
        ),
      );
    } else if (eventType == 'test_day') {
      _showTestDayInfoDialog();
    } else if (eventType == 'full_mock') {
      _showFeatureNotAvailableDialog(
        'Feature Not Available',
        'Full-sized mock feature is not available yet.',
      );
    } else {
      _showFeatureNotAvailableDialog(
        'Unknown Event Type',
        'This event type is not recognized.',
      );
    }
  }

  void _showFeatureNotAvailableDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE6EDF2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color.fromRGBO(21, 58, 103, 1),
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Color.fromRGBO(21, 58, 103, 1),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(243, 90, 90, 1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45),
            ),
            child: const Text(
              'Close',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  //deletes all events and testDay in UI calendar and firebase
  Future<void> deleteAllEvents() async {
    // Clear all events from local state
    selectedEvents.clear();

    // Get user document
    QuerySnapshot u =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    
    if (u.docs.isEmpty) {
      print("No user document found!");
      return;
    }
    
    String id = u.docs.last.id;
    
    // Setup events collection reference
    _eventsCollectionRef = FirebaseFirestore.instance.collection('users/$id/events');
    
    // Delete all event documents
    var snapshots = await _eventsCollectionRef.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    // Get user data for updates
    var userFromDb = u.docs.first;
    Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Update operations for Firestore
    Map<String, dynamic> updates = {};
    
    // Remove TestDay
    if (data.containsKey("TestDay") || data["TestDay"] != null) {
      updates["TestDay"] = FieldValue.delete();
    }
    
    // Clear excluded days
    if (data.containsKey("excludedDays") || data["excludedDays"] != null) {
      updates["excludedDays"] = [];
      // Also clear local state
      setState(() {
        revisionDays = [];
      });
    }
    
    // Apply all updates at once
    if (updates.isNotEmpty) {
      await users.doc(id).update(updates);
    }

    // Reset test day locally
    testDay = null;
    testDayBool = true;
    
    // Clear any lingering events
    if (u.docs.isNotEmpty) {
      String docID = u.docs.first.id;
      try {
        await _eventsCollectionRef.doc(docID).update({"events": []});
      } catch (e) {
        print("Error clearing events: $e");
      }
    }
    
    // Update UI
    setState(() {});
  }

  Future<void> initializeUserAndTestDay() async {
    await getUser();
    await getTestDay();
    await _loadExcludedDays(); // Load excluded days from Firebase
    
    // Only proceed with test day handling if a test day exists
    if (testDay != null && !testDayBool) {
      await getEventsFromDB(); // Then load events from database
      
      // First add Test Day event if not already present
      DateTime normalizedTestDay = DateTime(testDay!.year, testDay!.month, testDay!.day);
      if (!selectedEvents.containsKey(normalizedTestDay)) {
        selectedEvents[normalizedTestDay] = [];
      }
      
      // Check if the Test Day event already exists
      bool testDayEventExists = false;
      if (selectedEvents[normalizedTestDay] != null) {
        testDayEventExists = selectedEvents[normalizedTestDay]!.any((event) => event.title == "Test Day");
      }
      
      if (!testDayEventExists) {
        selectedEvents[normalizedTestDay]!.add(
          Event(title: "Test Day", color: const Color.fromARGB(255, 255, 89, 94))
        );
      }
      
      // Check for study sessions by examining event titles
      bool hasStudySessions = false;
      for (var events in selectedEvents.values) {
        for (var event in events) {
          if (event.title.contains("Mini Mock") || 
              event.title.contains("Full-sized Mock") || 
              event.title.contains("Official MSRA Paper") ||
              event.title.contains("Flashcard")) {
            hasStudySessions = true;
            break;
          }
        }
        if (hasStudySessions) break;
      }
      
      // If no study sessions found, try to generate them
      if (!hasStudySessions) {
        try {
          await generateStudySessions(user);
        } catch (e) {
          print("Error generating study sessions: $e");
        }
      }

      setState(() {});
    } else {
      // No test day is set or test day was deleted
      await getEventsFromDB(); // Still load other events if any
      setState(() {});
    }
  }

  Future<void> _loadStudySessions() async {
    StudySessionManager studySessionManager = StudySessionManager();
    User user = FirebaseAuth.instance.currentUser!;
    // DateTime testDay = DateTime.now().add(Duration(days: 30)); // Example test day

    Map<DateTime, List<Event>> events =
        await studySessionManager.generateStudySessions(user);
    setState(() {
      selectedEvents.addAll(events);
    });
    // add to database
    await studySessionManager.saveStudySessionsToDB(user, events);
  }

  Future<void> _loadTopicsList() async {
    if (auth.currentUser == null) return;

    var querySnapshot = await _userCollectionRef
        .where("userID", isEqualTo: auth.currentUser!.uid)
        .get();
    
    if (querySnapshot.docs.isEmpty) return;

    var userDoc = querySnapshot.docs.last.data() as Map<String, dynamic>;
    var topics = userDoc["topics"] as List<dynamic>;

    setState(() {
      topicsList = topics.map((topic) => topic["topic"].toString()).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    selectedEvents = {};
    initializeUserAndTestDay();
  }

  @override
  void dispose() {
    _eventController
        .dispose(); // when page is closed, event controller disposes of the unadded events.
    super.dispose();
  }

  // generate events is simple function which will iterate through the events list, adding them into the calendar. giving a rudimentary schedule for the user
  // this will be altered after the introduction of the algo, at which point we can refine the function to be more specific to that user.

  //maybe make testDay string be default string, then set state to be a string returned from firebase
  // so get object from databse, then .toString or as String

  // Helper function to get day name
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

  // helper function for adding new events
  void _showAddEventDialog(BuildContext context)  {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Event"),
        content: TextFormField(controller: _eventController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(243, 90, 90, 1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45), // Sets minimum width and height
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_eventController.text.isNotEmpty) {

                
                await addSingleEvent(selectedDay, _eventController.text, user);
                updateEventsToDB(user);
                Navigator.pop(context);
                _eventController.clear();
                setState(() {});
              
            }},
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45), // Sets minimum width and height
            ),
            child: const Text(
              "Add Event",
              style: TextStyle(fontSize: 16),
            ),
          ),

        ],
      ),
    );
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    //waits for build function to complete and then calls back to call the condition checking function 
    WidgetsBinding.instance.addPostFrameCallback((_){
     getEventsFromDB();
     setState((){});
    });
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawMain(),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 60,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu),
          ),
        ),
        title: Stack(
          children: [
            // Centered logo and title
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/newlogo.png',
                    fit: BoxFit.cover,
                    height: 34, // Adjust logo size as needed
                  ),
                  const SizedBox(width: 8), // Spacing between logo and title
                  const Text(
                    'Revision Calendar',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Labels section (Left side of the page)
          Expanded(
            flex: 1,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(40, 33, 33, 33),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Labels',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildLabelItem(
                      'Custom Events', Color.fromARGB(200, 0, 0, 100)),
                  SizedBox(height: 30),
                  _buildLabelItem(
                      'Mini Mock', StudySessionManager.kMiniMockColor),
                  SizedBox(height: 30),
                  _buildLabelItem(
                      'Full-sized Mock', StudySessionManager.kFullMockColor),
                  SizedBox(height: 30),
                  _buildLabelItem('Official MSRA Paper',
                      StudySessionManager.kOfficialPaperColor),
                  SizedBox(height: 30),
                  _buildLabelItem(
                      'Flashcards', StudySessionManager.kFlashcardColor),
                  SizedBox(height: 30),
                  _buildLabelItem(
                      'Official SJT Paper', StudySessionManager.kSJTPaperColor),
                  SizedBox(height: 30),
                  _buildLabelItem(
                      'Test Day', const Color.fromARGB(255, 255, 89, 94)),
                  
                ],
              ),
            ),
          ),
          // Vertical Divider (the line between the calendar and the label)
          Container(
            width: 2,
            color: Colors.grey[400],
            height: double.infinity,
          ),
          // Right side of the page -> Calendar, EventsList and Buttons
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // Calendar and Events List
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: TableCalendar(
                            firstDay: DateTime(2023),
                            lastDay: DateTime(2026),
                            focusedDay: focusedDay,
                            calendarFormat: format,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            daysOfWeekVisible: true,
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                color: Colors.blue[600],
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: const BoxDecoration(
                                color: Color.fromARGB(255, 13, 71, 161),
                                shape: BoxShape.circle,
                              ),
                              selectedTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              defaultTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              weekendTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              outsideTextStyle: TextStyle(
                                color: Colors.grey[500],
                              ),
                              disabledTextStyle: TextStyle(
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.grey[400],
                                decorationThickness: 2,
                              ),
                              markersMaxCount: 6,
                              markersAnchor: 1.0,
                              cellPadding: const EdgeInsets.all(8.0),
                              cellMargin: const EdgeInsets.all(4.0),
                            ),
                            enabledDayPredicate: (day) {
                              // Always enable the test day, regardless of exclusion settings
                              if (testDay != null) {
                                DateTime normalizedTestDay = DateTime(testDay!.year, testDay!.month, testDay!.day);
                                DateTime normalizedDay = DateTime(day.year, day.month, day.day);
                                if (isSameDay(normalizedTestDay, normalizedDay)) {
                                  return true;  // Always enable the test day
                                }
                              }
                              
                              // For other days, apply normal exclusion rules
                              final dayName = _getDayName(day.weekday);
                              return !revisionDays.contains(dayName);
                            },
                            onFormatChanged: (CalendarFormat _format) {
                              setState(() {
                                format = _format;
                              });
                            },
                            onDaySelected: (DateTime selectDay, DateTime focusDay) {
                              setState(() {
                                selectedDay = selectDay;
                                focusedDay = focusDay;
                              });
                            },
                            selectedDayPredicate: (DateTime date) {
                              return isSameDay(selectedDay, date);
                            },
                            eventLoader: _getEventsfromDay,
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                if (events.isEmpty) return null;
                                return Positioned(
                                  bottom: 2,
                                  child: Container(
                                    width: 60,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: events.take(3).map((event) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 1),
                                          width: 18,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(1.5),
                                            color: (event as Event).color,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),headerStyle: HeaderStyle(
                              titleTextStyle: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .white, // Changed to white for dark mode
                              ),
                              formatButtonTextStyle: TextStyle(
                                color: Colors
                                    .white, // Changed to white for dark mode
                                fontWeight: FontWeight.w600,
                              ),
                              // Add padding to the header
                              headerPadding:
                                  EdgeInsets.symmetric(vertical: 16.0),
                              // Make the format button more modern
                              formatButtonDecoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: Colors.white),
                              ),
                              // center title is removed so the main title doesn't look like it's not in the center
                              // Add margin to the header
                              headerMargin: EdgeInsets.only(bottom: 15.0),
                              // Enable left and right arrows
                              leftChevronVisible: true,
                              rightChevronVisible: true,
                              // Style the arrows
                              leftChevronIcon: Icon(Icons.chevron_left,
                                  size: 30, color: Colors.blue[300]),
                              rightChevronIcon: Icon(Icons.chevron_right,
                                  size: 30, color: Colors.blue[300]),
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              // Style for weekday names
                              weekdayStyle: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                color: Colors
                                    .white, // Changed to white for dark mode
                              ),
                              // Style for weekend names
                              weekendStyle: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                color: Colors.grey[
                                    400], // Changed to white for dark mode
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        ..._getEventsfromDay(selectedDay).map(
                          //This block of code will need to be re run if we are to have live updates, 
                          //This is necessary for both the add and edit event functions 
                          (Event event) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                event.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: event.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              tileColor: event.color.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.white),
                                    onPressed: () =>
                                        _editEventDate(context, event),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: Icon(Icons.link, color: Colors.white),
                                    onPressed: () =>
                                        _navigateToEventDetails(event),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.redAccent, // Background color
                                      shape: BoxShape
                                          .circle, // Makes it a round button
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.delete_outlined,
                                          color: Colors.white),
                                      onPressed: () async {
                                        await deleteSingleEvent(
                                            selectedDay, event.title, user);
                                        setState(() {});
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Buttons at the bottom of the right section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // Align buttons to the right
                    children: [
                      // Add New Event Button
                      ElevatedButton.icon(
                        onPressed: () => _showAddEventDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.add, size: 25),
                        label: const Text(
                          "Add New Event",
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Homepage Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Landing()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          "Homepage",
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Delete All Events Button
                      ElevatedButton.icon(
                        key: const Key('deleteButton'),
                        onPressed: () {
                          testDay = null;
                          testDayBool = true;
                          deleteAllEvents();
                          setState(() {});

                          // Show confirmation popup
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFFE6EDF2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              title: const Text(
                                "All Events Deleted",
                                style: const TextStyle(
                                  color: Color.fromRGBO(21, 58, 103, 1),
                                  fontSize: 21,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              content: const Text(
                                "Go to the homepage to schedule your study schedule.",
                                style: const TextStyle(
                                  color: Color.fromRGBO(21, 58, 103, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    minimumSize: Size(120, 45),
                                  ),
                                  child: Text(
                                    'OK',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Landing()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    minimumSize: Size(120, 45),
                                  ),
                                  child: Text(
                                    'Go to Homepage',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.delete, size: 25),
                        label: const Text(
                          "Delete All Events",
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const CustomFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  // VoidCallback -> Signature of callbacks that have no arguments and return no data.
  Widget _buildLabelItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<void> addSingleEvent(
      DateTime date, String eventTitle, User user) async {
    date = DateTime(date.year, date.month, date.day);
    
    // Create the new event with proper color
    Event newEvent = Event(
      title: eventTitle,
      color: _getEventColor(eventTitle)
    );
    
    // Add to local state first
    if (selectedEvents[date] == null) {
      selectedEvents[date] = [];
    }
    selectedEvents[date]?.add(newEvent);
    
    // Get existing events for this date from Firebase
    QuerySnapshot querySnapshot = await _eventsCollectionRef
        .where("date", isEqualTo: Timestamp.fromDate(date))
        .get();
   
    // Get all event titles as a list
    List<String> updatedEvents =
        selectedEvents[date]?.map((e) => e.title).toList() ?? [];
    
    try {
      if (querySnapshot.docs.isNotEmpty) {
        // Update existing document
        String docId = querySnapshot.docs.first.id;
        await _eventsCollectionRef.doc(docId).update({"events": updatedEvents});
      } else {
        // Create a new document for this date
        await _eventsCollectionRef.add({
          "date": Timestamp.fromDate(date),
          "events": updatedEvents
        });
      }
      
      print("Successfully saved event: $eventTitle on ${date.toString().split(' ')[0]}");
    } catch (e) {
      print("Error saving event to Firebase: $e");
    }
    
    // Important: Update calendar UI
    setState(() {});
  }

  Future<void> deleteSingleEvent(
      DateTime date, String eventTitle, User user) async {
    date = DateTime(date.year, date.month, date.day);

    if (!selectedEvents.containsKey(date)) return;

    selectedEvents[date]?.removeWhere((event) => event.title == eventTitle);

    if (selectedEvents[date]?.isEmpty ?? false) {
      selectedEvents.remove(date);
    }

    QuerySnapshot querySnapshot = await _eventsCollectionRef
        .where("date", isEqualTo: Timestamp.fromDate(date))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      String docId = querySnapshot.docs.first.id;
      List<String> updatedEvents =
          selectedEvents[date]?.map((e) => e.title).toList() ?? [];

      if (updatedEvents.isEmpty) {
        await _eventsCollectionRef
            .doc(docId)
            .delete(); // ❗ Ensure deletion happens
      } else {
        await _eventsCollectionRef.doc(docId).update({"events": updatedEvents});
      }
    }

    setState(() {});
  }

  Future<void> updateOneEvent(
      Event oldEvent, String newTitle, DateTime newDate) async {
    DateTime normalizedOldDate =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    DateTime normalizedNewDate =
        DateTime(newDate.year, newDate.month, newDate.day);

    try {
      // First, delete the old event
      await deleteSingleEvent(normalizedOldDate, oldEvent.title, user);
      
      // Then add the new event
      await addSingleEvent(normalizedNewDate, newTitle, user);
      
      // Make sure to update the selected day to the new date
      setState(() {
        selectedDay = normalizedNewDate;
        focusedDay = normalizedNewDate;
      });
      
      // Reload all events to ensure consistency
      await getEventsFromDB();
      
      print("Successfully updated event from '${oldEvent.title}' to '$newTitle'");
    } catch (e) {
      print("Error updating event: $e");
    }
  }

  void _editEventDate(BuildContext context, Event event) {
    final TextEditingController _editEventController =
        TextEditingController(text: event.title);
    DateTime? _selectedDate = selectedDay;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE6EDF2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        title: const Text(
          "Edit Event",
          style: TextStyle(
            color: Color.fromRGBO(21, 58, 103, 1),
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editable Event Title
            TextFormField(
              controller: _editEventController,
              enabled: event.title != "Test Day", // Disable title editing for Test Day
              style: const TextStyle(
                color: Color.fromRGBO(21, 58, 103, 1),
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                labelText: "Event Title",
                labelStyle: TextStyle(
                  color: Color.fromRGBO(21, 58, 103, 1),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Row with "Date:" label and button displaying the selected date
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Date:",
                  style: TextStyle(
                    color: Color.fromRGBO(21, 58, 103, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                StatefulBuilder(
                  builder: (context, setDialogState) => ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        locale: const Locale('en', 'GB'),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate) {
                        setDialogState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(21, 58, 103, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? "${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}"
                          : "Select Date",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(243, 90, 90, 1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_editEventController.text.isNotEmpty && _selectedDate != null) {
                if (event.title == "Test Day") {
                  // For Test Day events, use updateTestDay
                  await updateTestDay(_selectedDate!);
                } else {
                  // For other events, use updateOneEvent
                  await updateOneEvent(event, _editEventController.text, _selectedDate!);
                }
                Navigator.pop(context);
                setState(() {});
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45),
            ),
            child: const Text(
              "Save Changes",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Load excluded days from Firebase
  Future<void> _loadExcludedDays() async {
    try {
      QuerySnapshot querySnapshot = await _userCollectionRef
          .where("userID", isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first.data() as Map<String, dynamic>;
        if (userDoc.containsKey("excludedDays")) {
          var excludedDays = userDoc["excludedDays"] as List<dynamic>;
          setState(() {
            revisionDays = excludedDays.map((day) => day.toString()).toList();
          });
        }
      }
    } catch (e) {
      print("Error loading excluded days: $e");
    }
  }
}
