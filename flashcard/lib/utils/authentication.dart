import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; //IsWeb;

class Authentication {
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    // User? user = FirebaseAuth.instance.currentUser;

    // if (user != null) {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(
    //       builder: (context) => UserInfoScreen(
    //         user: user,
    //       ),
    //     ),
    //   );
    // }

    return firebaseApp;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
        await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
          await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            scaffold.showSnackBar(
              Authentication.customSnackBar(
                content:
                'The account already exists with a different credential',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            scaffold.showSnackBar(
              Authentication.customSnackBar(
                content:
                'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          scaffold.showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred using Google Sign In. Try again.',
            ),
          );
        }
      }
    }

    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot =
    await collectionRef.where("userID", isEqualTo: user?.uid).get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    if (allData.isEmpty) {
      if (kDebugMode) {
        print("user doesnt exists google login");
      }
      collectionRef.add({
        "notify": false,
        "email": user?.email,
        "userID": user?.uid,
        "name": user?.displayName,
        "topicCount": [0, 0, 0, 0, 0, 0, 0, 0],
        "topicScore": [0, 0, 0, 0, 0, 0, 0, 0],
        "topicLastSeen": [
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now()
        ]
      });
    } else {
      Map<String, dynamic> userData = allData.first as Map<String, dynamic>;
      if (!userData.containsKey("topicScore")) {
        collectionRef.doc(querySnapshot.docs.first.id).update({
          "topicScore": [0, 0, 0, 0, 0, 0, 0, 0]
        });
      }
      if (!userData.containsKey("topicCount")) {
        collectionRef.doc(querySnapshot.docs.first.id).update({
          "topicCount": [0, 0, 0, 0, 0, 0, 0, 0]
        });
      }
      if (!userData.containsKey("topicLastSeen")) {
        collectionRef.doc(querySnapshot.docs.first.id).update({
          "topicLastSeen": [
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now()
          ]
        });
      }
    }

    return user;
  }

  static Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        if (kDebugMode) {
          print('No user found for that email.');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'No user found for that email. Please create an account.',
          ),
        );
      } else if (e.code == 'wrong-password') {
        if (kDebugMode) {
          print('Wrong password provided.');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'Wrong password provided.',
          ),
        );
      }
    }

    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot =
    await collectionRef.where("userID", isEqualTo: user?.uid).get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    if (allData.isEmpty) {
      if (kDebugMode) {
        print("user doesnt exists not google login");
      }
      collectionRef.add({
        "notify": false,
        "email" : user?.email,
        "userID": user?.uid,
        "name": user?.displayName,
        "topicCount": [0, 0, 0, 0, 0, 0, 0, 0],
        "topicScore": [0, 0, 0, 0, 0, 0, 0, 0],
        "topicLastSeen": [
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now(),
          Timestamp.now()
        ]
      });
    } else {
      Map<String, dynamic> userData = allData.first as Map<String, dynamic>;

      if (!userData.containsKey("topicScore")) {
        collectionRef.doc(querySnapshot.docs.first.id).update({
          "topicScore": [0, 0, 0, 0, 0, 0, 0, 0]
        });
      }
      if (!userData.containsKey("topicCount")) {
        collectionRef.doc(querySnapshot.docs.first.id).update({
          "topicCount": [0, 0, 0, 0, 0, 0, 0, 0]
        });
      }
      if (!userData.containsKey("topicLastSeen")) {
        collectionRef.doc(querySnapshot.docs.first.id).update({
          "topicLastSeen": [
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now()
          ]
        });
      }
    }
    return user;
  }

  static Future<User?> registerWithNameEmailPassword({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    User? user;
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('users');
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
      await user!.updateDisplayName(name);
      await user.reload();
      user = auth.currentUser;

      user = auth.currentUser;
      QuerySnapshot querySnapshot =
      await collectionRef.where("userID", isEqualTo: user?.uid).get();
      final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

      if (allData.isEmpty) {
        if (kDebugMode) {
          print("user doesnt exists not google login");
        }
        collectionRef.add({
          "notify": false,
          "email" : user?.email,
          "userID": user?.uid,
          "name": user?.displayName,
          "topicCount": [0, 0, 0, 0, 0, 0, 0, 0],
          "topicScore": [0, 0, 0, 0, 0, 0, 0, 0],
          "topicLastSeen": [
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now(),
            Timestamp.now()
          ]
        });
      } else {
        Map<String, dynamic> userData = querySnapshot.docs.first as Map<
            String,
            dynamic>;

        if (!userData.containsKey("topicScore")) {
          collectionRef.doc(querySnapshot.docs.first.id).update({
            "topicScore": [0, 0, 0, 0, 0, 0, 0, 0]
          });
        }
        if (!userData.containsKey("topicCount")) {
          collectionRef.doc(querySnapshot.docs.first.id).update({
            "topicCount": [0, 0, 0, 0, 0, 0, 0, 0]
          });
        }
        if (!userData.containsKey("topicLastSeen")) {
          collectionRef.doc(querySnapshot.docs.first.id).update({
            "topicLastSeen": [
              Timestamp.now(),
              Timestamp.now(),
              Timestamp.now(),
              Timestamp.now(),
              Timestamp.now(),
              Timestamp.now(),
              Timestamp.now(),
              Timestamp.now()
            ]
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (kDebugMode) {
          print('The password provided is too weak.');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'The password provided is too weak.',
          ),
        );

      } else if (e.code == 'email-already-in-use') {
        if (kDebugMode) {
          print('The account already exists for that email.');
        }
        scaffold.showSnackBar(
          Authentication.customSnackBar(
            content: 'The account already exists for that email.',
          ),
        );
      }

    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return user;
  }

  // same for google and email and pass logins
  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }
}