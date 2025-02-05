import 'dart:core';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/calendar_screen.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/study_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:flashcard_x/screens/faq.dart';
import 'package:flashcard_x/screens/flashcard_editor_screen.dart';
import 'package:flashcard_x/screens/button_screen.dart';
import 'package:flashcard_x/screens/minimock_landing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'feedback_screen.dart';
import 'mark_scheme.dart';
import 'package:flashcard_x/screens/settings_screen.dart' as setting;
// import 'package:flashcard_x/screens/exam_guide_screen.dart';
// import 'package:flashcard_x/screens/resources.dart';





/* TO DO
Build the new landing page that comes after logging in and before the main dashboard.

Do i need to pass the user's name over?


*/
class Landing extends StatefulWidget {
  static String id = 'landing';

  const Landing({super.key});

  @override
  State<StatefulWidget> createState() => LandingState();
}

class LandingState extends State<Landing> {
  bool testDayBool_ = true;
  DateTime? hasDate;
  DateTime? _examDate;
  DateTime? _firstStudyDate;
  int buildCount = 0;
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String testDayString = "Test day not set";
  User? user;

  @override
  void initState() {
    super.initState();
    getUser();
    getFirstStudyDay();
    setState(() {});
  }


  Future<void> _setFirstStudyDay() async {
    QuerySnapshot u = await _userCollectionRef.where("userID", isEqualTo: user?.uid).get();
    var id = u.docs.last.id;
    
    // Save the first study day only once when the revision plan starts
    await _userCollectionRef.doc(id).update({
      "firstStudyDay": DateTime.now(), // Save the current date as first study day
    });

    

    // Optionally, retrieve the first study day
    await getFirstStudyDay();
  }

  Future<void> shouldShowDialog() async{
      await getTestDay();
      if (mounted && testDayBool_ && _examDate == null){
         showDialog(context: context,
         builder: (BuildContext context){
          return _buildAlertDialog(
          title: 'Do you want to start your revision plan today?',
          content: const SizedBox(), // Empty content for this dialog
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                 _setFirstStudyDay();
                _showExamDateDialog(context); // Call to show exam date dialog
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );setState(() {}); } else {}
  
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
  Future<void> checkTestDay() async {
    QuerySnapshot querySnapshot =
        await _userCollectionRef.where("userID", isEqualTo: user?.uid).get();

    var userFromDb = querySnapshot.docs.first;
    Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
    if ((data.containsKey("TestDay")||data["TestDay"] != null)) {
      //only interested in whether the db has a date or not for our boolean values that will be used in shouldShowDialog
      testDayBool_ = false;
      hasDate = DateTime.now();
    } else {
      testDayBool_ = true;

    }
    setState(() {});
  }
  Future<void> getTestDay() async {
    if(user != null){
      final user = this.user;
      if (user != null){
        QuerySnapshot querySnapshot =
            await _userCollectionRef.where("userID", isEqualTo: user.uid).get();

        var userFromDb = querySnapshot.docs.first;
        Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
        //if the Test Day field isn't null and is in the database we update the UI with it. Otherwise it is displayed as being not set.
        if ((data.containsKey("TestDay") || data["TestDay"] != null) &&
            (buildCount <= 2 || (_examDate != null && buildCount > 2))) {
          testDayBool_ = false;
          _examDate = DateTime.fromMicrosecondsSinceEpoch(userFromDb["TestDay"]
              .microsecondsSinceEpoch); //firebase is weird. conversion from TimeStamp to DateTime object
          String? day = _examDate?.day.toString();
          String? month = _examDate?.month.toString();
          String? year = _examDate?.year.toString();
          testDayString = '$day-$month-$year';
        } else {
          testDayBool_ = true;
        }
        setState(() {});
      }
    }
  }

  Future<void> getFirstStudyDay() async {
    if (user != null) {
      QuerySnapshot u = await _userCollectionRef.where("userID", isEqualTo: user?.uid).get();

      var userFromDb = u.docs.first;
      Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
      // If the Test Day field isn't null and is in the database we update the UI with it. Otherwise it is displayed as being not set.
      if (data.containsKey("firstStudyDay") && data["firstStudyDay"] != null) {
        // firstDayBool = false;
        _firstStudyDate = (data["firstStudyDay"] as Timestamp).toDate();
      }

      setState(() {});
    } 
  }


  @override
  Widget build(BuildContext context) {
    buildCount ++;
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
                                    builder: (context) => const MiniMockLanding(),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Icon(
                                      Icons.assignment_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Mini-mock',
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
          floatingActionButton: const CustomFloatingButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          
    ) ; 
  }


  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    //waits for build function to complete and then calls back to call the condition checking function 
    WidgetsBinding.instance.addPostFrameCallback((_){
       shouldShowDialog();
    });
  
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
 
 void _showExamDateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialog(
          title: 'What is your exam date?',
          content: Column(
            mainAxisSize: MainAxisSize.min,

            //if statement to check if firebase already has exam date in database
            children: [
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _examDate = picked;
                      updateTestDay(picked); // Update parent state
                      testDayBool_ = false;
                    });
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      _showRepetitionDialog(context);
                    }
                  }
        
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(21, 58, 103, 1),
                ),
                child: const Text('Pick Date'),
              ),
              const SizedBox(height: 10),
              Text(
                hasDate != null
                    ? 'Selected Date: ${DateFormat('MMM d, yyyy').format(_examDate!)}'
                    : 'No Date Selected',
                style: TextStyle(
                  color: _examDate != null
                      ? Colors.black
                      : const Color.fromRGBO(21, 58, 103, 1),
                ),
              ),
            ],
          ),
          actions: [],
        );
      },
    );
  }

 // Show dialog to ask for number of repetitions
  void _showRepetitionDialog(BuildContext context) {
    final List<int> repetitionOptions = [2, 3, 4, 5, 6];
    int? selectedRepetition;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFE6EDF2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How many repetitions of the official past paper would you like to schedule?',
                    style: const TextStyle(
                      color: Color.fromRGBO(21, 58, 103, 1),
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8), // Add spacing between lines
                  Text(
                    'We recommend at least 3 repetitions.',
                    style: const TextStyle(
                      color: Color.fromRGBO(21, 58, 103, 1),
                      fontSize: 16, // Slightly smaller font size
                      fontWeight: FontWeight.w400, // Regular font weight
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...repetitionOptions.map((int value) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: RadioListTile<int>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          tileColor: const Color.fromRGBO(21, 58, 103, 1),
                          title: Text(
                            '$value',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          value: value,
                          groupValue: selectedRepetition,
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedRepetition = newValue;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showExamDateDialog(context);
                      },
                      child: const Text('Previous'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (selectedRepetition != null) {
                          // Save selectedRepetition to the database
                          // code taken from below resources option dialog
                          QuerySnapshot u = await _userCollectionRef
                              .where("userID", isEqualTo: user?.uid)
                              .get();

                          var id = u.docs.last.id;
                          // updates the selectedRepetition field in the user's document
                          await _userCollectionRef.doc(id).update({
                          'selectedRepetition': selectedRepetition,
                          });

                          Navigator.of(context).pop();
                          _showOptionsDialog(
                              context); // Proceed to the next dialog
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter number of repetitions'),
                            ),
                          );
                        }
                      },
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper method
  Widget _buildAlertDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    return AlertDialog(
      backgroundColor: const Color(0xFFE6EDF2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color.fromRGBO(21, 58, 103, 1),
          fontSize: 21,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: content,
      actions: actions,
    );
  }

void _showOptionsDialog(BuildContext context) {
    final checkbox1 = ValueNotifier<bool>(false);
    final checkbox2 = ValueNotifier<bool>(false);
    final checkbox3 = ValueNotifier<bool>(false);
    final checkbox4 = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialog(
          title: 'What resources do you want to use?',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: checkbox1,
                    builder: (context, value, child) {
                      return Checkbox(
                        value: value,
                        onChanged: (value) {
                          checkbox1.value = value!;
                        },
                      );
                    },
                  ),
                  Text(
                    'Official paper',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: checkbox2,
                    builder: (context, value, child) {
                      return Checkbox(
                        value: value,
                        onChanged: (value) {
                          checkbox2.value = value!;
                        },
                      );
                    },
                  ),
                  Text(
                    'Full-sized mock exam',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: checkbox3,
                    builder: (context, value, child) {
                      return Checkbox(
                        value: value,
                        onChanged: (value) {
                          checkbox3.value = value!;
                        },
                      );
                    },
                  ),
                  Text(
                    'Mini-mocks',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: checkbox4,
                    builder: (context, value, child) {
                      return Checkbox(
                        value: value,
                        onChanged: (value) {
                          checkbox4.value = value!;
                        },
                      );
                    },
                  ),
                  Text(
                    'Flashcards',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showRepetitionDialog(context);
                      },
                      child: const Text('Previous'),
                    ),
            TextButton(
              onPressed: () async {
                if (checkbox1.value ||
                    checkbox2.value ||
                    checkbox3.value ||
                    checkbox4.value) {
                  List<String> selectedResources = [];
                  if (checkbox1.value) selectedResources.add('Official paper');
                  if (checkbox2.value) selectedResources.add('Full-sized mock exam');
                  if (checkbox3.value) selectedResources.add('Mini-mocks');
                  if (checkbox4.value) selectedResources.add('Flashcards');

                  QuerySnapshot u =
                  await _userCollectionRef.where("userID", isEqualTo: user?.uid).get();

                  // Update the Firestore document with the selected resources
                  var id = u.docs.last.id;
                  _userCollectionRef.doc(id).update({
                    'selectedResources': selectedResources,
                  });
                 

                  // Start the study session with the selected resources
                  StudySessionManager().startStudySession(selectedResources);

                  if(context.mounted){
                    Navigator.of(context).pop();
                  }
                  // Add your action here after options are submitted
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select at least one resource'),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
    
  }

   Future<void> updateTestDay(DateTime date) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot u =
        await _userCollectionRef.where("userID", isEqualTo: user?.uid).get();

    /*  FIRST update on database */
    var id = u.docs.last.id; //id being where the user's id details
    var userFromDb = u.docs.first;
    Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;

    users.doc(id).update({
      "TestDay": _examDate,
      "firstStudyDay": data.containsKey("firstStudyDay") && data["firstStudyDay"] != null
        ? data["firstStudyDay"] // Keep existing firstStudyDay if it exists
        : DateTime.now(), // Otherwise, set it to now
      });
      // update field testday to what is passed as param
    await getTestDay();
    setState(() {});
  
  }
 }
 