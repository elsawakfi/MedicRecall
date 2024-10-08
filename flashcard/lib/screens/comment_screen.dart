import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/widgets/design_main.dart';
import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  const CommentSection({Key? key, required this.cardID}) : super(key: key);
  final String cardID;

  @override
  // ignore: no_logic_in_create_state
  State<CommentSection> createState() => _CommentState(cardID);
}

class _CommentState extends State<CommentSection> {
  late CollectionReference flashcardCommentsRef;
  late User user;
  late TextEditingController commentText;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection("users");

  List<Map<String, dynamic>> users = [];

  bool loading = true;

  String cardID;

  _CommentState(this.cardID);

  Future<void> getUsers() async {
    for (var doc in (await usersRef.get()).docs) {
      users.add({"name": doc["name"], "userID": doc["userID"]});
    }
    setState(() {
      loading = false;
    });
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
  }

  String getUserName(String userID) {
    for (var oneUser in users) {
      if (oneUser["userID"] == userID) {
        return (oneUser["name"]);
      }
    }
    return "USER NOT FOUND";
  }

  Future<void> deleteComment(String dooID) async {
    await flashcardCommentsRef.doc(dooID).delete();
  }

  @override
  void initState() {
    getUsers();
    commentText = TextEditingController();
    user = FirebaseAuth.instance.currentUser!;
    flashcardCommentsRef = FirebaseFirestore.instance
        .collection("flashcards/$cardID/comments");
    super.initState();
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  Visibility canDelete(String docID, String userID) {
    bool isUser = user.uid == userID;

    return Visibility(
        visible: isUser,
        child: IconButton(
            onPressed: () {
              deleteComment(docID);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.black,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: DesignMain.appBarMain("Comments", context),
        body: Stack(
          children: [
            Center(
                child: Visibility(
              visible: loading,
              child: const CircularProgressIndicator(),
            )),
            Visibility(
              visible: !loading,
              child: StreamBuilder<dynamic>(
                  stream: flashcardCommentsRef
                      .orderBy("date", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
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
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getUserName(
                                      snapshot.data.docs[index]['userID']),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                                Row(
                                  children: [
                                    Text(formatDate((snapshot.data.docs[index]
                                            ['date'] as Timestamp)
                                        .toDate())),
                                    canDelete(snapshot.data.docs[index].id,
                                        snapshot.data.docs[index]['userID'])
                                  ],
                                )
                              ],
                            ),
                            subtitle: Text(
                              snapshot.data.docs[index]['comment'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 10,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
        bottomNavigationBar: Visibility(
          visible: !loading,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                      controller: commentText,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a comment',
                      )),
                ),
                IconButton(
                    onPressed: addComment, icon: const Icon(Icons.arrow_upward))
              ],
            ),
          ),
        ));
  }

  Future<void> addComment() async {
    flashcardCommentsRef.add({
      "userID": user.uid,
      "comment": commentText.text,
      "date": DateTime.now()
    });
    commentText.text = "";
  }
}
