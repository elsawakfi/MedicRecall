import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/widgets/design_main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class AddCard extends StatefulWidget {
  static final navKey = GlobalKey<NavigatorState>();

  final String cardID;
  final bool editCard;

  const AddCard({Key? navKey, required this.cardID, required this.editCard})
      : super(key: navKey);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _AddCardState(cardID, editCard);
}

class _AddCardState extends State<AddCard> {
  late User user;

  late TextEditingController front;
  late TextEditingController back;
  String topic = "";
  late TextEditingController resource;
  String subtopic = "";

  final FirebaseAuth auth = FirebaseAuth.instance;
  List<String> topics = [];
  List<String> subtopics = [];
  Map<String, List<String>> subtopicsMap = {};

  bool loading = true;
  CollectionReference flashcards =
      FirebaseFirestore.instance.collection('flashcards');

  String cardID;
  bool editCard;

  _AddCardState(this.cardID, this.editCard);

  Future<void> getUser() async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth.authStateChanges().first;
      if (tmp == null) {
        nav.push(
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
        );
      } else {
        user = tmp;
      }
    } else {
      user = auth.currentUser!;
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> getCard() async {
    await FirebaseFirestore.instance
        .collection('flashcards')
        .doc(cardID)
        .get()
        .then((value) {
      front.text = value["front"];
      back.text = value["back"];
      resource.text = value["resource"];
      topic = value["topic"];
      subtopic = value["subtopic"];
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getTopics();
    front = TextEditingController();
    back = TextEditingController();
    resource = TextEditingController();
    if (editCard) {
      getCard();
    }
  }

  Future<void> getTopics() async {
    CollectionReference topicRef =
        FirebaseFirestore.instance.collection("topics");

    QuerySnapshot topicSnapshot = await topicRef.get();
    for (var doc in topicSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      topics.add(data["topic"]);
      List<String> tmp = [];
      if (data["subtopics"] != null) {
        for (var topic in data["subtopics"]) {
          tmp.add(topic.toString());
        }
      }
      subtopicsMap[data["topic"]] = tmp;
    }

    topic = topics[0];
    subtopics = subtopicsMap[topic]!;
    if (subtopics.isNotEmpty) {
      subtopic = subtopics[0];
    }
    if (kDebugMode) {
      print(topics);
    }
    setState(() {});
  }

  void editCardDB() {
    flashcards.doc(cardID).update({
      "front": front.text,
      "back": back.text,
      "resource": resource.text,
      "topic": topic,
      "subtopic": subtopic
    });
  }

  void addCardDB() {
    flashcards.add({
      "front": front.text,
      "back": back.text,
      "resource": resource.text,
      "topic": topic,
      "subtopic": subtopic,
      "owner": user.uid
    });
  }

  void uploadCard() {
    if (editCard) {
      editCardDB();
    } else {
      addCardDB();
    }
    homepage();
  }

  get key => null;

  @override
  Widget build(BuildContext context) {
    AddCard.navKey;
    return Scaffold(
      appBar: DesignMain.appBarMain("Add Flashcard", context),
      body: Visibility(
        visible: !loading,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  child: SizedBox(
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: front,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Questions',
                          hintStyle: TextStyle(fontSize: 20),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  child: SizedBox(
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: back,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Answers',
                          hintStyle: TextStyle(fontSize: 20),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: topic,
                dropdownColor: Colors.white,
                 icon: const Icon(Icons.arrow_downward, color: Colors.black),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                underline: Container(height: 0),
                onChanged: (String? newValue) {
                  setState(() {
                    topic = newValue!;
                    subtopics = subtopicsMap[topic]!;
                    subtopic =
                        subtopics.isNotEmpty ? subtopics[0] : '';
                  });
                },
                items: topics
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
              ),
            ),
          
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: subtopic,
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_downward, color: Colors.black),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                underline: Container(height: 0),
                onChanged: (String? newValue) {
                  setState(() {
                    subtopic = newValue!;
                  });
                },
                items: subtopics
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void homepage() {
    Navigator.pop(context);
  }
}
