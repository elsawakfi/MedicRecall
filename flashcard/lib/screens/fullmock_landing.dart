import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/countdown_button.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flashcard_x/widgets/countdown_button.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'fullmock_rules_page.dart';

class FullMockLanding extends StatefulWidget {
  const FullMockLanding({super.key});
  
  @override
  State<FullMockLanding> createState() => FullMockLandingState();
}

class FullMockLandingState extends State<FullMockLanding> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  int? daysUntilTest;

  @override
  void initState() {
    super.initState();
    getUser();
    getTestDay();
  }

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
  }

  // Function from calendar_screen
  Future<void> getTestDay() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection("users").where("userID", isEqualTo: user.uid).get();

    var userFromDb = querySnapshot.docs.first;
    Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
    //if the Test Day field isn't null and is in the database we update the UI with it. Otherwise it is displayed as being not set.
    if (data.containsKey("TestDay") || data["TestDay"] != null) {
      var testDay = DateTime.fromMicrosecondsSinceEpoch(userFromDb["TestDay"]
          .microsecondsSinceEpoch); //firebase is weird. conversion from TimeStamp to DateTime object
      final DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      setState(() {
        daysUntilTest = (testDay.difference(today).inHours/24).round();
      });
    } else {
      setState(() {
        daysUntilTest = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawMain(),
      appBar: CustomAppBar(title: "Full-Sized Mock Exam"),
      body: daysUntilTest == null
          ? Center(child: CircularProgressIndicator()) // If data is still being fetched, show loading circle
          : Container(
        padding: const EdgeInsets.all(16.0), // Add some padding
        child: Center( // Center the column vertically and horizontally
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              SizedBox(
                height: 55,
                width: 960, // Set a fixed width for the button
                child: ElevatedButton.icon(
                  onPressed: daysUntilTest! > -1
                    ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FullMockRules()
                      ),
                    );
                  }
                  : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: Icon(
                    daysUntilTest! > -1 ? Icons.lock_open_sharp: Icons.lock_clock_sharp,
                    size: 30,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Full Mock',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const CustomFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}