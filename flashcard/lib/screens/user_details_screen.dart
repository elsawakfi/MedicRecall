import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/utils/authentication.dart';
// import 'package:flashcard_x/widgets/design_main.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({Key? key}) : super(key: key);

  @override
  State<UserDetailsPage> createState() => UserDetailsPageState();
}

class UserDetailsPageState extends State<UserDetailsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  late String id;
  String? userName = "loading...";
  bool isEnabled = false;
  final TextEditingController _controller = TextEditingController(text: "user");

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  // final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawMain(),
        appBar: AppBar(
            // title: const Text("User Details"),
            title: Align(
              alignment: const Alignment(-0.06, 0),
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
                    child: const Text("User Details"),
                  ),
                ],
              ),
            ),
            // titleTextStyle: const TextStyle(
            //     fontSize: 30, fontWeight: FontWeight.bold),
            centerTitle: true,
            leading: Builder(
                builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(
                        Icons.menu,
                      ),
                    ))),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("name:"),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _controller,
                        enabled: isEnabled,
                      ),
                    ),
                    Visibility(
                        visible: !isEnabled,
                        child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                isEnabled = true;
                              });
                            })),
                    Visibility(
                        visible: isEnabled,
                        child: IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              setState(() {
                                isEnabled = false;
                                users
                                    .doc(id)
                                    .update({"name": _controller.text});
                              });
                            }))
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                makeButtons("Delete account")
              ],
            )
          ],
        ));
  }

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

    QuerySnapshot querySnapshot =
        await users.where("userID", isEqualTo: user.uid).get();
    if (querySnapshot.docs.last["name"] == null) {
      userName = 'user';
    } else {
      userName = querySnapshot.docs.last["name"];
    }
    id = querySnapshot.docs.last.id;
    _controller.text = userName!;
  }

  Future<void> deleteUserData() async {
    ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);

    QuerySnapshot querySnapshot =
        await users.where("userID", isEqualTo: user.uid).get();

    var userDocID = querySnapshot.docs.first.id;

    if (mounted) {
      showAlertDialog(context, "Delete");
    }
    DocumentReference userDocRef = users.doc(userDocID);

    //Deletes users document from firebase and their account from the Firebase authentication
    try {
      await userDocRef.delete();
      await user.delete();
    } catch (e) {
      scaffold.showSnackBar(
        Authentication.customSnackBar(
          content: 'Error deleting account. Please try again.',
        ),
      );
    }
  }

  Future<void> resetUserData() async {
    QuerySnapshot querySnapshot =
    await users.where("userID", isEqualTo: user.uid).get();

    var userDocID = querySnapshot.docs.first.id;

    CollectionReference flashcardsSeen = FirebaseFirestore.instance
        .collection("users/$userDocID/flashcardsSeen");

    QuerySnapshot flashcardsSeenSnapshot = await flashcardsSeen.get();

    for (var cardSeen in flashcardsSeenSnapshot.docs) {
      flashcardsSeen.doc(cardSeen.id).delete();
    }

    CollectionReference events =
    FirebaseFirestore.instance.collection("users/$userDocID/events");

    QuerySnapshot eventsSnapshot = await events.get();

    for (var event in eventsSnapshot.docs) {
      events.doc(event.id).delete();
    }
    if (mounted) {
      showAlertDialog(context, "Reset");
    }
  }

  Column makeButtons(String subtopic) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          height: 50.0,
          width: 300,
          child: ElevatedButton(
            key: const ValueKey('Delete Userdata'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: const BorderSide(color: Color.fromRGBO(0, 160, 227, 1))),
              padding: const EdgeInsets.all(10.0),
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromRGBO(0, 160, 227, 1),
            ),
            onPressed: deleteUserData,
            child: Text(subtopic, style: const TextStyle(fontSize: 15)),
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          margin: const EdgeInsets.all(10),
          height: 50.0,
          width: 300,
          child: ElevatedButton(
            key: const ValueKey('Reset Userdata'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: const BorderSide(color: Color.fromRGBO(0, 160, 227, 1))),
              padding: const EdgeInsets.all(10.0),
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromRGBO(0, 160, 227, 1),
            ),
            onPressed: resetUserData,
            child: const Text("Reset all user data", style: TextStyle(fontSize: 15)),
          ),
        )
      ],
    );
  }

  showAlertDialog(BuildContext context, String type) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        if (type == "Delete") {
          Authentication.signOut(context: context);
          Navigator.of(context).pushNamedAndRemoveUntil(
              SignInScreen.id, (Route<dynamic> route) =>
          false);
        } else {
          Navigator.pop(context);
        }
      }
    );

    AlertDialog alert;
    // set up the AlertDialog
    if (type == "Delete") {
      alert = AlertDialog(
        title: const Text("Important"),
        content: const Text("Account has been deleted"),
        actions: [
          okButton,
        ],
      );
    } else {
      alert = AlertDialog(
        title: const Text("Important"),
        content: const Text("User data has been reset"),
        actions: [
          okButton,
        ],
      );
    }

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
