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
    setState(() {
      loading = false;
    });
  }

  Future<void> getCard() async {
    await FirebaseFirestore.instance
        .collection('flashcards') // suppose you have a collection named "Users"
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
    //topic = TextEditingController();
    resource = TextEditingController();
    // subtopic = TextEditingController();

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
    //print(front.text + back.text + topic.text + resource.text);
    //flashcards.add({"front":front.text, "back":back.text, "resource":resource.text, "topic":topic.text});
    flashcards.doc(cardID).update({
      "front": front.text ,
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

  get key =>
      null; // no clue if this is the appropriate thing to do, just did so because it made it work

  @override
  Widget build(BuildContext context) {
    // navigatorKey:
    AddCard.navKey;
    return Scaffold(
        appBar: DesignMain.appBarMain("Add Flashcard", context),
    body: Visibility(
    visible: !loading,
    child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
    Padding(
    padding: const EdgeInsets.all(10),
    child: TextField(
    controller: front,
    decoration: const InputDecoration(
    border: OutlineInputBorder(),
    hintText: 'front of card',
    ))),
    Padding(
    padding: const EdgeInsets.all(10),
    child: TextField(
    controller: back,
    decoration: const InputDecoration(
    border: OutlineInputBorder(),
    hintText: 'back of card',
    ))),
    DropdownButton<String>(
    value: topic,
    icon: Icon(Icons.arrow_downward, color: Theme.of(context).iconTheme.color),
    elevation: 16,
      style: TextStyle(color: Theme.of(context).dropdownMenuTheme.textStyle?.color),
    underline: Container(
    height: 2,
    color: Theme.of(context).dropdownMenuTheme.inputDecorationTheme?.enabledBorder?.borderSide.color
    ),
    onChanged: (String? newValue) {
    setState(() {
    topic = newValue!;
    subtopics = subtopicsMap[topic]!;
    subtopic = "";
    if (subtopics.isNotEmpty) {
    subtopic = subtopics[0];
    }
    });
    },
    items: topics.map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
    );
    }).toList(),
    ),
    DropdownButton<String>(
    value: subtopic,
    icon: Icon(Icons.arrow_downward, color: Theme.of(context).iconTheme.color),
    elevation: 16,
      style: TextStyle(color: Theme.of(context).dropdownMenuTheme.textStyle?.color),
    underline: Container(
    height: 2,
        color: Theme.of(context).dropdownMenuTheme.inputDecorationTheme?.enabledBorder?.borderSide.color
    ),
    onChanged: (String? newValue) {
    setState(() {
    subtopic = newValue!;
    });
    },
    items: subtopics.map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
    );
    }).toList(),
    ),
    GFButton(
    onPressed: uploadCard,
    text: "Submit",
    icon: const Icon(Icons.keyboard_arrow_right_sharp),
    shape: GFButtonShape.pills,
    color: Colors.green,
    textStyle: const TextStyle(fontSize: 18, color: Colors.white),
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
