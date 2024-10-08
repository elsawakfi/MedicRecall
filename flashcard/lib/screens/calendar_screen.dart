
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/widgets/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:table_calendar/table_calendar.dart';

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
  const Calendar({Key? key}) : super(key: key);

  @override
  CalendarStateO createState() => CalendarStateO();
}

class CalendarStateO extends State<Calendar> {
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');

  late CollectionReference _eventsCollectionRef;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;


  late Map<DateTime?, List<Event>> selectedEvents;

  CalendarFormat format = CalendarFormat.month;

  //The CalendarFormat variable format allows the user to change their view of the calendar, into weekly, biweekly and monthly.

  DateTime? testDay = DateTime.now();

  late String testDayString = "Test day not set";

  DateTime selectedDay = DateTime(1900, 1, 1);
  // what the user has tapped on
  DateTime focusedDay = DateTime.now(); // is that today?
  final DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // for some reason, events need to have their time as being midnight to be shown on the calendar. So need to set the today constant to be midnight today.
  // therefore today isn't just datetime.now it is calibrated to midnight.

  int buildCount = 0;

  final TextEditingController _eventController = TextEditingController();
  bool testDayBool = false;
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
          title: Align(
            alignment: const Alignment(-0.05,0),
            child: Stack(
              children: [
                Positioned(
                  top: 2.3,
                  child: Image.asset(
                    'assets/newlogo.png',
                    fit: BoxFit.cover,
                    height: 34,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 32),
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('Revision Calendar',
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          leading: Builder(
              builder: (context) => GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: const Icon(
                      Icons.menu,
                    ),
                  ))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              // initialisation of the calendar
              focusedDay: DateTime.now(),
              firstDay: DateTime(1990),
              // the bounds of the calendar
              lastDay: DateTime(2050),
              calendarFormat: format,
              onFormatChanged: (CalendarFormat format) {
                setState(() {
                  format =
                      format; // if the format of the calendar is changed by the user, reflect this in the app immediately
                });
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              // makes it so the calendar begins on monday.
              daysOfWeekVisible: true,

              //Change the day we are looking at currently
              onDaySelected: (DateTime selectDay, DateTime focusDay) {
                //allows us to change the selected day and the focus day
                setState(() {
                  selectedDay = selectDay;
                  focusedDay = focusDay;

                  selectedDay = DateTime(
                      selectedDay.year, selectedDay.month, selectedDay.day);
                  focusedDay = DateTime(
                      focusedDay.year, focusedDay.month, focusedDay.day);
                });
              },
              selectedDayPredicate: (DateTime date) {
                // allows you to select a new date
                return isSameDay(selectedDay, date);
              },

              eventLoader: _getEventsfromDay,

              // styling the calendar
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                //highlights the current day today.
                selectedDecoration: BoxDecoration(
                  //selected day is what the user taps on
                  color: Colors.blue,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(
                      10.0), //this creates a weird millisecond error
                ),
                selectedTextStyle: const TextStyle(color: Colors.white),
                todayDecoration: BoxDecoration(
                  //today - this is not changed by the user. Changed by the sun
                  color: Colors.grey,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                ),

                // Defaults for the days, this needs to be added to prevent a weird error which flashes for a second.

                defaultDecoration: BoxDecoration(
                  // default for the days
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(
                      10.0), //this creates a weird millisecond error
                ),
                weekendDecoration: BoxDecoration(
                  //weekend default
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonShowsNext:
                    false, // so the button shows what view you are currently on, not what is next.
              ),
            ),
            ..._getEventsfromDay(selectedDay).map((Event event) => ListTile(
                    title: Text(
                  event.title,
                ))),
            Column(
              children: [
                const Text("Your exam is on:"),
                Row(
                  children: const [
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),

                Text(
                  (testDayBool) ? "Exam date has not been set" : testDayString,
                  style: const TextStyle(fontSize: 30),
                ),

                MaterialButton(
                  onPressed: () {
                    testDay = null;
                    testDayBool = true;
                    deleteAllEvents();
                    setState(() {});
                  },
                  child: const Text("DELETE ALL"),
                ),

                Row(
                  children: const [
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
                ElevatedButton(
                    // user wants to create a revision schedule
                    onPressed: () => showDialog(
                        context: context, // dialogue box appears
                        builder: (context) => AlertDialog(
                                title: const Text(
                                    "Would you like to generate a revision plan?"),
                                // informs the user that they can add an event to the calendar

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
                                                  // informs the user that they can add an event to the calendar
                                                  actions: [
                                                    TextButton(
                                                        child: const Text(
                                                            "Cancel"),
                                                            onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                        }
                                                    ),
                                                    ElevatedButton(
                                                      child: const Text(
                                                          "Pick your test date",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue)),
                                                      onPressed: () {
                                                        //pass func when result is passed by user - result of showDatePicker func
                                                        showDatePicker(
                                                                context:
                                                                    context,
                                                                initialDate:
                                                                    DateTime
                                                                        .now(),
                                                                //constraints of the datepicker
                                                                firstDate:
                                                                    DateTime
                                                                        .now(),
                                                                // first date pickable is today
                                                                lastDate:
                                                                    DateTime(
                                                                        2050))
                                                            .then((date) {
                                                              if (date != null) {
                                                                // change the state of the app, where testDay has been changed
                                                                setState(() {
                                                                  //if there is already a test day on calender and user wants to set another one, show a dialogue box not allowing them to do so
                                                                  if (testDayBool ==
                                                                      false) {
                                                                    showDialog(
                                                                      context: context,
                                                                      builder: (
                                                                          BuildContext context) {
                                                                        return AlertDialog(
                                                                          title: const Text(
                                                                              'Alert'),
                                                                          content: const Text(
                                                                              'You cannot update the Test Day because it already exists.'),
                                                                          actions: <
                                                                              Widget>[
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator
                                                                                    .of(
                                                                                    context)
                                                                                    .pop(); // Close the alert dialog
                                                                                Navigator
                                                                                    .of(
                                                                                    context)
                                                                                    .pop();
                                                                              },
                                                                              child: const Text(
                                                                                  'OK'),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  } else
                                                                  if (testDayBool ==
                                                                      true) {
                                                                    testDayBool ==
                                                                        true;
                                                                    testDay =
                                                                    date;
                                                                    updateTestDay(
                                                                        testDay!);
                                                                    getTestDay();
                                                                    testDayString =
                                                                    "${date
                                                                        .day}-${date
                                                                        .month}-${date
                                                                        .year}";
                                                                    getEventsFromDB();
                                                                    generateEventsUIChange(
                                                                        testDay!);
                                                                    Navigator
                                                                        .pop(
                                                                        context); // once chosen, pop out of the date picker.
                                                                  }
                                                                });
                                                              } else {
                                                                Navigator.pop(context);
                                                              }
                                                        });
                                                      },
                                                    ),
                                                  ]));
                                    },
                                  ),
                                ])),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Make a Revision Plan"))
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: const Text("Add Event"),
                    // informs the user that they can add an event to the calendar
                    content: TextFormField(controller: _eventController),
                    // every text form field needs a controller
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text("Ok"),
                        onPressed: () {
                          // 3 cases to consider - person adds nothing, adds something when there is not events, and adds when there is already an event
                          if (_eventController.text.isEmpty) {
                            if (kDebugMode) {
                              print("no text to be added");
                            }
                          } else {
                            // if there is an event title given
                            if (kDebugMode) {
                              print(selectedDay.toUtc());
                            }
                            if (selectedEvents[selectedDay] != null) {
                              // if there is an event already there
                              selectedEvents[selectedDay]?.add(
                                // add the new event
                                Event(
                                    title: _eventController
                                        .text), // reflect in the _eventController
                              );
                            } else {
                              // if there is not already an event
                              selectedEvents[selectedDay] = [
                                Event(
                                    title:
                                        _eventController.text) //input the event
                              ];
                            }
                          }
                          updateEventsToDB(user);
                          Navigator.pop(
                              context); //navigator.pop to exit the context we have just added on creating the pop up screen.
                          _eventController
                              .clear(); //clear the controller (text field), memory cleanup
                          setState(() {});
                          return;
                        },
                      ),
                    ])),
        label: const Text("Add event", style: TextStyle(color: Colors.black)),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
