import 'dart:core';

import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/calendar_screen.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/faq.dart';
import 'package:flashcard_x/screens/flashcard_editor_screen.dart';
// import 'package:flashcard_x/screens/exam_guide_screen.dart';
// import 'package:flashcard_x/screens/resources.dart';
import 'package:flashcard_x/screens/settings_screen.dart' as setting;
import 'package:flutter/material.dart';

import 'feedback_screen.dart';
import 'mark_scheme.dart';

/* TO DO
Build the new landing page that comes after logging in and before the main dashboard.

Do i need to pass the user's name over?


*/
class Landing extends StatefulWidget {
  static String id = 'landing';

  const Landing({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LandingState();
}

class LandingState extends State<Landing> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('Welcome bar'),
      appBar: AppBar(
        // backgroundColor: Colors.blue,
        elevation: 0,
        title: Align(
          alignment: const Alignment(0.00,0),
          child: Stack(
            children: [
              Positioned(
                top: 1.3,

                  child: Image.asset(
                    'assets/newlogo.png',
                    fit: BoxFit.cover,
                    height: 38,
                  ),

              ),
              Container(
                margin: const EdgeInsets.only(left: 35),
                padding: const EdgeInsets.all(8.0),
                child: const Text('MedicRecall: Evidence-Based revision for the MSRA',
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                          Container(
                              width: double.infinity,
                              height: 130,
                              margin: const EdgeInsets.only(
                                  bottom: 10.0, left: 30.0, right: 30.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: const Center(
                                  child: SingleChildScrollView(
                                    // allow for scrolling if its a long question
                                    child: Center(
                                        child: Text(
                                            "Welcome to our platform! \n Streamline your revision and achieve excellent results \n in the Multi-Specialty Recruitment Assessment (MSRA).",
                                            //get the question from the map
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                            ))),
                                  ))),
                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  foregroundColor: Colors.blueGrey,
                                  backgroundColor: Colors.blueGrey,
                                  side: const BorderSide(color: Colors.blueGrey, width: 2),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                  ),
                                ),
                                onPressed: () => triggerSignIn('HomePage'),
                                key: const ValueKey('Flashcards'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.blueGrey,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2.0),
                                      child: const Icon(
                                        Icons.collections_bookmark_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Flashcard Tutor',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 34,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  foregroundColor: Colors.blueGrey,
                                  backgroundColor: Colors.blueGrey,
                                  side: const BorderSide(color: Colors.blueGrey, width: 2),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const UMS(),
                                    ),
                                  );
                                },
                                key: const ValueKey('Mark Scheme'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Icon(
                                      Icons.note_alt_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Unofficial Mark Scheme',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 34,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  foregroundColor: Colors.blueGrey,
                                  backgroundColor: Colors.blueGrey,
                                  side: const BorderSide(color: Colors.blueGrey, width: 2),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                  ),
                                ),
                                onPressed: () => triggerSignIn('FlashcardEditor'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Icon(
                                      Icons.add_box_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Create New Flashcards',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 34,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  foregroundColor: Colors.blueGrey,
                                  backgroundColor: Colors.blueGrey,
                                  side: const BorderSide(color: Colors.blueGrey, width: 2),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                  ),
                                ),
                                onPressed: () => triggerSignIn('Calendar'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Revision Calendar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 34,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  foregroundColor: Colors.blueGrey,
                                  backgroundColor: Colors.blueGrey,
                                  side: const BorderSide(color: Colors.blueGrey, width: 2),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                  ),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FeedbackScreen(),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.blueGrey,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2.0),
                                      child: const Icon(
                                        Icons.feedback_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Feedback',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 34,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  foregroundColor: Colors.blueGrey,
                                  backgroundColor: Colors.blueGrey,
                                  side: const BorderSide(color: Colors.blueGrey, width: 2),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                  ),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const setting.Settings(),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Icon(
                                      Icons.settings,
                                      color: Colors.white,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Settings',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 34,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(width: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  foregroundColor: Colors.blueGrey,
                                  backgroundColor: Colors.blueGrey,
                                  side: const BorderSide(color: Colors.blueGrey, width: 2),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                  ),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FAQScreen(),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.blueGrey,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2.0),
                                      child: const Icon(
                                        Icons.live_help_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'FAQs',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 34,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ))),
            ],
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    getUser();
    setState(() {});
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

  Future<void> triggerSignIn(String screen) async{
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
      if (screen == 'HomePage'){
        nav.push(
            MaterialPageRoute(
              builder: (context) => const HomePage(title: 'Home'),
            )
        );
      }
      else if (screen == 'FlashcardEditor'){
        nav.push(
            MaterialPageRoute(
              builder: (context) => const FlashcardEditor(),
            )
        );
      }
      else if (screen == 'Calendar'){
        nav.push(
            MaterialPageRoute(
              builder: (context) => const Calendar(),
            )
        );
      }

      // user = auth.currentUser!;
      //     () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => const HomePage(
      //         title: 'Home',
      //       )),
      // );
    }
  }

}

