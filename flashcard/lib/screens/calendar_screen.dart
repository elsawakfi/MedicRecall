
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/widgets/event.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/button_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flashcard_x/screens/study_session_manager.dart';

/*
Important note for devs

testDay is a dateTime object
testDayString is the same, but stored as a string
this is so that it can be stored and retrieved from the database, there was an error where dateTime couldnt be pulled
as a result, both are used:
testDay for the calendar on the app
testDayString for database purposes.

 */

bool loading = true;

List<String> topicsListOld = [
  //just the topics
  "Patient focus",
  "The remit of an FY1",
  "Commitment to professionalism",
  "Coping with pressure",
  "Effective communication",
  "Team working",
  "Confidentiality",
  "Who's who"
];
List<String> topicsList = [
  // topics with a subtopic (if it has one)
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

List<dynamic> topicsSeen = [];

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  CalendarStateO createState() => CalendarStateO();
}

class CalendarStateO extends State<Calendar> {
  final StudySessionManager studySessionManager = StudySessionManager();
  final CollectionReference _userCollectionRef = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;

  late User user;
  late Map<DateTime?, List<Event>> selectedEvents;
  CalendarFormat format = CalendarFormat.month;
  DateTime? testDay = DateTime.now();
  late String testDayString = "Test day not set";
  DateTime selectedDay = DateTime(2020, 1, 1);
  // what the user has tapped on
  DateTime focusedDay = DateTime.now();
  final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int buildCount = 0;
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

    HomePageState homePageState = HomePageState();
    var holderList = await homePageState.getTopicsDatabase();
    var topics = holderList[0];

    QuerySnapshot querySnapshot =
    await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    var topicCount = querySnapshot.docs.last["topicCount"];
    var topicLastSeen = querySnapshot.docs.last["topicLastSeen"];

    int daysUntilTest = (testDay.difference(today).inHours / 24)
        .round(); //calculates the number of days between today and the testday

    for (var i = 0; i < topics.length; i++) {
      var howLongAgoRevisedDays = (Timestamp.now().seconds - topicLastSeen![i].seconds) / (60 * 60 * 24);
      Map<int, int> dateToColourMap = {0: ((howLongAgoRevisedDays.toInt()*4)+1), 1: 2, 2: 4, 3: 8, 4: 16, 5: 32, 6: 64, 7: 128};

      int daysToNextReviewDate = (((dateToColourMap[topicCount![i]]!) + (topicLastSeen![i].seconds/86400)).toInt()) - Timestamp.now().seconds~/86400;
      DateTime nextReviewDateObject = today.add(Duration(days: daysToNextReviewDate));
      DateTime standardisedDate = DateTime(nextReviewDateObject.year, nextReviewDateObject.month, nextReviewDateObject.day);

      if (daysToNextReviewDate >= 0 && topicCount[i] > 0 && daysToNextReviewDate < daysUntilTest) {
        if (selectedEvents[standardisedDate] != null) {
          selectedEvents[standardisedDate]?.add(Event(title: topics[i]["topic"].toString()));// add to the selected items list - this is then added to the calendar
        } else {
          selectedEvents[standardisedDate] ??= [];
          selectedEvents[standardisedDate]?.add(Event(title: topics[i]["topic"].toString()));// add to the selected items list - this is then added to the calendar
        }

      }
    }

    updateEventsToDB(user); // add these events to the database, so they can be pulled later on.
  }

  //Calls generateEvents and sets the state to rebuild the UI with changes
  Future<void> generateEventsUIChange(DateTime testDay) async {
    await generateEvents(testDay, user);
    setState(() {});
  }

  Future <void> generateStudySessions(User user) async {
    var studySessions = await studySessionManager.generateStudySessions(user);
    setState(() {
      selectedEvents.addAll(studySessions);
    });
    // add to database
    await studySessionManager.saveStudySessionsToDB(user, studySessions);
  }

  // DATABASE FUNCTIONS:

  Future<void> getUser() async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth
          .authStateChanges()
          .first;
      if (tmp == null) {
        nav.push(
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            )
        );
      } else {
        user = tmp;
      }
    } else {
      user = auth.currentUser!;
    }
  }

  // We pull the testDay if its in the database to be updated in the calendar UI
  Future<void> getTestDay() async {
    QuerySnapshot querySnapshot =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();

    var userFromDb = querySnapshot.docs.first;
    Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
    //if the Test Day field isn't null and is in the database we update the UI with it. Otherwise it is displayed as being not set.
    if ((data.containsKey("TestDay") || data["TestDay"] != null) && (buildCount <= 2 || (testDay != null && buildCount > 2))) {
      testDayBool = false;
      testDay = DateTime.fromMicrosecondsSinceEpoch(userFromDb["TestDay"]
          .microsecondsSinceEpoch); //firebase is weird. conversion from TimeStamp to DateTime object
      String? day = testDay?.day.toString();
      String? month = testDay?.month.toString();
      String? year = testDay?.year.toString();

      testDayString = '$day-$month-$year';
    } else {
      testDayBool = true;
    }
    setState(() {});
  }

  //with UTD we want to update the date on the calendar, and change in firebase
  Future<void> updateTestDay(DateTime date) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot u =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();

      /*  FIRST update on database */
      var id = u.docs.last.id; //id being where the user's id details
      users.doc(id).update(
          {"TestDay": date}); // update field testday to what is passed as param

      selectedEvents[testDay]?.remove(Event(title: "Test Day"));
      await getTestDay();
      setState(() {});
  }

  //updates the UI with the events collected from firebase
  Future<void> getEventsFromDB() async {
    getTestDay(); // ensure test day is initialised
    QuerySnapshot querySnapshot = await _eventsCollectionRef.get();
    var allEvents = querySnapshot.docs.map((doc) => doc.data()).toList();
    //gets all the events in the events folder for the user

    for (var value in allEvents) {
      // for each event tied to the user
      var event = Map<String, dynamic>.from(value
          as Map<String, dynamic>); //event is a map from strings to dynamics
      var date = (DateTime.fromMicrosecondsSinceEpoch(event["date"]
          .microsecondsSinceEpoch)); //convert timestamp to datetime
      List<Event> events = []; //events is an empty list to hold all events.
      for (var e in event["events"]) {
        events.add(Event(title: e)); // adds each
      }

      selectedEvents[date] = events;

    }
    if (selectedEvents[testDay] == null) {
      selectedEvents[testDay] = [Event(title: "Test Day")];
    } else {
      selectedEvents[testDay]?.add(Event(title: "Test Day"));
    }

    setState(() {});
  }

  //upload each event in the calendar to the database
  Future<void> updateOneEvent(DateTime date, List<String> events, User user) async {
    QuerySnapshot u =
    await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    String id = u.docs.last.id;

    _eventsCollectionRef =
        FirebaseFirestore.instance.collection('users/$id/events');
    QuerySnapshot querySnapshot = await _eventsCollectionRef
        .where("date", isEqualTo: date)
        .get(); // get the events matching to the date given
    if (querySnapshot.docs.isEmpty) {
      // incase of no event,
      _eventsCollectionRef
          .add({"date": date, "events": events}); // add the event with the day
    } else {
      var id = querySnapshot.docs.first.id;

      if (events.isEmpty) {
        _eventsCollectionRef.doc(id).delete();
      } else if (events != querySnapshot.docs.first["events"]) {
        _eventsCollectionRef.doc(id).update({"date": date, "events": events});
      }
    }
  }

  //When creating a new revision plan we update the database with the revision topics and dates in the calendar
  Future<void> updateEventsToDB(User user) async {
    List<DateTime> dates = [];
    selectedEvents.forEach((date, events) {
      dates.add(date!);
      List<String> eventsString = []; // holds all events as a string
      if (events.isNotEmpty) {
        for (var e in events) {
          if (e.title != "Test Day") {
            eventsString.add(e.title);
          }
        }
        if (eventsString.isNotEmpty) {
          updateOneEvent(date, eventsString, user);
        }
      }
    });
  }

  //deletes all events and testDay in UI calendar and firebase
  Future<void> deleteAllEvents() async {
    selectedEvents
        .clear(); // sets the selectedEvents list to empty - delete all events being stored locally.

    QuerySnapshot u =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    String id = u.docs.last.id;
    _eventsCollectionRef =
        // FirebaseFirestore.instance.collection('users/' + id + "/events");
        FirebaseFirestore.instance.collection('users/$id/events');
    var snapshots = await _eventsCollectionRef.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    var userFromDb = u.docs.first;
    Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    if (data.containsKey("TestDay") || data["TestDay"] != null) {
      data.remove("TestDay");
      users.doc(id).update({"TestDay": FieldValue.delete()}); // update field TestDay to be removed from database
    }

    selectedEvents[testDay]?.remove(Event(title: "Test Day"));
    getTestDay();
  }

  @override
  void initState() {
    selectedEvents = {};
    super.initState();
    setState(() {
      testDayString = "loading ...";
    });
    getUser();
    Future<void> getData() async {
      QuerySnapshot u =
      await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
      String id = u.docs.last.id;

      _eventsCollectionRef =
          FirebaseFirestore.instance.collection('users/$id/events');
      await getEventsFromDB();
    }
    getData();
    _loadStudySessions();
  }
   Future<void> initializeUserAndTestDay() async {
    await getUser();
    await getTestDay();
    await generateEventsUIChange(testDay!);
  }

  Future<void> _loadStudySessions() async {
   StudySessionManager studySessionManager = StudySessionManager();
    User user = FirebaseAuth.instance.currentUser!;
    // DateTime testDay = DateTime.now().add(Duration(days: 30)); // Example test day

    Map<DateTime, List<Event>> events = await studySessionManager.generateStudySessions(user);
    setState(() {
      selectedEvents.addAll(events);
    });
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

@override
Widget build(BuildContext context) {
  buildCount++;
  return Scaffold(
    drawer: const DrawMain(),
    appBar: AppBar(
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
          // Positioned custom button on the right
          Positioned(
            right: 0,
            top: 0,
            child: const CustomFloatingButton()
          ),
        ],
      ),
      centerTitle: true,
    ),
    body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TableCalendar(
                  focusedDay: focusedDay,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2050),
                  calendarFormat: format,
                  onFormatChanged: (CalendarFormat format) {
                    setState(() {
                      this.format = format;
                    });
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  daysOfWeekVisible: true,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  onDaySelected: (DateTime selectDay, DateTime focusDay) {
                    setState(() {
                      selectedDay = selectDay;
                      focusedDay = focusDay;
                    });
                  },
                  eventLoader: _getEventsfromDay,
                  calendarStyle: CalendarStyle(
                    isTodayHighlighted: true,
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white),
                    todayDecoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    weekendDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonShowsNext: false,
                  ),
                ),
                ..._getEventsfromDay(selectedDay).map(
                  (Event event) => ListTile(
                    title: Text(event.title),
                  ),
                ),
                Column(
                  children: [
                    const Text("Your exam is on:"),
                    Text(
                      (testDayBool)
                          ? "Exam date has not been set"
                          : testDayString,
                      style: const TextStyle(fontSize: 30),
                    ),
                    MaterialButton(
                      onPressed: () {
                        testDay = null;
                        testDayBool = true;
                        deleteAllEvents();
                        setState(() {});
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textColor: const Color.fromARGB(255, 243, 167, 162),
                      child: const Text("DELETE ALL"),
                    ),
                    ElevatedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                              "Would you like to generate a revision plan?"),
                          actions: [
                            TextButton(
                              child: const Text("No"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: const Text("Yes"),
                              onPressed: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                        "When is your next test date? (final test)"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ElevatedButton(
                                        child: const Text(
                                          "Pick your test date",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        onPressed: () {
                                          showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2050),
                                          ).then((date) {
                                            if (date != null) {
                                              setState(() {
                                                if (testDayBool == false) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                        context) {
                                                      return AlertDialog(
                                                        title:
                                                            const Text('Alert'),
                                                        content: const Text(
                                                            'You cannot update the Test Day because it already exists.'),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child:
                                                                const Text('OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else if (testDayBool ==
                                                    true) {
                                                  testDayBool == true;
                                                  testDay = date;
                                                  updateTestDay(testDay!);
                                                  getTestDay();
                                                  testDayString =
                                                      "${date.day}-${date.month}-${date.year}";
                                                  getEventsFromDB();
                                                  generateEventsUIChange(
                                                      testDay!);
                                                  Navigator.pop(context);
                                                }
                                              });
                                            } else {
                                              if (context.mounted){
                                                Navigator.pop(context);
                                              }
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Make a Revision Plan",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      heroTag: UniqueKey().toString(),
      onPressed: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Add Event"),
          content: TextFormField(controller: _eventController),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                if (_eventController.text.isNotEmpty) {
                  if (selectedEvents[selectedDay] != null) {
                    selectedEvents[selectedDay]?.add(
                      Event(title: _eventController.text),
                    );
                  } else {
                    selectedEvents[selectedDay] = [
                      Event(title: _eventController.text),
                    ];
                  }
                  updateEventsToDB(user);
                  Navigator.pop(context);
                  _eventController.clear();
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
      label: const Text("Add event", style: TextStyle(color: Colors.white)),
      icon: const Icon(Icons.add),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
  );
}}