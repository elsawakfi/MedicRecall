import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/minimock_exam1.dart';
import 'package:flashcard_x/screens/minimock_exam2.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/screens/minimock1_rules_page.dart';


class MiniMockLanding extends StatefulWidget {
  const MiniMockLanding({super.key});
  
  @override
  State<MiniMockLanding> createState() => MiniMockLandingState();
}

class MiniMockLandingState extends State<MiniMockLanding> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

  @override
  void initState() {
    super.initState();
    getUser();
    getTestDay(); // Fetch the questions on initialisation (Needed as this is not to be called in the widget build)
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

  // Get the question data from the firestore
  Future<void> getTestDay() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection("users").where("userID", isEqualTo: user.uid).get();

    var userFromDb = querySnapshot.docs.first;
    Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
    //if the Test Day field isn't null and is in the database we update the UI with it. Otherwise it is displayed as being not set.
    if (data.containsKey("TestDay") || data["TestDay"] != null) {
      var testDay = DateTime.fromMicrosecondsSinceEpoch(userFromDb["TestDay"]
          .microsecondsSinceEpoch); //firebase is weird. conversion from TimeStamp to DateTime object
      String? day = testDay.day.toString();
      String? month = testDay.month.toString();
      String? year = testDay.year.toString();
      final DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      int daysUntilTest = (testDay.difference(today).inHours/24).round();

      // testDayString = '$day-$month-$year';
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawMain(),
        appBar: AppBar(
          // backgroundColor: Colors.blue,
            elevation: 0,
            title:  Align(
              alignment: const Alignment(-1.0,0),
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
                    child: const Text('Mini-Mocks',
                    textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),

            centerTitle: false,
            leading: Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const Icon(
                    Icons.menu,
                  ),
                ))),
      body: Container(
        //color:Color.fromARGB(255, 33, 100, 159), 
        padding: const EdgeInsets.all(16.0), // Add some padding
        child: Center( // Center the column vertically and horizontally
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              SizedBox(
                height: 50,
                width: 1000, // Set a fixed width for the button
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MiniMock1Rules(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: const Icon(
                    Icons.lock_open_sharp,
                    size: 30,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Mini Mock 1',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 50,
                width: 1000, // Set a fixed width for the button
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MiniMockExam2(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: const Icon(
                    Icons.lock_clock_sharp,
                    size: 30,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Mini Mock 2',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
