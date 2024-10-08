import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';

import '../screens/calendar_screen.dart';

class DesignMain {
  static AppBar appBarMain(String title, BuildContext context) {
    return AppBar(
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
              child: Text(title),
            ),
          ],
        ),
      ),

      centerTitle: true,
      leading: GestureDetector(
        key: const ValueKey('HomePage'),
        onTap: () => Navigator.pop(context),

        child: const Icon(
           Icons.arrow_back, // add custom icons also
         ),
      ),
    );
  }
}

class RefreshDesignMain {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  final CollectionReference _userCollectionRef =
  FirebaseFirestore.instance.collection('users');

  //AppBar where the back button pops entire stack and goes back to flashcard page. Also, back button updates calendar revision events in database.
  AppBar appBarMain(String title, BuildContext context) {

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

    Future<void> updateCalendarEvents() async {
      getUser();
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

    void home() {
      updateCalendarEvents();
      Navigator.of(context).popUntil((route) => false);
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage(title: 'Home')));
    }

    return AppBar(
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
              child: Text(title),
            ),
          ],
        ),
      ),

      centerTitle: true,
      leading: GestureDetector(
        key: const ValueKey('HomePage'),
        onTap: () => home(),
        child: const Icon(
          Icons.arrow_back, // add custom icons also
        ),
      ),
    );
  }
}
