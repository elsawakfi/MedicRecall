import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/drawer_widget.dart';
import 'add_flashcard_screen.dart';

class FlashcardEditor extends StatefulWidget {
  const FlashcardEditor({Key? key}) : super(key: key);

  @override
  State<FlashcardEditor> createState() => FlashcardEditorState();
}

class FlashcardEditorState extends State<FlashcardEditor> {
  CollectionReference flashcards =
      FirebaseFirestore.instance.collection('flashcards');

  late User user;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool loading = true;

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
                  child: const Text('Create New Flashcards',
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
            ),
            // child: const Icon(
            //   Icons.menu,
            // ),
          ),
        ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 130,
                      margin: const EdgeInsets.only(
                        bottom: 10.0,
                        left: 30.0,
                        right: 30.0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Center(
                        child: SingleChildScrollView(
                          child: Center(
                            child: Text(
                              "Use the green button to create your own flashcards and have them seamlessly merge with our existing database.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 500,
                      height: MediaQuery.of(context).size.height,
                      child: Visibility(
                        visible: !loading,
                        child: StreamBuilder<dynamic>(
                          stream: flashcards
                              .where("owner", isEqualTo: user.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Something went wrong');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("Loading");
                            }

                            return ListTileTheme(
                              contentPadding: const EdgeInsets.all(15),
                              iconColor: Colors.red,
                              textColor: Colors.black54,
                              tileColor: Colors.yellow[100],
                              style: ListTileStyle.list,
                              dense: true,
                              child: ListView.builder(
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) => Card(
                                  margin: const EdgeInsets.all(10),
                                  child: ListTile(
                                    title: Text(
                                      snapshot.data.docs[index]['front'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                    subtitle: Text(
                                      snapshot.data.docs[index]['back'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MaterialButton(
                                          shape: const CircleBorder(),
                                          color: Colors.red,
                                          onPressed: () async {
                                            deleteCard(snapshot.data.docs[index].id);
                                          },
                                          child: const Icon(
                                            Icons.delete_forever,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                        MaterialButton(
                                          shape: const CircleBorder(),
                                          color: Colors.blue,
                                          onPressed: () {
                                            editCard(
                                              context,
                                              snapshot.data.docs[index].id,
                                            );
                                          },
                                          child: const Icon(
                                            Icons.edit,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                addCard(context);
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16), // Add some spacing between FAB and bottom
          ],
        ),
      ),
    );
  }

  Future<void> deleteCard(String cardID) {
    return flashcards.doc(cardID).delete();
  }

  Future<void> getUser() async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth    ///we check to see if the user is already logged in.
          .authStateChanges() ///if the authState has changed, meaning that a user has been found to already be logged in,
          .first;             ///set tmp to be the user.
      if (tmp == null) {
        nav.push(               ///if the user has not yet logged in,
            MaterialPageRoute(  ///send them to the sign in screen
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

  void addCard(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddCard(cardID: "aaa", editCard: false),
        ));
  }

  void editCard(BuildContext context, String cardID) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCard(cardID: cardID, editCard: true),
        ));
  }
}
