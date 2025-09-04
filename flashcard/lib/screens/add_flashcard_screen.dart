import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
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

    // Initialize as empty to show hint text initially
    if (!editCard) {
      topic = "";
      subtopic = "";
      subtopics = [];
    } else {
      topic = topics[0];
      subtopics = subtopicsMap[topic]!;
      if (subtopics.isNotEmpty) {
        subtopic = subtopics[0];
      }
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
    // Validate that both category and sub-category are selected
    if (topic.isEmpty || subtopic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both Category and Sub-category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (editCard) {
      editCardDB();
    } else {
      addCardDB();
    }
    homepage();
  }

  get key => null;

 
  PreferredSizeWidget _buildCustomAppBarWithBack(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AppBar(
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Positioned(
                top: 4,
                child: Image.asset(
                  'assets/dashboard_assets/app_logo4.png',
                  fit: BoxFit.cover,
                  height: isSmallScreen ? 28 : 34,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: isSmallScreen ? 24 : 30),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Add Flashcard",
                  style: theme.appBarTheme.titleTextStyle?.copyWith(
                    fontSize: isSmallScreen ? 18 : 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      automaticallyImplyLeading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    AddCard.navKey;
    return Scaffold(
      appBar: _buildCustomAppBarWithBack(context),
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
                          hintText: 'Question',
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
                          hintText: 'Answer',
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
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              width: 240, // Increased by 20% (200 * 1.2 = 240)
              child: DropdownButton<String>(
                isExpanded: true,
                value: null, // Always null to show hint
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_downward, color: Colors.black),
                elevation: 16,
                style: const TextStyle(color: Colors.black, fontSize: 18),
                underline: Container(height: 0),
                hint: Center(
                  child: Text(
                    topic.isEmpty ? 'Category' : topic,
                    style: TextStyle(
                      color: topic.isEmpty ? Colors.grey : Colors.black,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    topic = newValue!;
                    subtopics = subtopicsMap[topic]!;
                    subtopic = ''; // Reset to show hint text
                  });
                },
                items: topics
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Center(
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: topic.isEmpty ? Colors.grey[100] : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              width: 240, // Increased by 20% (200 * 1.2 = 240)
              child: IgnorePointer(
                ignoring: topic.isEmpty,
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: null, // Always null to show hint
                  dropdownColor: Colors.white,
                  icon: Icon(Icons.arrow_downward, 
                           color: topic.isEmpty ? Colors.grey : Colors.black),
                  elevation: 16,
                  style: TextStyle(
                    color: topic.isEmpty ? Colors.grey : Colors.black,
                    fontSize: 18,
                  ),
                  underline: Container(height: 0),
                  hint: Center(
                    child: Text(
                      subtopic.isEmpty ? 'Sub-category' : subtopic,
                      style: TextStyle(
                        color: subtopic.isEmpty ? Colors.grey : Colors.black,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onChanged: topic.isEmpty ? null : (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        subtopic = newValue;
                      });
                    }
                  },
                  items: subtopics.isEmpty 
                      ? []
                      : subtopics
                          .map((value) => DropdownMenuItem<String>(
                                value: value,
                                child: Center(
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ))
                          .toList(),
                ),
              ),
            ),
        
        const SizedBox(height: 50), 
        Transform.scale(
            scale: 1.44, 
            child: GFButton(
              onPressed: uploadCard,
              text: "Create",
              icon: const Icon(Icons.keyboard_arrow_right_sharp),
              shape: GFButtonShape.pills,
              color: Colors.green,
              textStyle: TextStyle(
                fontSize: 18, 
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
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
