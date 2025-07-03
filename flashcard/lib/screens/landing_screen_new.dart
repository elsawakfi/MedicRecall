import 'dart:core';
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
import 'package:flutter/material.dart';


// VARIABLES THAT MUST BE CONNECTED TO THE DATABASE
// nextTopicForReview


class NewLanding extends StatefulWidget {
  static String id = 'landing_screen_new';
  const NewLanding({super.key});

  @override
  State<StatefulWidget> createState() => NewLandingState();
}

class NewLandingState extends State<NewLanding> {
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

  // NEW VARIABLES FROM MEDICRECALL1
  String? nextTopicForReview;

  @override
  void initState() {
    super.initState();
    getUser();
    getFirstStudyDay();
    landingService.onLanding = true;
    if (mounted) setState(() {});
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
      //title: "User Dashboard",
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DashboardBoxLeft(
                      title: 'Next Flashcard Deck for review:',
                      subtitle: nextTopicForReview != null
                          ? "$nextTopicForReview"
                          : "No topics scheduled.",
                      buttonText: 'Start Now',
                      onPressed: () => triggerSignIn('FlashcardEditor'),
                    ),
                  ),
                  SizedBox(width: 16),
                  SizedBox(width: 16),
                  Expanded(
                    child: DashboardBoxRight(
                      title: 'Next Mock Exam:',
                      subtitle: 'Official Paper 1',
                        onPressed1: () async {
                          landingService.onLanding = false;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FullMockLanding(),
                            ),
                          );
                        },
                        onPressed2: () async {
                          landingService.onLanding = false;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MiniMockLanding(),
                            ),
                          );
                        },
                    ),
                  ),
                ]
              ),
              SizedBox(height: 20),
              Row(children: [
                IconButton(
                  label: 'Study Schedule',
                  iconFilePath: 'assets/dashboard_assets/calendar.png',
                  onPressed: () => triggerSignIn('Calendar'),
                ),
                IconButton(
                  label: 'Create New Flashcards',
                  iconFilePath: 'assets/dashboard_assets/plus.png',
                  onPressed: () => triggerSignIn('FlashcardEditor'),
                ),
              ],)
            ],
          )
        )
      )    
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

class IconButton extends StatelessWidget {
  
  const IconButton({super.key, 
    required this.label,
    required this.onPressed,
    this.iconFilePath,
  });

  final String label;
  final Future<void> Function() onPressed;
  final String? iconFilePath;

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);
    //final themeProvider = Provider.of<ThemeProvider>(context);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            //backgroundColor: themeProvider.isDarkMode ? Colors.black : Color.fromRGBO(44, 44, 44, 1),
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 15),
              if (iconFilePath != null) ...[
                Image.asset(
                  width: 30,
                  iconFilePath!,
                ),
              ],
              Expanded(
                child: Text(
                label,
                textAlign: TextAlign.center,
                  style: textStyle1,
                ),
              ),
            ]
          ),
          )
        ),
      );
  }
}

class DashboardBoxLeft extends StatelessWidget {
  const DashboardBoxLeft({super.key, 
    required this.title,
    required this.buttonText,
    required this.onPressed,
    this.subtitle,
    this.height,
  });

  final String title;
  final String buttonText;
  final Future<void> Function() onPressed;
  final String? subtitle;
  final double? height;


  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            //color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              SizedBox(height: 4.0),
              Container(
                padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                child: Row(
                  children: [
                    IconButton(
                      label: 'Flashcard Tutor',
                      iconFilePath: 'assets/dashboard_assets/trending_up.png',
                      onPressed: onPressed,
                      // onPressed: () {
                      //   Navigator.push(
                      //     context,
                      //     MoveRightRoute(page: const HomePage(title: "Flashcard Tutor")),
                      //   );
                      // },
                    ),
                  ]
                ),
              ),

              
            ]
          ),
        )
      ]


    );
}
}

class DashboardBoxRight extends StatelessWidget {
  const DashboardBoxRight({super.key, 
    required this.title,
    required this.onPressed1,
    required this.onPressed2,
    this.subtitle,
    this.height,
  });

  final Future<void> Function() onPressed1;
  final Future<void> Function() onPressed2;
  final String title;
  final String? subtitle;
  final double? height;


  @override
  Widget build(BuildContext context) {
  
    return Column(
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              SizedBox(height: 4.0),
              Container(
                padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                child: Row(
                  children: [
                    IconButton(
                      label: 'Full-Sized Mock',
                      iconFilePath: 'assets/dashboard_assets/play_circle.png',
                      onPressed: onPressed1,
                      // onPressed: () {
                      //   Navigator.push(
                      //     context,
                      //     MoveRightRoute(page: const HomePage(title: "Exam Declaration")),
                      //   );
                      // },
                    ),
                    IconButton(
                      label: 'Mini Mock',
                      iconFilePath: 'assets/dashboard_assets/target.png',
                      onPressed: onPressed2,
                      // onPressed: () {
                      //   Navigator.push(
                      //     context,
                      //     MoveRightRoute(page: const HomePage(title: "Exam Declaration")),
                      //   );
                      // },
                    ),
                  ]
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    //color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    color: Colors.white,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            SizedBox(height: 5),
                            // Text(
                            //   title,
                            //   style: theme.textTheme.titleMedium?.copyWith(
                            //       color: themeProvider.isDarkMode ? Colors.black : Colors.white)
                            // ),
                            // subtitle == null ? CircularProgressIndicator(color: themeProvider.isDarkMode ? Colors.black : Colors.white) : 
                            // Text(
                            //   subtitle!,
                            //   style: theme.textTheme.bodyMedium?.copyWith(
                            //     color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                            //   )
                            // ),
                            SizedBox(height: 5),
                        ]),
                      ),
                    ])
                ),
              ),
            ]
          ),
        )
      ]


    );
  }
}

final TextStyle textStyle1 = TextStyle(
  fontFamily: 'Lato',
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: Colors.white,
);