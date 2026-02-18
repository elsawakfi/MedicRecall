// import 'dart:ffi';
// import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flashcard_x/screens/calendar_screen.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/screens/study_session_manager.dart';
import 'package:flashcard_x/utils/algo.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flashcard_x/utils/last_revised.dart';
// import 'package:flashcard_x/utils/theme_provider.dart';
import '../widgets/drawer_widget2.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flashcard_x/widgets/event.dart';
import 'package:flashcard_x/widgets/indicator.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/feed_screen.dart';
import '../widgets/countdown_button.dart';
// import 'package:provider/provider.dart';
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

class TopicRow {
  final String topic;
  final String formattedDate; // "dd/MM/yyyy" or "N/A"
  final Color color;          // tile color
  final int seen;             // 0..total
  final int total;
  final bool isComplete;      // seen == total
  final DateTime? calendarDate; // actual DateTime if scheduled
  final List<String> subtopics;   // list of subtopic names
  TopicRow({
    required this.topic,
    required this.formattedDate,
    required this.color,
    required this.seen,
    required this.total,
    required this.isComplete,
    required this.calendarDate,
     List<String>? subtopics,               // nullable or optional param
  }) : subtopics = List<String>.from(subtopics ?? const []); // mutable copy
}

class HomePageState extends State<HomePage> {
  int? _hoveringIndex;
  late User user;
  List<TopicRow> _rows = [];
  late String? name;
  late String? id;
  late List<dynamic>? topicCount;
  List<dynamic>? topicLastSeen;
  // DateTime? _firstStudyDate;
  CollectionReference users = FirebaseWrapper.firestore().collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool loading = true;
  List<Map<String, dynamic>> topics = [];
  Map<String, bool> checked = {};
  Map<String, int> seenCards = {};
  Map<String, int> totalCards = {};
  late DateTime testDay;
  late Map<DateTime, List<Event>> selectedEvents;
  late Map<DateTime, List<Event>> allEvents;
  late CollectionReference _eventsCollectionRef;
  late List<String> topicNames = [];
  late List<int> topicScores = [];
  late Map<String, dynamic>? topicData; 
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');
  StudySessionManager studySessionManager = StudySessionManager();

  double spacing = 16;



  Future<void> getflashcardEvents() async{
     try{
      _eventsCollectionRef =
          FirebaseFirestore.instance.collection('users/$id/events');

      var snapshots = await _eventsCollectionRef.get();
      for (var doc in snapshots.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('date') && data.containsKey('events') ) {
          List<dynamic>? eventsList = data['events'] as List<dynamic>?;
          
          for (var event in eventsList!){
            String title = event.toString();          
            if((!title.contains("Flashcards")) || title.contains("Completed")) {
                continue;
            //     Timestamp? timestamp = data['date'] as Timestamp?;
            //       if (timestamp != null) {
            //     DateTime date = timestamp.toDate();
            //     date = DateTime(date.year, date.month, date.day);
            //     List<String> events = eventsList.map((e) => e.toString()).toList();
            //     allEvents[date] = events.map ((title) => Event(color: Colors.black, title: title)).toList();
            // }
            }
            else{
                Timestamp? timestamp = data['date'] as Timestamp?;
                  if (timestamp != null) {
                DateTime date = timestamp.toDate();
                date = DateTime(date.year, date.month, date.day);
                List<String> events = eventsList.map((e) => e.toString()).toList();
                selectedEvents[date] = events.map((title) => Event(
                    title: title,
                    color : Colors.yellow
                )).toList(); 
              }
        }


            }
        }
      }
      allEvents.addAll(selectedEvents);

    } catch(e){
      print("Error loading events from DB: $e");
    }

  }


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
      // _firstStudyDate = DateTime.fromMicrosecondsSinceEpoch(
          // querySnapshot.docs.last["firstStudyDay"].microsecondsSinceEpoch);
    });
  }

  Future<void> updateOneEvent(
      Event oldEvent, String newTitle, DateTime newDate, {DateTime? oldDate}) async {
    DateTime normalizedDate =
        DateTime(newDate.year, newDate.month, newDate.day,0,0,0,0);
    // Remove old event from Firestore
    if(oldDate != null){ 
      DateTime normalizedOld =  DateTime(oldDate.year, oldDate.month, oldDate.day,0,0,0,0);
      await deleteSingleEvent(normalizedOld, oldEvent.title, user);
      
    }else{
      await deleteSingleEvent(normalizedDate, oldEvent.title, user);
    }
   
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

  Future<Map<String, dynamic>> getTopicsDatabase() async {
  final topicRef = FirebaseWrapper.firestore().collection("topics");
  final snapshot = await topicRef.get();

  List<Map<String, dynamic>> unordered = [];
  Map<String, bool> holderChecked = {};
  topicNames = [];

  for (var doc in snapshot.docs) {
    final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
    data["color"] = Color(int.parse(data["color"]));

    // Ensure subtopics is always a List<String>
    List<String> tempSubtopics = [];
    if (data["subtopics"] != null) {
      for (var subtopic in data["subtopics"]) {
        tempSubtopics.add(subtopic.toString());
        holderChecked[subtopic.toString()] = false;
      }
    }
    data["subtopics"] = tempSubtopics;
    unordered.add(data);
    topicNames.add(data["topic"]);

    holderChecked[data["topic"].toString()] = false;
  }

  // Build ordered list without extra query
  List<Map<String, dynamic>> ordered = List.from(unordered);
  ordered.sort((a, b) => (a["order"] as int).compareTo(b["order"] as int));

  return {
    "unordered": unordered,
    "ordered": ordered,
    "checked": holderChecked,
  };
}
  
  // Future<List> getTopicsDatabase() async {
  //   List<dynamic> holderList = [];

  //   CollectionReference topicRef =
  //   FirebaseWrapper.firestore().collection("topics");
  //   QuerySnapshot topicSnapshot = await topicRef.orderBy('order').get();
  //   QuerySnapshot topicSnapshotUnordered = await topicRef.get();
    
  //   for (var doc in topicSnapshotUnordered.docs ){
  //     var data = doc.data() as Map<String, dynamic>;
  //     topicNames.add(data["topic"]);
  //   }
  //   List<Map<String, dynamic>> holder = [];
  //   Map<String, bool> holderChecked = {};
  //   for (var doc in topicSnapshot.docs) {
  //     holder.add(Map<String, dynamic>.from(doc.data() as Map<String, dynamic>));
  //     holder.last["color"] = Color(int.parse(holder.last["color"]));
  //     holderChecked[holder.last["topic"].toString()] = false;

  //     if (holder.last["subtopics"] == null) {
  //       // if subtopic field is empty
  //       List<String> tempSubtopics = [];
  //       holder.last["subtopics"] = tempSubtopics;
  //     } else {
  //       List<String> tempSubtopics = [];
  //       for (var subtopic in holder.last["subtopics"]) {
  //         tempSubtopics.add(subtopic.toString());
  //         holderChecked[subtopic.toString()] = false;
  //       }
  //       holder.last["subtopics"] = tempSubtopics;
  //     }
  //   }
  //   holderList.add(holder);
  //   holderList.add(holderChecked);

  //   return holderList;
  // }
  
  
  


 Future<void> addSingleEvent (
      DateTime date, String eventTitle, User user,{bool edit = false}) async {
    date = DateTime(date.year, date.month, date.day,0,0,0,0);
   
  // DateTime today = DateTime.now();
  
  // if (edit == false){

  // date = await findNearestFreeDate(date, 5, testDay, today, allEvents, user.uid);
 
  // }

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
      print("Adding event $eventTitle to $date\n");
    }
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

  }
 
    setState(() {});
  }


Future<void> getTopics() async {
  if (mounted) {
    setState(() => loading = true);
  }

  topicData = await getTopicsDatabase();

  if (mounted) {
    setState(() {
      topics = topicData!["ordered"];   // or "unordered" depending on use case
      checked = topicData!["checked"];
    });
  }

  topicScores = [];
  for (final map in topics) {
    List<String> subtopics = map["subtopics"];
    int score = (await Algo().getScore(user.uid, subtopics))!;
    topicScores.add(score);
  }
}
//Get all events from database, iterate over events and look for which date a flashcard topic has been scheduled 
  // Future<void> getTopics() async {
  //   if (mounted) {
  //     setState(() {
  //       loading = true;
  //     });
  //   }
    
  //   var holderList = await getTopicsDatabase();
    

  //   if (mounted) {
  //     setState(() {
  //       topics = holderList[0];
  //       checked = holderList[1];
        
  //     });
  //   }
   
  //   topicScores = [];
  //   for (final map in topics){
  //     List<String> subtopics = map["subtopics"];
  //     int score = (await Algo().getScore(user.uid, subtopics))!;
  //     topicScores.add(score);
  //   }
   
  // }

  @override
  void initState() {
    super.initState();
    setState(() {
      name = "loading...";
      loading = true;
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
 
    // await getUser();
    // await getTopics();
    // await userData();
    // await getflashcardEvents();
    // await getStats();
    // await _computeRows();

    await getUser();

    await Future.wait(
    [getTopics(),
     getflashcardEvents(),
     getStats()]);

    await _computeRows();
     setState((){
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
    return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } 
    return Scaffold(
      drawer: const DrawMain2(),
      appBar: CustomAppBar(
        title: 'Flashcard Tutor',
      ),
        body:  Center(
      child: loading
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
        child: Padding(
          padding : const EdgeInsets.symmetric(vertical:0,horizontal:2),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: makeColumn(),
        ),
      ),
    ),),
      floatingActionButton: const CustomFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
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
      
      try {
        testDay = querySnapshot.docs.last['TestDay'].toDate();
      }catch (e){
        // If testDay hasn't been set, assign a default value
        testDay = DateTime.now();
      }
      // _firstStudyDate = DateTime.fromMicrosecondsSinceEpoch(
      //     querySnapshot.docs.last["firstStudyDay"].microsecondsSinceEpoch);
    });
  }

  Future<void> getStats() async {
    TopicStats stats = await LastRevised.getStats();
    if (mounted) {
      setState(() {
        totalCards = stats.totalCards;
        seenCards = stats.seenCards;
       
      });
    }
  }

  Future<void> _computeRows() async{
    final DateTime today = DateTime.now();
    final List<TopicRow> newRows = [];
    final List<Future<void>> sideEffects = [];
  for (final map in topics) {
    final topic = map["topic"] as String;
    final idx = topicNames.indexOf(topic);
    int seen = seenCards[topic] ?? 0;
    int total = totalCards[topic] ?? 0;
    int score = topicScores[(map["order"]-1)];
    final isComplete = (total > 0 && seen >= total) && (score >= total);
    // determine current scheduled date for this topic (if any)
    DateTime? dateInCalendar;
    DateTime? nextReview;
    Event? existing;
    final allMatches = selectedEvents.entries
    .expand((entry) => entry.value.map((e) => (date: entry.key, event: e)))
    .where((pair) => pair.event.title.contains(topic))
    .toList();

     
      allMatches.sort((a, b) => a.date.compareTo(b.date));

      if (allMatches.isNotEmpty) {
        final earliest = allMatches.first;   // earliest
        final secondEarliest = allMatches.length > 1 ? allMatches[1] : null; // 2nd earliest

        dateInCalendar = DateTime(
            earliest.date.year, earliest.date.month, earliest.date.day);
        existing = earliest.event;

        if (secondEarliest != null) {
          nextReview = DateTime(
              secondEarliest.date.year, secondEarliest.date.month, secondEarliest.date.day);
        }
        else{
          nextReview = dateInCalendar;
        }
      }
    
    

    // compute “how long since last seen” and gap days map
    
    final daysSince = (Timestamp.now().seconds - topicLastSeen![idx].seconds) / (60 * 60 * 24);
    
 
   
    Color tileColor;
    String dateText = "N/A";
    if (dateInCalendar == null) {
      tileColor = const Color(0xFFD9D9D9);
    } else if ((dateInCalendar.isBefore(today) || dateInCalendar.isAtSameMomentAs(today))) {
      tileColor = const Color(0xFFFF9595);
      dateText = DateFormat('dd/MM/yyyy').format(dateInCalendar);
    } else {
      // recently reviewed vs grey
      tileColor = (daysSince <= 36) ? const Color(0xFFB0FFC6) : const Color(0xFFD9D9D9);
      dateText = DateFormat('dd/MM/yyyy').format(dateInCalendar);
    }

    // if complete -> schedule next (idempotent & NO UI rebuilds here)
    if (isComplete){
      
        print("Updating to complete\n");
        if(dateInCalendar == null){
            tileColor = const Color(0xFFB0FFC6);
        }
        else{
      sideEffects.add(updateOneEvent(existing!, "Completed: $topic ", dateInCalendar!));
        
      // Reset seen on backend (once)
      sideEffects.add(LastRevised.resetSeenCardsForTopic(topic));
      // set presentation for complete state
        tileColor = const Color(0xFFB0FFC6);
        dateText = DateFormat('dd/MM/yyyy').format(nextReview!);}
    }

    final List<String> subs = (map["subtopics"] as List?)
        ?.map((e) => e.toString())
        .toList() 
    ?? const [];

    newRows.add(TopicRow(
      topic: topic,
      formattedDate: dateText,
      color: tileColor,
      seen: seen,
      total: total,
      isComplete: isComplete,
      calendarDate: dateInCalendar,
      subtopics: subs,
    ));
  }
  
  if (!mounted) return;
  setState(() => _rows = newRows);
  if (sideEffects.isNotEmpty) {
    Future.microtask(() async {
      try {
        await Future.wait(sideEffects);
      } catch (e) {
        if (kDebugMode) {
          print("Side effects failed: $e");
        }
      }
    });
  }
  
  }

  

  List<Widget> makeCheckboxListFromRows() {
  final List<Widget> tiles = [];
  for (int i = 0; i < _rows.length; i++) {
    final row = _rows[i];

    tiles.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 15, right: 15),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hoveringIndex = i),
          onExit:  (_) => setState(() => _hoveringIndex = null),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ExpansionTile(
                  onExpansionChanged: (expanded) {
                    if (expanded) setState(() => _hoveringIndex = null);
                  },
                  trailing: Text(
                    "${row.seen} / ${row.total}",
                    style: const TextStyle(color: Colors.black),
                  ),
                  backgroundColor: row.color,
                  collapsedBackgroundColor: row.color,
                  textColor: Colors.black,
                  title: Text(row.topic, style: const TextStyle(color: Colors.black)),
                  leading: Checkbox(
                    side: const BorderSide(color: Colors.black, width: 1.5),
                    value: checked[row.topic] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        checked[row.topic] = value ?? false;
                        for (final s in row.subtopics) {
                          checked[s] = value ?? false;
                        }
                      });
                    },
                  ),
                  subtitle: Row(
                    children: [
                      const Text("Next Review Date: ", style: TextStyle(color: Colors.black)),
                      Text(row.formattedDate, style: const TextStyle(color: Colors.black)),
                    ],
                  ),
                  children: row.subtopics.map((s) {
                    final subSeen  = seenCards[s] ?? 0;
                    final subTotal = totalCards[s] ?? 0;
                    return CheckboxListTile(
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      secondary: Text("$subSeen / $subTotal", style: const TextStyle(color: Colors.black)),
                      value: checked[s] ?? false,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.fromLTRB(62, 0, 62, 0),
                      onChanged: (bool? v) {
                        setState(() {
                          checked[s] = v ?? false;
                          // keep the parent in sync
                          checked[row.topic] = row.subtopics.every((t) => checked[t] == true);
                        });
                      },
                      title: Text(s, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                ),
              ),

              if (_hoveringIndex == i)
                IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("Click to view subtopics", style: TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  return tiles;
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
          backgroundColor: Colors.black,
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
          children: makeCheckboxListFromRows(),
        ),
      ),

      // const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60
            
            ),
          Spacer(
            flex: 1),
          Expanded(
            flex: 1,
            child: Align(child: TextButton(
              key: const ValueKey("Revise"),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 25,
                  backgroundColor: Colors.black,
                  color: Colors.white,
                ),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40))),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
              ),

              onPressed: () async {
                // reviseCards("revise");
                reviseCards();
                

              },

              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Text(
                  'Revise',
                  selectionColor: Colors.black,
                ),
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
                      backgroundColor: Colors.black,
                ),

                onPressed: () {
                  explanationBox();
                },

                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Icon(Icons.question_mark, color: Colors.white,),
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

  List<Widget> makeMobileColumn() {
    List<Widget> widgets = [
      const SizedBox(height: 10),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Indicator(color: Color.fromRGBO(0xFA, 0xFA, 0xFA, 1), text: "Unseen"),
          const SizedBox(height: 10),
          Indicator(color: Color.fromRGBO(0xFF, 0x95, 0x95, 1), text: "Needs Review"),
          const SizedBox(height: 10),
          Indicator(color: Color.fromRGBO(0xB0, 0xFF, 0xC6, 1), text: "Recently Reviewed"),
        ],
      ),

      const SizedBox(height: 40),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: makeCheckboxListFromRows(),
        ),
      ),

      // const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // Revise button - left side
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  key: const ValueKey("Revise"),
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: reviseCards,
                  child: const Text('Revise', textAlign: TextAlign.center),
                ),
              ),
            ),

            const SizedBox(width: 12), // spacing between buttons

            // Explanation button - right side
            SizedBox(
              height: 54,
              width: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: explanationBox,
                child: const Icon(Icons.question_mark, color: Colors.white),
              ),
            ),
          ],
        ),
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
      //Need to fix this for the logic of dark mode vs light mode 
      backgroundColor: Colors.black, 
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

  Future<void> reviseCards()async {
    List<String> selectedSubtopics = [];

    for (var key in checked.keys) {
      if (checked[key] == true) {
        selectedSubtopics.add(key);
      }
    }
    if (selectedSubtopics.isNotEmpty) {
      await Navigator.push(
                context,
                ExpandRoute(page: AboveEverything(subtopics: selectedSubtopics, count: 0)),
              ).then((_) async {
                // Refresh data after returning
                setState(() => loading = true);
                await getData(); 
                setState(() => loading = false);
              });
      
      if (!mounted){
        return;
        
        }
          
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



// Future<bool> _isExcludedDay(DateTime date, String userId) async {
  //   try {
  //     QuerySnapshot querySnapshot =
  //         await _userCollectionRef.where("userID", isEqualTo: userId).get();
  //     if (querySnapshot.docs.isEmpty) return false;

  //     var userData = querySnapshot.docs.last.data() as Map<String, dynamic>;
  //     if (!userData.containsKey('excludedDays')) return false;

  //     List<String> excludedDays = List<String>.from(userData['excludedDays']);
  //     String dayName = _getDayName(date.weekday);
  //     return excludedDays.contains(dayName);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error checking excluded day: $e');
  //     }
  //     return false;
  //   }
  // }

  // String _getDayName(int weekday) {
  //   switch (weekday) {
  //     case 1:
  //       return "Monday";
  //     case 2:
  //       return "Tuesday";
  //     case 3:
  //       return "Wednesday";
  //     case 4:
  //       return "Thursday";
  //     case 5:
  //       return "Friday";
  //     case 6:
  //       return "Saturday";
  //     case 7:
  //       return "Sunday";
  //     default:
  //       return "";
  //   }
  // }




  // Future<DateTime> findNearestFreeDate(
  //     DateTime targetDate,
  //     int maxDaysToMove,
  //     DateTime testDay,
  //     DateTime today,
  //     Map<DateTime, List<Event>> generatedEvents,
  //     String userId,
  //     {int requiredSpacing = 0}) async {
  //   // First check if the target date is already available
  //   if (generatedEvents[targetDate] == null &&
  //       !await _isExcludedDay(targetDate, userId)) {
  //     return targetDate;
  //   }

  //   // Try to find a date forward (preferred direction)
  //   DateTime nextDate = targetDate;
  //   int daysForward = 0;
  //   while (nextDate.isBefore(testDay) && daysForward < maxDaysToMove) {
  //     nextDate = nextDate.add(const Duration(days: 1));
  //     daysForward++;
      
  //     // Check if this date respects both availability and required spacing
  //     if (generatedEvents[nextDate] == null &&
  //         !await _isExcludedDay(nextDate, userId)) {
  //       // If we need to maintain spacing, check adjacent days
  //       if (requiredSpacing > 0) {
  //         bool hasAdjacentEvent = false;
          
  //         // Check days before based on spacing
  //         for (int i = 1; i <= requiredSpacing; i++) {
  //           DateTime checkDate = nextDate.subtract(Duration(days: i));
  //           if (generatedEvents[checkDate] != null) {
  //             hasAdjacentEvent = true;
  //             break;
  //           }
  //         }
          
  //         // Check days after based on spacing
  //         if (!hasAdjacentEvent) {
  //           for (int i = 1; i <= requiredSpacing; i++) {
  //             DateTime checkDate = nextDate.add(Duration(days: i));
  //             if (checkDate.isAfter(testDay)) break;
  //             if (generatedEvents[checkDate] != null) {
  //               hasAdjacentEvent = true;
  //               break;
  //             }
  //           }
  //         }
          
  //         if (!hasAdjacentEvent) {
  //           return nextDate;
  //         }
  //         // Continue searching if this date doesn't meet spacing requirements
  //         continue;
  //       }
        
  //       return nextDate;
  //     }
  //   }

  //   // If no future date found within maxDaysToMove, try searching backward
  //   DateTime prevDate = targetDate;
  //   int daysBackward = 0;
  //   while (prevDate.isAfter(today) && daysBackward < maxDaysToMove) {
  //     prevDate = prevDate.subtract(const Duration(days: 1));
  //     daysBackward++;
      
  //     // Check if this date respects both availability and required spacing
  //     if (generatedEvents[prevDate] == null &&
  //         !await _isExcludedDay(prevDate, userId)) {
  //       // If we need to maintain spacing, check adjacent days
  //       if (requiredSpacing > 0) {
  //         bool hasAdjacentEvent = false;
          
  //         // Check days before based on spacing
  //         for (int i = 1; i <= requiredSpacing; i++) {
  //           DateTime checkDate = prevDate.subtract(Duration(days: i));
  //           if (checkDate.isBefore(today)) break;
  //           if (generatedEvents[checkDate] != null) {
  //             hasAdjacentEvent = true;
  //             break;
  //           }
  //         }
          
  //         // Check days after based on spacing
  //         if (!hasAdjacentEvent) {
  //           for (int i = 1; i <= requiredSpacing; i++) {
  //             DateTime checkDate = prevDate.add(Duration(days: i));
  //             if (generatedEvents[checkDate] != null) {
  //               hasAdjacentEvent = true;
  //               break;
  //             }
  //           }
  //         }
          
  //         if (!hasAdjacentEvent) {
  //           return prevDate;
  //         }
  //         // Continue searching if this date doesn't meet spacing requirements
  //         continue;
  //       }
        
  //       return prevDate;
  //     }
  //   }

  //   // If we reach here, try the start date itself as a last resort
  //   if (generatedEvents[today] == null &&
  //       !await _isExcludedDay(today, userId)) {
  //     return today;
  //   }

  //   // If absolutely no valid date found, return the original target date
  //   // The calling methods will need to check if this date is actually usable
  //   return targetDate;
  // }
//  Future<void> _recomputeRowsAndMaybeSchedule() async {
//   final DateTime today = DateTime.now();
//   final List<TopicRow> newRows = [];

//   // guard set to avoid double scheduling within a run
//   final Set<String> scheduledThisPass = {};

//   for (final map in topics) {
//     final topic = map["topic"] as String;
//     final seen = seenCards[topic] ?? 0;
//     final total = totalCards[topic] ?? 0;
//     final isComplete = total > 0 && seen >= total;
//     // determine current scheduled date for this topic (if any)
//     DateTime? dateInCalendar;
//     Event? existing;
//     if (selectedEvents.isNotEmpty) {
//       for (var entry in selectedEvents.entries) {
//         for (var e in entry.value) {
//           if (e.title.contains(topic)) {
//             dateInCalendar = DateTime(entry.key.year, entry.key.month, entry.key.day);
//             existing = e;
            
//           }
//         }
//         if (dateInCalendar != null) break;
//       }
//     }

//     // compute “how long since last seen” and gap days map
//     final idx = topicNames.indexOf(topic);
//     final daysSince = (Timestamp.now().seconds - topicLastSeen![idx].seconds) / (60 * 60 * 24);
//     final Map<int,int> gap = {
//       0: (daysSince.ceil() * 4) + 1,
//       1: 6, 2: 10, 3: 16, 4: 24, 5: 36
//     };
//     final int count = (topicCount![idx] as int).clamp(0, gap.length - 1);
//     final int gapDays = gap[count] ?? ((daysSince.ceil() * 4) + 1); // 1 day default if key missing
//     final DateTime nextReview = (dateInCalendar ?? today).add(Duration(days: gapDays));
   

//     // decide color + date text (pure)
//     Color tileColor;
//     String dateText = "N/A";
//     if (dateInCalendar == null) {
//       tileColor = const Color(0xFFD9D9D9);
//     } else if ((seen == 0) && (dateInCalendar.isBefore(today) || dateInCalendar.isAtSameMomentAs(today))) {
//       tileColor = const Color(0xFFFF9595);
//       dateText = DateFormat('dd/MM/yyyy').format(dateInCalendar);
//     } else {
//       // recently reviewed vs grey
//       tileColor = (daysSince <= 2.0) ? const Color(0xFFB0FFC6) : const Color(0xFFD9D9D9);
//       dateText = DateFormat('dd/MM/yyyy').format(dateInCalendar);
//     }

//     // if complete -> schedule next (idempotent & NO UI rebuilds here)
//     if (isComplete && !scheduledThisPass.contains(topic)) {
//       // 1) mark today as “Completed: …” if needed
//       // 2) add next “<topic> Flashcards” ONLY if it does not already exist on that date
//       // 3) reset seen for topic (server) — but do NOT call userData/getStats here
//       // 4) finally, update local presentation: set tile green + next date

//       // IDENTITY / IDEMPOTENCY CHECKS
//       final String nextTitle = "$topic Flashcards";
//       final bool alreadyHasNext = selectedEvents[nextReview]
//               ?.any((e) => e.title == nextTitle) ?? false;

//       if (!alreadyHasNext) {
//         // move “future” completion to today if needed
//         if (dateInCalendar != null && dateInCalendar.isAfter(today)) {
//           await updateOneEvent(existing!, "Completed: $topic ", today, oldDate: dateInCalendar);
//           dateInCalendar = today;
//         } else if (dateInCalendar != null) {
//           await updateOneEvent(existing!, "Completed: $topic ", dateInCalendar!);
//         }

//         await addSingleEvent(nextReview, nextTitle, user);
//         // Reset seen on backend (once)
//         await LastRevised.resetSeenCardsForTopic(topic);
//         scheduledThisPass.add(topic);
//       }

//       // set presentation for complete state
//       tileColor = const Color(0xFFB0FFC6);
//       dateText = DateFormat('dd/MM/yyyy').format(nextReview);
//     }

//     final List<String> subs = (map["subtopics"] as List?)
//         ?.map((e) => e.toString())
//         .toList() 
//     ?? const [];

//     newRows.add(TopicRow(
//       topic: topic,
//       formattedDate: dateText,
//       color: tileColor,
//       seen: seen,
//       total: total,
//       isComplete: isComplete,
//       calendarDate: dateInCalendar,
//       subtopics: subs,
//     ));
//   }

//   if (!mounted) return;
//   setState(() => _rows = newRows);
// }

}