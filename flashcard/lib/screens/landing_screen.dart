import 'dart:core';
import 'package:flashcard_x/screens/landing_screen_new.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/calendar_screen.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/faq.dart';
import 'package:flashcard_x/screens/flashcard_editor_screen.dart';
import 'package:flashcard_x/widgets/countdown_button.dart';
import 'package:flashcard_x/screens/minimock_landing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'feedback_screen.dart';
import 'fullmock_landing.dart';
import 'landing_service.dart';
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
  bool onLanding = true;
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
    landingService.onLanding = true;
    if (mounted) setState(() {});
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

  Future<void> getUser() async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth
          .authStateChanges()
          .first;
      if (tmp == null) {
        nav.push(MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ));
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
    if ((data.containsKey("TestDay") || data["TestDay"] != null)) {
      //only interested in whether the db has a date or not for our boolean values that will be used in shouldShowDialog
      testDayBool_ = false;
      hasDate = DateTime.now();
    } else {
      testDayBool_ = true;
    }
    if (mounted) setState(() {});
  }

  Future<void> getTestDay() async {
    if (user != null) {
      final user = this.user;
      if (user != null) {
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
        if (mounted) setState(() {});
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

      if (mounted) setState(() {});
    }
  }

  // Helper method for creating styled buttons
  Widget _buildStyledButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    String? key,
    bool centerIcon = false,
  }) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    // Define breakpoint for mobile (you can adjust this value)
    const mobileBreakpoint = 600.0;
    // Determine if we're on mobile
    final isMobile = screenWidth < mobileBreakpoint;

    // Adjust text size and padding based on screen size
    final textSize = isMobile ? 24.0 : 34.0;
    final horizontalPadding = isMobile ? 20.0 : 10.0;
    final verticalPadding = isMobile ? 16.0 : 10.0;
    final buttonSpacing = isMobile ? 24.0 : 40.0; // New spacing variable

    return Column(
      children: [
        Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400,
              minWidth: isMobile ? 300 : 400,
            ),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 0),
            child: TextButton(
              key: key != null ? ValueKey(key) : null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                foregroundColor: Colors.blueGrey,
                backgroundColor: Colors.blueGrey,
                side: const BorderSide(color: Colors.blueGrey, width: 2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
              ),
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: centerIcon
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (centerIcon)
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.blueGrey,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(isMobile ? 1.5 : 2.0),
                      child: Icon(icon, color: Colors.white, size: 24),
                    )
                  else
                    Icon(icon, color: Colors.white, size: 24),
                  SizedBox(width: isMobile ? 8 : 10),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: textSize,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: buttonSpacing),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return Scaffold(
      key: const ValueKey('Welcome bar'),
      appBar: AppBar(
        elevation: 0,
        title: Align(
          alignment: const Alignment(0.00, 0),
          child: Stack(
            children: [
              Positioned(
                top: 1.3,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).appBarTheme.iconTheme?.color ??
                        Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/newlogo.png',
                    fit: BoxFit.cover,
                    height: 38,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 35),
                padding: const EdgeInsets.all(8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isMobile = screenWidth < 600;

                    return Text(
                      isMobile
                          ? 'MedicRecall'
                          : 'MedicRecall: Evidence-Based revision for the MSRA',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
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
                  height: 150,
                  margin: const EdgeInsets.only(
                      bottom: 10.0, left: 30.0, right: 30.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isMobile = screenWidth < 600;

                      return Center(
                        child: SingleChildScrollView(
                          child: Center(
                            child: Text(
                              "Welcome to our platform! \n Streamline your revision and achieve excellent results \n in the Multi-Specialty Recruitment Assessment (MSRA).",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 18 : 28,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                _buildStyledButton(
                  text: 'New Landing Page',
                  icon: Icons.note_alt_outlined,
                  onPressed: () {
                    landingService.onLanding = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewLanding(),
                      ),
                    );
                  },
                  key: 'Mark Scheme',
                ),
                _buildStyledButton(
                  text: 'Flashcard Tutor',
                  icon: Icons.collections_bookmark_outlined,
                  onPressed: () => triggerSignIn('HomePage'),
                  key: 'Flashcards',
                ),
                _buildStyledButton(
                  text: 'Unofficial Mark Scheme',
                  icon: Icons.note_alt_outlined,
                  onPressed: () {
                    landingService.onLanding = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UMS(),
                      ),
                    );
                  },
                  key: 'Mark Scheme',
                ),
                _buildStyledButton(
                  text: 'Create New Flashcards',
                  icon: Icons.add_box_outlined,
                  onPressed: () => triggerSignIn('FlashcardEditor'),
                  key: 'Create New Flashcards',
                ),
                _buildStyledButton(
                  text: 'Revision Calendar',
                  icon: Icons.calendar_today_outlined,
                  onPressed: () => triggerSignIn('Calendar'),
                  key: 'Revision Calendar',
                ),
                _buildStyledButton(
                  text: 'Mini-Mocks',
                  icon: Icons.assignment_outlined,
                  onPressed: () {
                    landingService.onLanding = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MiniMockLanding(),
                      ),
                    );
                  },
                  key: 'Mini-Mocks',
                ),
                _buildStyledButton(
                  text: 'Full-Sized Mock',
                  icon: Icons.assignment_outlined,
                  onPressed: () {
                    landingService.onLanding = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FullMockLanding(),
                      ),
                    );
                  },
                  key: 'Full-Sized Mock',
                ),
                _buildStyledButton(
                  text: 'Feedback',
                  icon: Icons.feedback_outlined,
                  onPressed: () {
                    landingService.onLanding = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedbackScreen(),
                      ),
                    );
                  },
                  key: 'Feedback',
                ),
                _buildStyledButton(
                  text: 'Settings',
                  icon: Icons.settings,
                  onPressed: () {
                    landingService.onLanding = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const setting.Settings(),
                      ),
                    );
                  },
                  key: 'Settings',
                ),
                _buildStyledButton(
                  text: 'FAQ',
                  icon: Icons.question_answer_outlined,
                  onPressed: () {
                    landingService.onLanding = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FAQScreen(),
                      ),
                    );
                  },
                  key: 'FAQ',
                ),
              ],
            ),
          )),
        ],
      )),
      floatingActionButton: const CustomFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  Future<void> triggerSignIn(String screen) async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth.authStateChanges().first;

      if (tmp == null) {
        //whenever nav.push is called, the onLanding variable needs to be set to false to make
        landingService.onLanding = false;
        nav.push(MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ));
      } else {
        user = tmp;
      }
    } else {
      if (screen == 'HomePage') {
        landingService.onLanding = false;
        nav.push(MaterialPageRoute(
          builder: (context) => const HomePage(title: 'Home'),
        ));
      } else if (screen == 'FlashcardEditor') {
        landingService.onLanding = false;
        nav.push(MaterialPageRoute(
          builder: (context) => const FlashcardEditor(),
        ));
      } else if (screen == 'Calendar') {
        landingService.onLanding = false;
        nav.push(MaterialPageRoute(
          builder: (context) => const Calendar(),
        ));
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
      "firstStudyDay": data.containsKey("firstStudyDay") &&
              data["firstStudyDay"] != null
          ? data["firstStudyDay"] // Keep existing firstStudyDay if it exists
          : DateTime.now(), // Otherwise, set it to now
    });
    // update field testday to what is passed as param
    await getTestDay();
    if (mounted) setState(() {});
  }
}
