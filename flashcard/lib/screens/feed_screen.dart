import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/comment_screen.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/utils/algo.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiping_card_deck/swiping_card_deck.dart';
import 'package:flashcard_x/screens/calendar_screen.dart';
import 'package:flashcard_x/widgets/design_main.dart';

import '../utils/page_transition.dart';

class AboveEverything extends StatelessWidget {
  //builds a ChangeNotifierProvider around the Feed, which
  final List<String>
      subtopics; //lets us keep track of what state has changed, and rebuild
  final int count; //widgets accordingly.
  const AboveEverything(
      {Key? key, required this.subtopics, required this.count})
      : super(key: key);
  @override
  //hello
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AboveEverythingState(),
        child: Feed(subtopics: subtopics, count: count));
  }
}

class AboveEverythingState extends ChangeNotifier {
  //This is a state that has scope above all other widgets in this
  var lastFlipped = DateTime
      .now(); //page, It is used to keep track of the time that has elapsed
  void setTime() {
    //since the tick or cross buttons were last pressed
    lastFlipped = DateTime
        .now(); //which is used in determining when to activate and deactivate
  } //the AbsorbPointer.
}

class MrAbsorbyManager {
  //Object which governs the activation of the AbsorbingPointer
  final ValueNotifier<bool> absorbingOn = ValueNotifier<bool>(false);
  final ValueNotifier<int> timerNotifier =
      ValueNotifier<int>(MrAbsorbyManager.timeToWait);
  static const int timeToWait = 5;
  Future<void> doRigamarole() async {
    //Turns the AbsorbingPointer on, waits 5 seconds and then turns it off
    absorbingOn.value = true;
    // for counting down the timer
    for (int i = MrAbsorbyManager.timeToWait; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      timerNotifier.value =
          i; //when it hits 0, we want to end at that exact moment so it should be this way 'round
    }
    absorbingOn.value = false;
  }
}

class MrContManager {
  //Object which governs the activation of the tick and AbsorbingPointer
  final ValueNotifier<bool> absorbingOn = ValueNotifier<bool>(false);
  static const int timeToWait = 5800;
  Future<void> doRigamarole() async {
    //Turns the AbsorbingPointer on, waits 5.8 seconds and then turns it off (This prevents a bug with the flipping AbsorbingPointer)
    absorbingOn.value = true;
    await Future.delayed(const Duration(milliseconds: timeToWait));
    absorbingOn.value = false;
  }
}

class Feed extends StatefulWidget {
  static final navKey = GlobalKey<NavigatorState>();
  // final String choice;
  final List<String> subtopics;
  final int count;

  const Feed({Key? navKey, required this.subtopics, required this.count})
      : super(key: navKey);

  @override
  State<StatefulWidget> createState() =>
      // ignore: no_logic_in_create_state
      _FeedState(subtopics, count);
}

class _FeedState extends State<Feed> {
  final ValueNotifier<int> completedCardsNotifier = ValueNotifier<int>(0);
  final List<String> subtopics;
  final int count;
  late int flashcardIndex;
  int length = 10;
  int preCardval = 2;
  int selectedValue1 = 2;
  int score = 0;
  int completedFlashcards = 0;

  late bool loading;
  bool flipped = false;
  bool finished = false;
  late User user;

  List<Card> cards = [];

  bool flippable = false;
  late DateTime firstSeen;

  double cardWidth = 400;
  double cardHeight = 600;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');
  late CollectionReference _flashcardsSeenRef;
  late List<Map<String, dynamic>> flashcards;
  final MrAbsorbyManager mrManager = MrAbsorbyManager();
  final MrContManager mrCont = MrContManager();

  _FeedState(this.subtopics, this.count);
  late String title;
  get key => null;
  get export => null;
  void home() {
    updateCalendarEvents();
    Navigator.of(context).popUntil((route) => false);
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const HomePage(title: 'Home')));
  }

  @override
  void initState() {
    setState(() {
      flashcardIndex = -1;
      //Structure of flashcard
      flashcards = [
        {
          "front": "loading",
          "back": "loading",
          "topic": "loading",
          "resource": "loading"
        }
      ];
      loading = true;
      title = "Flashcards";
    });

    getData().then((_) {
      // make sure that the timer doesn't start before the flashcard is loaded
      mrManager.doRigamarole();
      mrCont.doRigamarole();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Feed.navKey;
    SwipingCardDeck deck = displayDeck();
    updateFirstSeen();
    RefreshDesignMain refreshDesignMain = RefreshDesignMain();

    return Scaffold(
        appBar: refreshDesignMain.appBarMain(title, context),
        body: Stack(
          children: [
            Visibility(
              visible: !finished,
              child: Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    color: Colors.blue,
                    padding: const EdgeInsets.all(8.0),
                    child: ValueListenableBuilder<int>(
                      valueListenable: completedCardsNotifier,
                      builder: (context, completed, _) {
                        return Text(
                          '$completed / $length',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            Center(
              key: const ValueKey('flashcard center'),
              child: Visibility(
                  visible: cards.isNotEmpty && !finished,
                  child: FittedBox(
                      child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: ValueListenableBuilder<bool>(
                            //AbsorbPointer contained within a ValueListenableBuilder
                            valueListenable: mrManager
                                .absorbingOn, //allows dynamic rebuilding of a widget depending
                            builder: (BuildContext context, bool value, child) {
                              //on changes to state (in this case the state of the mrAbsorbyManager)
                              return AbsorbPointer(
                                absorbing: value,
                                child: deck,
                              );
                            },
                          )))),
            ),
            // display the timer on the screen
            Positioned(
              top: 20,
              left: 20,
              child: ValueListenableBuilder<int>(
                valueListenable: mrManager.timerNotifier,
                builder: (context, value, child) {
                  return Text(
                    'Time left before you can flip the card: $value seconds',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            Center(
                child: Visibility(
              visible: loading,
              child: const CircularProgressIndicator(),
            )),
            Center(
                child: Visibility(
              visible: finished,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //After completion, display:
                  const Text(
                    "Congrats!",
                    style: TextStyle(fontSize: 38),
                  ),
                  const SizedBox(height: 40),
                  Visibility(
                    visible: true,
                    child: Text(
                        "You have no more cards to revise. Your score is $score"),
                  ),
                  const SizedBox(height: 40),
                  MaterialButton(
                    key: const ValueKey('HomePage/CompleteCardsChecker'),
                    shape: const CircleBorder(),
                    color: Theme.of(context).primaryColor,
                    //color: Colors.black,
                    padding: const EdgeInsets.all(20),
                    onPressed: home,
                    child: const Icon(
                      Icons.amp_stories,
                      size: 30,
                    ),
                  ),
                ],
              ),
            )),
            //This section of code is used to implement the green check mark feature next to the flashcard.
            Visibility(
              visible: !loading && !finished,
              child: Positioned(
                left: MediaQuery.of(context).size.width / 2 + 200,
                top: MediaQuery.of(context).size.height / 2 - 70,
                child: ValueListenableBuilder<bool>(
                    //AbsorbPointer contained within a ValueListenableBuilder
                    valueListenable: mrCont
                        .absorbingOn, //allows dynamic rebuilding of a widget depending
                    builder: (BuildContext context, bool value, child) {
                      //on changes to state (in this case the state of the mrAbsorbyManager)
                      return AbsorbPointer(
                          absorbing: value,
                          child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Tooltip(
                                  message: 'Mastered',
                                  margin: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    onPressed: () {
                                      updateFirstSeen();
                                      mrManager
                                          .doRigamarole(); //activate the absorber for timeToWait seconds
                                      mrCont
                                          .doRigamarole(); //activate the continue absorber for 5.8 seconds
                                      deck.swipeRight();
                                    },
                                    icon: const Icon(Icons.check),
                                    color: Colors.green,
                                    iconSize: 80,
                                  ))));
                    }),
              ),
            ),
            //This section of code is used to implement the red cross mark feature next to the flashcard.
            Visibility(
              visible: !loading && !finished,
              child: Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 300,
                  top: MediaQuery.of(context).size.height / 2 - 70,
                  child: ValueListenableBuilder(
                      valueListenable: mrCont.absorbingOn, //when the absorbingOn variable changes, rebuild the AbsorbingPointer with the new value of absorbing.
                      builder: (BuildContext context, bool value, child) {
                        return AbsorbPointer(
                            absorbing: value,
                            child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Tooltip(
                                    message: 'Still learning',
                                    margin: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                      onPressed: () {
                                        updateFirstSeen();
                                        mrCont.doRigamarole();
                                        mrManager.doRigamarole(); //activate the absorber for timeToWait seconds
                                        deck.swipeLeft();
                                      },
                                      icon: const Icon(Icons.close),
                                      color: Colors.red,
                                      iconSize: 80,
                                    ))));
                      })),
            ),
          ],
        ),
        floatingActionButton: Visibility(
          visible: !loading && !finished,
          child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  ExpandRoute(
                      page: CommentSection(
                    cardID: flashcards[flashcardIndex + 1]["id"],
                  )),
                );
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.messenger)),
        ));
  }

  //Handle the logic for switching to the next card
  SwipingCardDeck displayDeck() {
    return SwipingCardDeck(
      cardDeck: cards,
      onDeckEmpty: () => goHome(subtopics, count),
      onLeftSwipe: (Card card) => nextCardLeft(),
      onRightSwipe: (Card card) => nextCardRight(),
      cardWidth: cardWidth,
      swipeThreshold: MediaQuery.of(context).size.width / 12,
      minimumVelocity: 1000,
      rotationFactor: 0.8 / 3.14,
      swipeAnimationDuration: const Duration(milliseconds: 500),
    );
  }

  void updateFirstSeen() {
    firstSeen = DateTime.now();
  }

  //We call the generateEvents function in the calendar_state file to update the calendar and database with the new next revision dates after we finish a flashcard deck
  Future<void> updateCalendarEvents() async {
    QuerySnapshot querySnapshot =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    var userFromDb = querySnapshot.docs.first;
    if ((userFromDb.data() as Map<String, dynamic>).containsKey("TestDay")) {
      Timestamp timestamp = userFromDb["TestDay"];
      DateTime testDate = timestamp.toDate();
      CalendarStateO calendarStateO = CalendarStateO();
      await calendarStateO.generateEvents(testDate, user);
    }
  }

  Future<void> getData() async {
    await getUser();

    // if (choice == "revise") {
    //   flashcards = await Algo().getCards(subtopics, user.uid);
    // } else if (choice == "new") {
    //   flashcards = await Algo().newCards(subtopics, user.uid);
    // }

    flashcards = await Algo().newCards(subtopics, user.uid);
    var oldCards = await Algo().getCards(subtopics, user.uid);
    flashcards.addAll(oldCards);
    length = flashcards.length; //length = The total number of cards
    if (length > 0) {
      await resetTimesSeen();
    }
    score = (await Algo().getScore(user.uid, subtopics))!;

    if (length != 0) {
      getCardDeck();

      setState(() {
        loading = false;
      });
      //nextCard();
    } else {
      setState(() {
        loading = false;
        finished = true;
      });
    }
  }

  //When answered correctly
  void nextCardRight() {
    if (kDebugMode) {
      //print(flashcards.length);
    }
    if (!loading) {
      flashcardIndex += 1; //Get next card
      flipped = false;
      if (flashcardIndex >= flashcards.length) {
        setState(() {
          finished = true;
        });
      }

      completedCardsNotifier.value++;
      score++;
      updateSeenCorrect();
      mrManager.doRigamarole();

      // version : bar appears on the bottom of the screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Correct!',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void goHome(List<String> subtopics, int count) {
    if (flashcards.isEmpty) {
      debugPrint("Card deck empty.\n Your score is $score");
    } else {
      count++;
      Navigator.push(
        context,
        ExpandRoute(
            page: Feed(
          subtopics: subtopics,
          count: count,
        )),
      );
    }
  }

  //When answering incorrectly
  void nextCardLeft() {
    if (!loading) {
      flashcardIndex += 1; //Get next card
      flipped = false;
      if (flashcardIndex >= flashcards.length) {
        setState(() {
          finished = true;
        });
      }

      completedCardsNotifier.value++;
      updateSeenIncorrect();
      mrManager.doRigamarole();

      //version : bar appears on the bottom of the screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Wrong!',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

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

    //firebase data
    QuerySnapshot u =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    String id = u.docs.last.id;

    _flashcardsSeenRef =
        FirebaseFirestore.instance.collection("users/$id/flashcardsSeen");
  }

  Future<void> updateSeenIncorrect() async {
    if (!finished) {
      if (flashcardIndex + 1 == length) {
        updateTopicCountAndTopicLastSeen();
        setState(() {
          finished = true;
        });
      }

      //int cardValDB = cardValue;
      QuerySnapshot querySnapshot = await _flashcardsSeenRef
          .where("cardID", isEqualTo: flashcards[flashcardIndex]["id"])
          .get();

      bool exists = querySnapshot.docs.isNotEmpty;

      if (!exists) {
        _flashcardsSeenRef.add({
          "cardID": flashcards[flashcardIndex]["id"],
          "lastSeen": Timestamp.fromDate(
              Timestamp.now().toDate().subtract(const Duration(days: 128))),
          "timesSeen": 1,
          "score": [0],
          "gotRight": false
        });
      } else {
        var timesSeen = querySnapshot.docs.first["timesSeen"];
        var tempId = querySnapshot.docs.first.id;
        timesSeen += 1;
        List<dynamic> cardScore = querySnapshot.docs.first["score"];
        //cardScore[0] = 0;
        _flashcardsSeenRef.doc(tempId).update({
          "cardID": flashcards[flashcardIndex]["id"],
          "timesSeen": timesSeen,
          "score": cardScore,
          "gotRight": false
        });
      }
    }

    QuerySnapshot u =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    var userDoc = u.docs.last;

    var topicsSeen = [];

    Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

    if (data["topicsSeen"] != null) {
      topicsSeen = data["topicsSeen"];
    }

    var flashcardTopic = flashcards[flashcardIndex]["topic"];

    if (!topicsSeen.contains(flashcardTopic)) {
      topicsSeen.add(flashcardTopic);
      _userCollectionRef.doc(userDoc.id).update({"topicsSeen": topicsSeen});
    }
  }

  Future<List<Map<String, dynamic>>> getTopicDetails() async {
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

    return holder;
  }

  Future<List<bool>> getTopicList() async {
    List<Map<String, dynamic>> topics = await getTopicDetails();
    List<bool> containsTopic = [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ];
    for (var i = 0; i < topics.length; i++) {
      var map = topics[i];
      containsTopic[i] = true;

      if (map["subtopics"].length == 0) {
        if (subtopics.contains(map["topic"])) {
        } else {
          containsTopic[i] = false;
        }
      } else {
        containsTopic[i] = false;
        for (var n = 0; n < map["subtopics"].length; n++) {
          if (subtopics.contains(map["subtopics"][n])) {
            containsTopic[i] = true;
          }
        }
      }
    }
    return containsTopic;
  }

  Future<void> updateTopicCountAndTopicLastSeen() async {
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
        await usersRef.where("userID", isEqualTo: user.uid).get();

    String id = querySnapshot.docs.last.id;

    List<dynamic> topicCount = querySnapshot.docs.last["topicCount"];

    List<dynamic> topicLastSeen = querySnapshot.docs.last["topicLastSeen"];

    List<bool> containsTopic = await getTopicList();
    List<Map<String, dynamic>> topics = await getTopicDetails();

    var databaseFlashcards = await Algo().getFlashcards(user.uid);
    List<dynamic> topicList = [];
    List<int?> score = [];

    for (var i = 0; i < containsTopic.length; i++) {
      score.add(0);

      if (containsTopic[i] == true) {
        topicList.add(topics[i]["topic"]);
        bool flashcardExists =
            flashcards.any((flashcard) => flashcard["topic"] == topicList[i]);
        if (flashcardExists == false) {
          containsTopic[i] = false;
        }
      } else {
        topicList.add("");
      }
    }

    for (var flashcard in databaseFlashcards) {
      if ((topicList.contains(flashcard["topic"]) ||
              topicList.contains(flashcard["topic"]) &&
                  flashcard["subtopic"] == "") &&
          flashcard["gotRight"] == true) {
        var topicListIndex = topicList.indexOf(flashcard["topic"]);
        score[topicListIndex] = score[topicListIndex]! + 1;
      }
    }

    var totalCards = [];
    for (var i = 0; i < containsTopic.length; i++) {
      totalCards.add(0);
      if (containsTopic[i]) {
        totalCards[i] = topics[i]["numberOfCards"] + totalCards[i];
        if (totalCards[i] == score[i]) {
          topicCount[i] = topicCount[i] + 1;
          topicLastSeen[i] = Timestamp.now();
        }
      }
    }

    usersRef
        .doc(id)
        .update({"topicCount": topicCount, "topicLastSeen": topicLastSeen});
  }

  Future<void> updateSeenCorrect() async {
    if (!finished) {
      if (flashcardIndex + 1 == length) {
        updateTopicCountAndTopicLastSeen();
        setState(() {
          finished = true;
        });
      }

      //int cardValDB = cardValue;
      QuerySnapshot querySnapshot = await _flashcardsSeenRef
          .where("cardID", isEqualTo: flashcards[flashcardIndex]["id"])
          .get();

      bool exists = querySnapshot.docs.isNotEmpty;

      if (!exists) {
        _flashcardsSeenRef.add({
          "cardID": flashcards[flashcardIndex]["id"],
          "lastSeen": FieldValue.serverTimestamp(),
          "timesSeen": 1,
          "score": [1],
          "gotRight": true
        });
      } else {
        var timesSeen = querySnapshot.docs.first["timesSeen"];
        var tempId = querySnapshot.docs.first.id;
        timesSeen += 1;
        List<dynamic> cardScore = querySnapshot.docs.first["score"];
        cardScore[0] = cardScore[0] + 1;
        _flashcardsSeenRef.doc(tempId).update({
          "cardID": flashcards[flashcardIndex]["id"],
          "lastSeen": FieldValue.serverTimestamp(),
          "timesSeen": timesSeen,
          "score": cardScore,
          "gotRight": true
        });
      }
    }

    QuerySnapshot u =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    var userDoc = u.docs.last;

    var topicsSeen = [];

    Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

    if (data["topicsSeen"] != null) {
      topicsSeen = data["topicsSeen"];
    }

    var flashcardTopic = flashcards[flashcardIndex]["topic"];

    if (!topicsSeen.contains(flashcardTopic)) {
      topicsSeen.add(flashcardTopic);
      _userCollectionRef.doc(userDoc.id).update({"topicsSeen": topicsSeen});
    }
  }

  Future<void> resetTimesSeen() async {
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot userSnapshot =
        await usersRef.where("userID", isEqualTo: user.uid).get();

    String id = userSnapshot.docs.last.id;

    var cards = await Algo().getFlashcards(user.uid);
    List<Map<String, dynamic>> filteredCards = cards
        .where((card) =>
            (subtopics.contains(card["topic"]) && card["subtopic"] == "") ||
            subtopics.contains(card["subtopic"]))
        .toList();
    bool exists = false;

    List<Map<String, dynamic>> topics = await getTopicDetails();
    var containsTopic = await getTopicList();

    var totalCards = 0;
    for (var i = 0; i < containsTopic.length; i++) {
      List<dynamic> subtopicStrings =
          topics[i]["subtopics"].map((sub) => sub.toString()).toList();
      var intersection = subtopics
          .where((element) => subtopicStrings.contains(element))
          .toList();
      List<int> indicesMap = [];

      for (var subtopic in intersection) {
        int index = subtopicStrings.indexOf(subtopic);
        indicesMap.add(index);
      }

      for (var index in indicesMap) {
        totalCards = topics[i]["subtopicLength"][index] + totalCards;
      }
    }

    if (filteredCards.length == totalCards) {
      exists = true;
    }

    bool wrongCardExist = false;

    List<dynamic> topicScore = userSnapshot.docs.last["topicScore"];

    if (exists) {
      for (int i = 0; i < flashcards.length; i++) {
        QuerySnapshot querySnapshot = await _flashcardsSeenRef
            .where("cardID", isEqualTo: flashcards[i]["id"])
            .get();
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;

        // Retrieve timesSeen and gotRight value from the cards
        var gotRight = data["gotRight"];

        if (!gotRight) {
          wrongCardExist = true;
        }
      }

      if (!wrongCardExist) {
        for (int i = 0; i < flashcards.length; i++) {
          QuerySnapshot querySnapshot = await _flashcardsSeenRef
              .where("cardID", isEqualTo: flashcards[i]["id"])
              .get();
          var tempId = querySnapshot.docs.first.id;

          _flashcardsSeenRef
              .doc(tempId)
              .update({"timesSeen": 0, "gotRight": false});
        }

        for (int i = 0; i < containsTopic.length; i++) {
          if (containsTopic[i]) {
            var topicName = topics[i]["topic"];
            List<String> subtopic = [];
            subtopic.add(topicName);
            topicScore[i] = await Algo().getScore(user.uid, subtopic);
          }
        }

        usersRef.doc(id).update({"topicScore": topicScore});
      }
    }
  }

  void showResource(String resourceText) {
    var alert = AlertDialog(
      title: const Text("Resource"),
      content: Text(
        resourceText,
        textAlign: TextAlign.center,
      ),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void getCardDeck() {
    for (int i = 0; i < length; i++) {
      cards.add(makeCard(i));
    }
  }

  Card makeCard(int index) {
    return Card(
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: FittedBox(
          child: FlipCard(
            key: Key(index.toString()),
            front: SizedBox(
                width: 400,
                height: 600,
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Center(
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                              flashcards[index]["front"]
                                  .replaceAllMapped(
                                    RegExp(r'(?<!\s)-'),
                                    (match) => '\u2011',
                                  )
                                  .replaceAll('-', '\n-'),
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.black),
                              textAlign: TextAlign.center))),
                )),
            back: SizedBox(
                width: 400,
                height: 600,
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Center(
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  flashcards[index]["back"]
                                      .replaceAllMapped(
                                        RegExp(r'(?<!\s)-'),
                                        (match) => '\u2011',
                                      )
                                      .replaceAll('-', '\n-'),
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 80),
                            ],
                          ))),
                )),
          ),
        ),
      ),
    );
  }
}
