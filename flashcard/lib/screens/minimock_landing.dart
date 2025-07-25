import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/minimock2_rules_page.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget2.dart';
import 'package:flashcard_x/screens/minimock1_rules_page.dart';
import 'package:flashcard_x/widgets/countdown_button.dart';


class MiniMockLanding extends StatefulWidget {
  const MiniMockLanding({super.key});
  
  @override
  State<MiniMockLanding> createState() => MiniMockLandingState();
}

class MiniMockLandingState extends State<MiniMockLanding> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference _userCollectionRef =
    FirebaseFirestore.instance.collection('users');
  late User user;
  DateTime? _examDate;
  DateTime? _firstStudyDate;
  bool? examSet;
  bool? halfway;

  @override
  void initState() {
    super.initState();
    initialise();
  }

  Future<void> initialise() async{
    await getUser();
    await getFirstStudyDay();
    await getTestDay();
    dateDifference();
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

  // Function from calendar_screen
  Future<void> getTestDay() async {
    QuerySnapshot querySnapshot =
      await _userCollectionRef.where("userID", isEqualTo: user.uid).get();

    var userFromDb = querySnapshot.docs.first;
    Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
    //if the Test Day field isn't null and is in the database we update the UI with it. Otherwise it is displayed as being not set.
    if (data.containsKey("TestDay") || data["TestDay"] != null) {
      _examDate = DateTime.fromMicrosecondsSinceEpoch(userFromDb["TestDay"]
          .microsecondsSinceEpoch); //firebase is weird. conversion from TimeStamp to DateTime object
      setState(() {
        examSet = true;
      });
    }else{
      setState(() {
        examSet = false;
      });
    }
  }

  Future<void> getFirstStudyDay() async {
    QuerySnapshot u = await _userCollectionRef.where("userID", isEqualTo: user.uid).get();
    var userFromDb = u.docs.first;
    Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
    // If the Test Day field isn't null and is in the database we update the UI with it. Otherwise it is displayed as being not set.
    if (data.containsKey("firstStudyDay") && data["firstStudyDay"] != null) {
      // firstDayBool = false;
      _firstStudyDate = (data["firstStudyDay"] as Timestamp).toDate();
    }

    setState(() {});
    }

  void dateDifference(){
    if(_examDate != null && _firstStudyDate != null){
      final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      Duration? difference = _examDate?.difference(_firstStudyDate!);
      DateTime? halfwayDate = _firstStudyDate?.add(Duration(seconds: difference!.inSeconds ~/ 2));
      halfwayDate = DateTime(halfwayDate!.year, halfwayDate.month, halfwayDate.day); // Normalise
      setState(() {
        // If statement checks for if the current date is greater than or equal to the halfway date
        if (!today.isBefore(halfwayDate!)) {
          halfway = true;
        } else {
          halfway = false;
        }
      });
    } else {
      halfway = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawMain2(),
      appBar: CustomAppBar(title: "Mini-Mocks"),
      body: examSet == null || halfway == null
          ? Center(child: CircularProgressIndicator()) // If data is still being fetched, show loading circle
          : Container(
        //color:Color.fromARGB(255, 33, 100, 159),
        padding: const EdgeInsets.all(16.0), // Add some padding
        child: Center( // Center the column vertically and horizontally
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(
                height: 55,
                width: 960, // Set a fixed width for the button
                child: ElevatedButton.icon(
                  onPressed: examSet! ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MiniMock1Rules(),
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
                    examSet! ? Icons.lock_open_sharp: Icons.lock_clock_sharp,
                    size: 30,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Mini-Mock 1',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 55,
                width: 960, // Set a fixed width for the button
                child: ElevatedButton.icon(
                  onPressed: halfway! ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MiniMock2Rules(),
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
                    halfway! ? Icons.lock_open_sharp: Icons.lock_clock_sharp,
                    size: 30,
                    color: Colors.black,
                  ),
                  label: Text(
                    'Mini-Mock 2',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color.fromARGB(255, 235, 230, 239),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: const Offset(0, 6), // changes position of shadow
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: (){
                        _helpPopup(context);
                      },
                      icon: Icon(Icons.question_mark, color:  Color.fromARGB(255, 98, 86, 139),),
                    )
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

// HELP BUTTON
void _helpPopup(BuildContext context){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          backgroundColor: const Color(0xFFE6EDF2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          title: Center(
              child:Text(
                'Mini-Mock Help Menu',
                style: const TextStyle(
                  color: Color.fromRGBO(21, 58, 103, 1),
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                ),
              )
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'To use the mini-mocks please first set an exam date using the \'Set Your Exam Date\' button.\nThe first mini-mock is unlocked immediately whilst the second one is unlocked halfway\nthrough your revision schedule, as seen on the calendar.\nTo start a mini-mock please click one of the unlocked options.',
                style: TextStyle(color: Color.fromRGBO(21, 58, 103, 1), fontSize: 16),
                softWrap: true,
              )
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                  },
                  child: const Text('Close'),
                ),
              ],
            )
          ]
      );
    },
  );
}
