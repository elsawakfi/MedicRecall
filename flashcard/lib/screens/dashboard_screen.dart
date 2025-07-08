import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/calendar_screen.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/screens/study_session_manager.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flashcard_x/utils/last_revised.dart';
import 'package:flashcard_x/utils/theme_provider.dart';
import 'package:flashcard_x/widgets/app_bar_title_.dart';
import 'package:flashcard_x/widgets/event.dart';
import 'package:flashcard_x/widgets/indicator.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/feed_screen.dart';
import 'package:provider/provider.dart';
import '../utils/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class HomePage extends StatefulWidget {
  static String id = 'home';

  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late User user;
  
  late String? name;
  late String? id;
  bool getEvensOnce = false;
  late List<dynamic>? topicCount;
  List<dynamic>? topicLastSeen;
  CollectionReference users = FirebaseWrapper.firestore().collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool loading = true;
  List<Map<String, dynamic>> topics = [];
  Map<String, bool> checked = {};
  Map<String, int> seenCards = {};
  Map<String, int> totalCards = {};
  late DateTime _firstStudyDate;
  late DateTime testDay;
  late Map<DateTime?, List<Event>> selectedEvents;
  late Map<DateTime, List<Event>> allEvents;
  late CollectionReference _eventsCollectionRef;
  late List<String> topicNames = [];
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');
  StudySessionManager studySessionManager = StudySessionManager();

  double spacing = 16;


  Future<void> userData() async {
  //This function, retrieves all the necessary data for the flashcard tutor. 
  //The important part is getting the events from the database and only storing the events that have a flashcard
  //Study session scheduled in
    QuerySnapshot querySnapshot =
    await users.where("userID", isEqualTo: user.uid).get();
    setState(() {
      name = querySnapshot.docs.last["name"];
      id = querySnapshot.docs.last.id;
      topicCount = querySnapshot.docs.last["topicCount"];
      topicLastSeen = querySnapshot.docs.last["topicLastSeen"];
      try {
        testDay = querySnapshot.docs.last['TestDay'].toDate();
      }catch (e){
        // If testDay hasn't been set, assign a default value
        testDay = DateTime.now();
      }
      _firstStudyDate = DateTime.fromMicrosecondsSinceEpoch(
          querySnapshot.docs.last["firstStudyDay"].microsecondsSinceEpoch);
    });
    

    // if(!getEvensOnce){
      //Do not keep updating events???
    
    try{
      _eventsCollectionRef =
          FirebaseFirestore.instance.collection('users/$id/events');

      var snapshots = await _eventsCollectionRef.get();
      
     
      for (var doc in snapshots.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('date') && data.containsKey('events')) {
          Timestamp? timestamp = data['date'] as Timestamp?;
          List<dynamic>? eventsList = data['events'] as List<dynamic>?;

          if (timestamp != null && eventsList != null) {
            DateTime date = timestamp.toDate();
            date = DateTime(date.year, date.month, date.day);

            List<String> events = eventsList.map((e) => e.toString()).toList();

            allEvents[date] = events.map ((title) => Event(color: Colors.black, title: title)).toList();
            for (String e in events){
             
              if (!topicNames.contains(e) && !e.contains("Completed:")){
                 
                  events.remove(e);
                  
              }
            }

            selectedEvents[date] = events.map((title) => Event(
                title: title,
                color : Colors.yellow
            )).toList();
            getEvensOnce = true;
            
          }
        }

      }
     
    } catch(e){
      print("Error loading events from DB: $e");
    }
  }

    Future<void> updateOneEvent(
      Event oldEvent, String newTitle, DateTime newDate) async {
    DateTime normalizedDate =
        DateTime(newDate.year, newDate.month, newDate.day,0,0,0,0);
    // Remove old event from Firestore
    await deleteSingleEvent(normalizedDate, oldEvent.title, user);
    await addSingleEvent(normalizedDate, newTitle, user,edit :true);
  }


    Future<void> deleteSingleEvent(
      DateTime date, String eventTitle, User user) async {
    date = DateTime(date.year, date.month, date.day,0,0,0,0);

    if (!allEvents.containsKey(date)) {
      print("No events found for date: ${date.toString().split(' ')[0]}");
      return;
    }

    allEvents[date]?.removeWhere((event) => event.title == eventTitle);

    if (allEvents[date]?.isEmpty ?? false) {
      allEvents.remove(date);
    }

    QuerySnapshot querySnapshot = await _eventsCollectionRef
        .where("date", isEqualTo: Timestamp.fromDate(date))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      String docId = querySnapshot.docs.first.id;
      List<String> updatedEvents =
          allEvents[date]?.map((e) => e.title).toList() ?? [];

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
  Future<List> getTopicsDatabase() async {
    List<dynamic> holderList = [];

    CollectionReference topicRef =
    FirebaseWrapper.firestore().collection("topics");
    QuerySnapshot topicSnapshot = await topicRef.get();
    List<Map<String, dynamic>> holder = [];
    Map<String, bool> holderChecked = {};
    for (var doc in topicSnapshot.docs) {
      holder.add(Map<String, dynamic>.from(doc.data() as Map<String, dynamic>));
      holder.last["color"] = Color(int.parse(holder.last["color"]));
      holderChecked[holder.last["topic"].toString()] = false;

      if (holder.last["subtopics"] == null) {
        // if subtopic field is empty
        List<String> tempSubtopics = [];
        holder.last["subtopics"] = tempSubtopics;
      } else {
        List<String> tempSubtopics = [];
        for (var subtopic in holder.last["subtopics"]) {
          tempSubtopics.add(subtopic.toString());
          holderChecked[subtopic.toString()] = false;
        }
        holder.last["subtopics"] = tempSubtopics;
      }
    }
    holderList.add(holder);
    holderList.add(holderChecked);

    return holderList;
  }
  
  
  Future<bool> _isExcludedDay(DateTime date, String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await _userCollectionRef.where("userID", isEqualTo: userId).get();
      if (querySnapshot.docs.isEmpty) return false;

      var userData = querySnapshot.docs.last.data() as Map<String, dynamic>;
      if (!userData.containsKey('excludedDays')) return false;

      List<String> excludedDays = List<String>.from(userData['excludedDays']);
      String dayName = _getDayName(date.weekday);
      return excludedDays.contains(dayName);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking excluded day: $e');
      }
      return false;
    }
  }

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


  Future<DateTime> findNearestFreeDate(
      DateTime targetDate,
      int maxDaysToMove,
      DateTime testDay,
      DateTime today,
      Map<DateTime, List<Event>> generatedEvents,
      String userId,
      {int requiredSpacing = 0}) async {
    // First check if the target date is already available
    if (generatedEvents[targetDate] == null &&
        !await _isExcludedDay(targetDate, userId)) {
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
          !await _isExcludedDay(nextDate, userId)) {
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
          !await _isExcludedDay(prevDate, userId)) {
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
        !await _isExcludedDay(today, userId)) {
      return today;
    }

    // If absolutely no valid date found, return the original target date
    // The calling methods will need to check if this date is actually usable
    return targetDate;
  }


 Future<void> addSingleEvent (
      DateTime date, String eventTitle, User user,{bool edit = false}) async {
    date = DateTime(date.year, date.month, date.day,0,0,0,0);
   
  DateTime today = DateTime.now();
  
  if (edit == false){
  print("Finding nearest date\n");
  date = await findNearestFreeDate(date, 5, testDay, today, allEvents, user.uid);
  print("Found??\n");
  }

  Color color =  Colors.yellow; 

  if (edit == true) color = Colors.black;
  
    //The delete single event function updates the UI in real time so I just copied the structure of that function 
    Event newEvent =  Event(
                        title: eventTitle,
                        color: color
                        );
    //cannot add a new revision date if the date is not empty
    if (allEvents[date] == null) {
      selectedEvents[date] = [];
      allEvents[date] = [];
      print("Adding event to $date\n");
    
    selectedEvents[date]?.add(newEvent);
    allEvents[date]?.add(newEvent);
    QuerySnapshot querySnapshot = await _eventsCollectionRef
        .where("date", isEqualTo: Timestamp.fromDate(date))
        .get();

     List<String> updatedEvents =
        allEvents[date]?.map((e) => e.title).toList() ?? [];
    
    if (querySnapshot.docs.isNotEmpty) {
    String docId = querySnapshot.docs.first.id;

    // Update Firestore document
    await _eventsCollectionRef.doc(docId).update({"events": updatedEvents});
  } else {
    // If no document exists, create a new one
    DocumentReference newDoc = await _eventsCollectionRef.add({
      "date": Timestamp.fromDate(date),
      "events": [eventTitle] // Start with just the new event
    });
    
    String newDocId = newDoc.id;
    await _eventsCollectionRef.doc(newDocId).update({"events": updatedEvents});

  }}
 
    setState(() {});
  }

//Get all events from database, iterate over events and look for which date a flashcard topic has been scheduled 
  Future<void> getTopics() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    
    var holderList = await getTopicsDatabase();
    

    if (mounted) {
      setState(() {
        topics = holderList[0];
        checked = holderList[1];
        topicNames = topics.map((e) => '${e['topic']} Flashcards').toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      name = "loading...";
    });
    getData();
    setState(() {});
  }

  Future<void> getData() async {
    //DO NOT CHANGE THE ORDER OF THIS OTHERWISE PAGE WILL NOT BUILD
    setState((){
      name = "loading...";
      selectedEvents = {};
      allEvents = {};
      loading = true;
    });
    await getUser();
    await getTopics();
    await userData();
    await getStats();
    
    setState(() {
      loading = false;
    });
    
    
  }

  

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    return AppScaffold(
        body:  Center(
      child: loading
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: makeColumn(),
        ),
      ),
    ),
        title: "Flashcard Tutor"
    );
  }

  Future<void> getUser() async {

    NavigatorState nav = Navigator.of(context);
    setState(() {
      loading = true;
    });
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
    QuerySnapshot querySnapshot =
        await users.where("userID", isEqualTo: user.uid).get();
     
     

    setState(() {
      name = querySnapshot.docs.last["name"];
      id = querySnapshot.docs.last.id;
      topicCount = querySnapshot.docs.last["topicCount"];
      topicLastSeen = querySnapshot.docs.last["topicLastSeen"];
      loading = false;
    });
  }

  Future<void> getStats() async {
    setState(() {
      loading = true;
    });

    TopicStats stats = await LastRevised.getStats();
    if (mounted) {
      setState(() {
        totalCards = stats.totalCards;
        seenCards = stats.seenCards;
        loading = false;
      });
    }
    
  }

 

  
  

  //Formats the checkbox categories according to colour depending on whether the review date is due and how many flashcards have been seen.
  List<Widget> makeCheckboxList() {
    DateTime today = DateTime.now();
    today = DateTime(today.year,today.month,today.day,0,0,0,0);
    
    List<Widget> value = [];
    for (var i = 0; i < topics.length; i++) {
   
      var map = topics[i];
      var text = seenCards[map["topic"]] == null
          ? "0"
          : seenCards[map["topic"].toString()].toString();

      //Number of days since topic was last revised is converted from seconds to days as an int
      var howLongAgoRevisedDays = (Timestamp.now().seconds - topicLastSeen![i].seconds) / (60 * 60 * 24);

      //A mapping of how many times the topics been seen to what the next review date gap should be. After 7 times it stays at 128 days.
      
      //CHANGE THIS FORMULA FOR to DR. Harris' new one
      Map<int, int> dateToColourMap = {0: ((howLongAgoRevisedDays.ceil()*4)+1), 1: 2, 2: 4, 3: 8, 4: 16, 5: 32, 6: 64, 7: 128};
      
      
      
      // MaterialColor topicColour = Colors.green;
      Color tColour = Color(0xFFB0FFC6); // green
      if (topicCount![i]>(dateToColourMap.length-1)){
        topicCount![i]=dateToColourMap.length-1;
      }

      

      int nextReviewDateMilliseconds = (((dateToColourMap[topicCount![i]]! * 24 * 60 * 60) + topicLastSeen![i].seconds) * 1000).toInt();
      DateTime nextReviewDate = DateTime.fromMillisecondsSinceEpoch(nextReviewDateMilliseconds, isUtc: true).toLocal();
      String formattedDate = DateFormat('dd/MM/yyy').format(nextReviewDate); 
      DateTime? dateInCalendar;
      bool notInCalendar = true;
      List<String> rescheduled = [];
      Event e = Event(color:Color(0xFFB0FFC6),title: "Shouldn't add"); 
      
      
      //Only go through the flashcard events with "selectedEvents" instead of allEvents
      
      if (selectedEvents.isNotEmpty ){
        for (final entry in selectedEvents.entries){
        for (final event in entry.value){
          if (event.title.contains(map["topic"])){
            formattedDate = entry.key.toString();
            dateInCalendar = entry.key;
            formattedDate = formattedDate.substring(0,10);
            notInCalendar = false;
            e = event;
          }
        }
        }
        if (notInCalendar){
          formattedDate = "N/A";
          tColour = Color(0xFFD9D9D9);
        }
        else{

         //If the user hasn't seen any cards and it is past the revision date set it red
      //Otherwise set it to grey
      if (seenCards[map["topic"]] == null || seenCards[map["topic"]] == 0){
        if (dateInCalendar!.isBefore(today)){
         tColour = Color(0xFFFF9595); 
        }
        else{
           tColour = Color(0xFFD9D9D9);

        }
      }
      
      //if the user has seen some of the cards 
      else  {

        //If the revision date is in the future 
        if (dateInCalendar!.isAfter(today)){
             
             //If the user has seen all the cards set to green
             if (seenCards[map["topic"]]! == totalCards[map["topic"]]!) {
              tColour = Color(0xFFB0FFC6); 
             }

            //If they haven't seen all of them set it to grey
             if(seenCards[map["topic"]]! < totalCards[map["topic"]]!) tColour = Color(0xFFD9D9D9);   
      }

        else if(dateInCalendar.isBefore(today) || dateInCalendar.isAtSameMomentAs(today)) {
          //Reschedule or set red
           if (seenCards[map["topic"]]! == totalCards[map["topic"]]!){
            
            rescheduled.add("${map["topic"]}");
            tColour = Color(0xFFD9D9D9);   
           
 
            addSingleEvent(nextReviewDate,
              "${map["topic"]} Flashcards", user);
            formattedDate = nextReviewDate
            .toString().substring(0,10);
            text = "0";

            
            updateOneEvent(e, "Completed: ${e.title} ", dateInCalendar);

            LastRevised.resetSeenCardsForTopic("${map["topic"]}");
            selectedEvents.remove(dateInCalendar);
        
           }
           if (seenCards[map["topic"]] == null || seenCards[map["topic"]]! < totalCards[map["topic"]]!){
            tColour = Color(0xFFFF9595);   
           }
        
        }
        
     
      }}}
      else{
          formattedDate = "N/A";
          //dateInCalendar = today;
          tColour = Color(0xFFD9D9D9);
        }

      value.add(Padding(padding: EdgeInsets.only(bottom: 8, left: 15, right: 15), child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Tooltip(
          message: "Click to view subtopics",
          decoration: BoxDecoration(color: Colors.transparent),
          enableTapToDismiss: true,
          verticalOffset: -11,
          preferBelow: false,
          child: ExpansionTile(
            trailing: Text(
                "$text / ${totalCards[map["topic"].toString()]}",
                style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: tColour,
            collapsedBackgroundColor: tColour,
            textColor: Colors.black,
            title: Text(
                "${map["topic"]}",
                style: const TextStyle(color: Colors.black),
            ),
            leading: Checkbox(
              side: const BorderSide(
                      color: Colors.black,
                      width: 1.5
                    ),
              key: i == 0 ? const ValueKey("Checkbox") : UniqueKey(),
              value: checked[map["topic"]],
              onChanged: (bool? value) {
                setState(() {
                  checked[map["topic"]] = value!;

                  for (var subtopic in map["subtopics"]) {
                    checked[subtopic.toString()] = checked[map["topic"]]!;
                    
                  }
                });
              },
            ),
            subtitle: Row(
              children: [
                const Text(
                  "Next Review Date: ",
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            children: makeCheckbox(map))
        ),
      )));
    }
    return value;
  }

  List<CheckboxListTile> makeCheckbox(Map<String, dynamic> data) {
    List<CheckboxListTile> value = [];
    for (var subtopic in data["subtopics"]) {
      var text = seenCards[subtopic] == null
          ? "0"
          : seenCards[subtopic.toString()].toString();
      value.add(CheckboxListTile(
        side: const BorderSide(
            color: Colors.black,
            width: 1.5),
        secondary: Text(
          "$text / ${totalCards[subtopic.toString()]}",
          style: const TextStyle(color: Colors.black),
        ),
        value: checked[subtopic.toString()],
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.fromLTRB(62, 0, 62, 0),
        onChanged: (bool? value) {
          setState(() {
            checked[subtopic.toString()] = value!;
          });
          bool allSelected = true;
          for (var subtopic in data["subtopics"]) {
            if (checked[subtopic.toString()] == false) {
              allSelected = false;
            }
          }
          setState(() {
            checked[data["topic"]] = allSelected;
          });
        },
        title: Text(
          subtopic.toString(),
          style: const TextStyle(color: Colors.black),
        ),
      ));
    }
    return value;
  }

  void explanationBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Instructions',
            style: TextStyle(fontSize: 20),
            ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 5),
                Text(
                  '1. Start a revision session by completing one or more of our flashcard decks.\n'
                      '2. Work through each question, ensuring that you answer the question in your head before flipping the card (active recall).\n'
                      '3. Click the tick or cross next to the flashcard to indicate whether you have mastered the card.\n'
                      '4. At the end of each deck, you will be prompted to review all the cards that you are still learning before moving on.\n'
                      '5.	Once completed, the deck will turn green.\n'
                      '6. Then, our tailored spaced repetition algorithm kicks in and will schedule your next review date for that topic.\n'
                      '7. Repeat this cycle throughout your revision period; the time between repetitions will increase with successive reviews.\n'
                      '8.	If you wish to receive email reminders when a topic is overdue, you can turn on this feature in our settings tab.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                      )
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> makeColumn() {
    List<Widget> widgets = [
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: <Widget>[
          Indicator(color: Color.fromRGBO(0xFA, 0xFA, 0xFA, 1), text: "Unseen"),
          Indicator(color: Color.fromRGBO(0xFF, 0x95, 0x95, 1), text: "Needs Review"),
          Indicator(color: Color.fromRGBO(0xB0, 0xFF, 0xC6, 1), text: "Recently Reviewed"),

        ],


      ),

      const SizedBox(height: 40),
      Container(
        margin: const EdgeInsets.only(left: 30.0, right: 30.0),
        child: Column(
          children: makeCheckboxList(),
        ),
      ),

      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 60),
          Spacer(flex: 1),
          Expanded(
            flex: 1,
            child: Align(child: TextButton(
              key: const ValueKey("Revise"),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),

              onPressed: () {
                // reviseCards("revise");
                reviseCards();
              },

              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Text('Revise'),
              ),
            ),
          )),

          Expanded(
            flex: 1, 
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),

                onPressed: () {
                  explanationBox();
                },

                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Icon(Icons.question_mark, color: Colors.black,),
                ),
              ),
            )
          ),
          SizedBox(width: 60,)
        ],
      ),
      const SizedBox(height: 20),
    ];

    return widgets;
  }

  //Shows an alert box
  AlertDialog alertDialogue() {
    return AlertDialog(
      title: const Text(
          'No topics selected'),
      content: const Text(
          'Please select a topic by ticking the checkbox beside the category before pressing revise.'),
      actions: <
          Widget>[
        TextButton(
          onPressed: () {
            Navigator
                .of(
                context)
                .pop(); // Close the alert dialog
          },
          child: const Text(
              'OK'),
        ),
      ],
    );
  }

  void reviseCards() {
    List<String> selectedSubtopics = [];

    for (var key in checked.keys) {
      if (checked[key] == true) {
        selectedSubtopics.add(key);
      }
    }

    if (selectedSubtopics.isNotEmpty) {
      Navigator.push(
        context,
        ExpandRoute(
            page: AboveEverything(
              subtopics: selectedSubtopics,
              count: 1,
              // choice: choice,
            )),
      );
    } else {

      //If no topics selected, alert box is shown
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialogue();
        },
      );
    }
  }
}

