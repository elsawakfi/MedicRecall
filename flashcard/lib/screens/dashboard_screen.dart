import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/screens/study_session_manager.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/widgets/event.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/calendar_screen.dart';
import 'package:flashcard_x/screens/feed_screen.dart';
import 'package:flashcard_x/screens/button_screen.dart';
import '../utils/page_transition.dart';
import 'package:intl/intl.dart';


class HomePage extends StatefulWidget {
  static String id = 'home';

  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  late User user;
  late String? name;
  late String? id;
  late List<dynamic>? topicCount;
  List<dynamic>? topicLastSeen;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool loading = true;
  List<Map<String, dynamic>> topics = [];
  Map<String, bool> checked = {};
  Map<String, int> seenCards = {};
  Map<String, int> totalCards = {};
  late DateTime testDay; 
  late DateTime _firstStudyDate;
  late Map<DateTime?, List<Event>> selectedEvents;
  late CollectionReference _eventsCollectionRef;
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');
  StudySessionManager studySessionManager = StudySessionManager();


  double spacing = 16;

  Future<List> getTopicsDatabase() async {
    List<dynamic> holderList = [];

    CollectionReference topicRef =
    FirebaseFirestore.instance.collection("topics");
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

  Future<void> getTopics() async {
    setState(() {
      loading = true;
    });

    var holderList = await getTopicsDatabase();

    setState(() {
      topics = holderList[0];
      checked = holderList[1];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
   
    setState(() {
      name = "loading...";
      selectedEvents = {};
    });
    getData();

    setState(() {});
  }

  Future<void> getData() async {
    await  getUser();
    print("User\n");
    await getStats();
    print("Stats\n");
    await getTopics();
    print("Topicas\n");
    //issue with getFirstStudyDay, takes too long but if you put it as the first getter function, the page does not 
    //build 
    await  getFirstStudyDay();
    print("El primer dia de estudiar\n");
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _key,
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
                child: const Text('Flashcard Tutor',
                ),
              ),
            ],
          ),
        ),

        centerTitle: true,
        elevation: 0,
        leading: GestureDetector(
          key: const ValueKey('Navbar'),
          onTap: () => _key.currentState!.openDrawer(),
          child: const Icon(
            Icons.menu, // add custom icons also
            // color: Colors.black,
          ),
        ),
      ),

      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: makeColumn(),
                ),
              ),
      ),
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
      loading = false;
      testDay = querySnapshot.docs.last['TestDay'].toDate();
    }); 
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
            
            
            selectedEvents[date] = events.map((title) => Event(
              title: title,
              color : Colors.yellow
            )).toList();
          }
        } 

        }
        } catch(e){
       print("Error loading events from DB: $e");
      } 
    //This is how we sync the calendar screen and the flashcard tutor screen over these events
    //await getEventsFromDB();
    
  }

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
      for (var doc in snapshots.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('date') && data.containsKey('events')) {
          Timestamp? timestamp = data['date'] as Timestamp?;
          List<dynamic>? eventsList = data['events'] as List<dynamic>?;
          
          if (timestamp != null && eventsList != null) {
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
    } catch (e) {
      print("Error loading events from DB: $e");
    }
  }

  Future<void> getStats() async {
    setState(() {
      loading = true;
    });
    CollectionReference flashcardRef =
        FirebaseFirestore.instance.collection('flashcards');
    CollectionReference seenRef = FirebaseFirestore.instance
        .collection("users/${id!}/flashcardsSeen");
    QuerySnapshot seen = await seenRef.get();
    QuerySnapshot all =
        await flashcardRef.where("owner", isEqualTo: "all").get();
    QuerySnapshot userCards =
        await flashcardRef.where("owner", isEqualTo: id).get();

    for (var doc in seen.docs) {
      DocumentSnapshot card = await flashcardRef.doc(doc["cardID"]).get();
      if (card.exists) {
        Map<String, dynamic> data = card.data() as Map<String, dynamic>;
        incrementMap(seenCards, data["topic"].toString());
        if (data["subtopic"] != "") {
          incrementMap(seenCards, data["subtopic"].toString());
        }
      }
    }
                                                 //to do: change this to only load cards selected
    for (var doc in all.docs + userCards.docs) { //This loads all the cards during the dashboard screen loading process...
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // print(data.toString());
        incrementMap(totalCards, data["topic"].toString());
        if (data["subtopic"] != "") {
          incrementMap(totalCards, data["subtopic"].toString());
        }
      }
    }

    setState(() {
      loading = false;
    });
  }

  void incrementMap(Map<String, int> map, String key) {
    if (map.containsKey(key)) {
      map.update(key, (i) => map[key]! + 1);
      return;
    }
    map[key] = 1;
  }

  Future<void> getFirstStudyDay() async {
    
      QuerySnapshot u =
          await _userCollectionRef.where("userID", isEqualTo: user.uid).get();

      var userFromDb = u.docs.first;
      Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
      // If the Test Day field isn't null and is in the database we update the UI with it. Otherwise it is displayed as being not set.
      if (data.containsKey("firstStudyDay") && data["firstStudyDay"] != null) {
        // firstDayBool = false;
        _firstStudyDate = DateTime.fromMicrosecondsSinceEpoch(
            userFromDb["firstStudyDay"].microsecondsSinceEpoch);
      }

      setState(() {});
    
  }

  //Formats the checkbox categories according to colour depending on whether the review date is due and how many flashcards have been seen.
  List<ExpansionTile> makeCheckboxList() {

    List<ExpansionTile> value = [];
    for (var i = 0; i < topics.length; i++) {

      var map = topics[i];
      int numCards = seenCards[map["topic"]] ?? 0;
      
      var shade = numCards / (totalCards[map["topic"]]?? 1)*100;
      var text = seenCards[map["topic"]] == null
          ? "0"
          : seenCards[map["topic"].toString()].toString();


      //Number of days since topic was last revised is converted from seconds to days as an int
      var howLongAgoRevisedDays = (Timestamp.now().seconds - topicLastSeen![i].seconds) / (60 * 60 * 24);

      //A mapping of how many times the topics been seen to what the next review date gap should be. After 7 times it stays at 128 days.
      Map<int, int> dateToColourMap = {0: ((howLongAgoRevisedDays.ceil()*4)+1), 1: 2, 2: 4, 3: 8, 4: 16, 5: 32, 6: 64, 7: 128};
      MaterialColor topicColour = Colors.green;
      if (topicCount![i]>(dateToColourMap.length-1)){
        topicCount![i]=dateToColourMap.length-1;
      }

      
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyy').format(DateTime.now());
      //int increment = 0; 
      List<Event>? eventsForDate;
     
      //DateTime targetDate = DateTime(_firstStudyDate.year, _firstStudyDate.month, _firstStudyDate.day, 0, 0, 0, 0);
      DateTime targetDate = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);
      while (targetDate.isBefore(testDay) || targetDate.isAtSameMomentAs(testDay)){
        eventsForDate = selectedEvents[targetDate];
        
        //targetDate = DateTime(_firstStudyDate.year, _firstStudyDate.month, _firstStudyDate.day+increment, 0, 0, 0, 0);
        
        
        //int index = 0; 
      
        
        if (eventsForDate != null) {
          print("Events : $eventsForDate \n");
          
          
          for (Event event in eventsForDate) {
          if (event.toString().contains(map["topic"])){
            print("Title is: ${event.toString()} and is on $targetDate\n");
            if(targetDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day, 0, 0, 0, 0))){
              formattedDate = "Today";
              DateTime rescheduledDate = DateTime(targetDate.year, targetDate.month, targetDate.day+7, 0, 0, 0, 0);
              CalendarStateO().addSingleEvent(rescheduledDate, topics[i].toString(), user);
              //formattedDate = DateFormat('dd/MM/yyy').format(rescheduledDate);
            }
            else if(targetDate.isBefore(now)){
              //reschedule study session.....
              DateTime rescheduledDate = DateTime(targetDate.year, targetDate.month, targetDate.day+7, 0, 0, 0, 0);
              CalendarStateO().addSingleEvent(rescheduledDate, topics[i].toString(), user);
              formattedDate = DateFormat('dd/MM/yyy').format(rescheduledDate);
            }
            
            else{
              formattedDate = DateFormat('dd/MM/yyy').format(targetDate);
            }

            if ( shade >= 70 ){
                topicColour = Colors.green;
                targetDate = testDay;
            }
            else{
              topicColour = Colors.grey;
              targetDate = testDay;
            }
            
         } 
          
      }
}     else { 
          if (shade >= 70) {
            topicColour = Colors.green;}
          else{
           topicColour = Colors.grey;
          }    
          formattedDate = "N/A";
}
      
 targetDate = targetDate.add(Duration(days: 1)); 
}
    int nextReviewDateMilliseconds = (((dateToColourMap[topicCount![i]]! * 24 * 60 * 60) + topicLastSeen![i].seconds) * 1000).toInt();
    DateTime nextReviewDate = DateTime.fromMillisecondsSinceEpoch(nextReviewDateMilliseconds, isUtc: true).toLocal();
      if (dateToColourMap[topicCount![i]]! < howLongAgoRevisedDays) {
        topicColour = Colors.red;
        formattedDate = DateFormat('dd/MM/yyy').format(nextReviewDate);
      }
      value.add(
          ExpansionTile(
          trailing: Text(
              "$text / ${totalCards[map["topic"].toString()]}",
              style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: topicColour,
          collapsedBackgroundColor: topicColour,
          textColor: Colors.black,
          title: Text(
              "${map["topic"]}  ${map["emoji"]}",
              style: const TextStyle(color: Colors.white),
          ),
          leading: Checkbox(
            side: const BorderSide(
                    color: Colors.white,
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
                style: TextStyle(color: Colors.white),
              ),
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          children: makeCheckbox(map)));
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
            color: Colors.white,
            width: 1.5),
        secondary: Text(
          "$text / ${totalCards[subtopic.toString()]}",
          style: const TextStyle(color: Colors.white),
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
          style: const TextStyle(color: Colors.white),
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
          backgroundColor: const Color.fromRGBO(67, 67, 67, 1.0),
          title: const Text('Instructions',
              style: TextStyle(
                color: Colors.white,
              )
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '1. Start a revision session by completing one or more of our flashcard decks.\n'
                      '2. Work through each question, ensuring that you answer the question in your head before flipping the card (active recall).\n'
                      '3. Click the tick or cross next to the flashcard to indicate whether you have mastered the card.\n'
                      '4. At the end of each deck, you will be prompted to review all the cards that you are still learning before moving on.\n'
                      '5.	Once completed, the deck will turn green.\n'
                      '6. After two days, the categories will turn red, signifying that it is time to review the deck again.\n'
                      '7. Repeat this cycle throughout your revision periods; the time between repetitions will increase with successive reviews.\n'
                      '8.	If you wish to receive email reminders when a topic is overdue, you can turn on this feature in our settings tab.',
                    style: TextStyle(
                      color: Colors.white,
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
      const SizedBox(height: 40),
      Container(
          width:1200,
          height: 200,
          margin: const EdgeInsets.only(bottom: 10.0, left: 30.0, right: 30.0),
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(10.0),
          ),
        child: const Center(
          child: SingleChildScrollView(
            child: Text(
              "Our pre-made flashcard decks contain hundreds of high-yield questions,\n"
                  " all derived from UFPO and GMC guidance. It uses our unique spaced repetition system to help you\n"
                  "to learn and retain more content in less time.",
              //get the question from the map
              textAlign: TextAlign.center,
              style: TextStyle(
              fontSize:26,
              color: Colors.white,
              )
            )
          ),
        ),

      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(0, 160, 227, 1),
              side: const BorderSide(
                  color: Color.fromRGBO(0, 160, 227, 1), width: 2),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100))),
            ),

            onPressed: () {
              explanationBox();
            },

            child: const Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text('How does it work?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w500)),
            ),
          ),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
            key: const ValueKey("Revise"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(0, 160, 227, 1),
              side: const BorderSide(
                  color: Color.fromRGBO(0, 160, 227, 1), width: 2),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100))),
            ),

            onPressed: () {
              // reviseCards("revise");
              reviseCards();
            },


            child: const Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text('Revise',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w500)),
            ),
          ),
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
          'Alert'),
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