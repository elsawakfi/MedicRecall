import 'dart:core';
import 'package:flashcard_x/screens/explanation.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/calendar_screen.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/faq.dart';
import 'package:flashcard_x/screens/flashcard_editor_screen.dart';
import 'package:flashcard_x/screens/minimock_landing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'feedback_screen.dart';
import 'fullmock_landing.dart';
import 'landing_service.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'mark_scheme.dart';
import 'package:flashcard_x/screens/settings_screen.dart' as setting;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flashcard_x/utils/last_revised.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'dart:async';
import 'package:flashcard_x/widgets/app_bar.dart';
import 'package:flashcard_x/widgets/drawer_widget2.dart';
import 'package:flashcard_x/widgets/countdown_button.dart';
import 'package:flashcard_x/screens/subtopic_choice_screen.dart';
import 'package:flashcard_x/utils/subscription_service.dart';

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
  DateTime? examDate; // Add this field
  DateTime? _firstStudyDate;
  bool onLanding = true;
  int buildCount = 0;
  final CollectionReference _userCollectionRef =
    FirebaseFirestore.instance.collection('users');
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String testDayString = "Test day not set";
  User? user;
  StreamSubscription? stream; // Add this field
  String daysUntilExam = "Date Not Set"; // Add this field

  List<bool> whichDaysRevised = [];
  List<DateTime> daysLoggedIn = [];
  int noDaysLoggedIn = 0;
  DateTime todaysDate = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  int numberOfDecksRevised = 0;
  int howManyDaysInARow = 0;

    // FETCHES DATA FROM FIREBASE AND UPDATES THE STATE
  Future<void> loadStreakData() async {
    StreakStats streakStats = await LastRevised.loadStreakStats();
    setState(() {
      numberOfDecksRevised = streakStats.numberOfDecksRevised;
      howManyDaysInARow = streakStats.howManyDaysInARow();
      whichDaysRevised = streakStats.last7Days();
      //examDate = streakStats.examDate;
      daysLoggedIn = streakStats.daysLoggedIn;
      noDaysLoggedIn = daysLoggedIn.length;
      todaysDate = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    });

  }

  // NEW VARIABLES FROM MEDICRECALL1
  String? nextTopicForReview;

  // @override
  // void initState() {
  //   super.initState();
  //   getUser();
  //   getFirstStudyDay();
  //   landingService.onLanding = true;
  //   if (mounted) setState(() {});
  // }

  // ----- Retrieve information for the dashboard -----
  Future<void> getNextTopicForReview() async {
    TopicStats stats = await LastRevised.getStats(includeSubtopics: false);
    Map<String, DateTime> nextReviewDatesMap = LastRevised.nextReviewDateByTopic(stats);
    String nextTopic = nextReviewDatesMap.keys.first;
    DateTime nextReviewDate = nextReviewDatesMap.values.first;

    for (String topicID in nextReviewDatesMap.keys) {
      if (nextReviewDatesMap[topicID]!.isBefore(nextReviewDate)) {
        nextTopic = topicID;
        nextReviewDate = nextReviewDatesMap[topicID]!;
      }
    }

    if (mounted) {
      setState(() {
        nextTopicForReview = nextTopic;
      });
    }

  }

  @override
  void initState() {
    super.initState();
    _initLanding();
  }

  Future<void> _initLanding() async {
    await subscriptionService.loadSubscription();
    landingService.onLanding = true;
    getUser().then( (_) async {
      await LastRevised.recordLogin();
      final nextTopic = await LastRevised.getNextTopicForReview();
      await getExamDate(); // Remove the assignment since it returns void

      // Update the state with the fetched data
      if (mounted) {
        setState(() {
          this.nextTopicForReview = nextTopic;
          // Remove this.examDate = examDate; since getExamDate() returns void
        });
      }
    });
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
                      child: Icon(icon, color: Colors.black, size: 24),
                    )
                  else
                    Icon(icon, color: Colors.black, size: 24),
                  SizedBox(width: isMobile ? 8 : 10),
                  Expanded(
                    child: Text(
                      text,
                      style: textStyle1,
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
        floatingActionButton: const CustomFloatingButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      //title: "User Dashboard",
      drawer: const DrawMain2(),
      appBar: CustomAppBar(
        title: 'MedicRecall',
        mobileTitle: 'MedicRecall',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),

              // TOP LEFT AND RIGHT WIDGETS (FLASHCARD TUTOR AND MOCK EXAMS)
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
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubtopicChoice(
                              flashcardSet: "Medical Topics",
                              subtopics: ["Cardiology", "Neurology", "Endocrinology", "Respiratory"],
                            ),
                          ),
                        );
                      }
                    ),
                  ),
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

              // STUDY SCHEDULE AND CREATE NEW FLASHCARDS ICON BUTTONS
              Row(children: [
                _IconButton(
                  label: 'Study Schedule',
                  iconFilePath: 'assets/dashboard_assets/calendar.png',
                  onPressed: () => triggerSignIn('Calendar'),
                ),
                _IconButton(
                  label: 'Create New Flashcards',
                  iconFilePath: 'assets/dashboard_assets/plus.png',
                  onPressed: () => triggerSignIn('FlashcardEditor'),
                ),
              ],
              ),

              SizedBox(height: 16),

              // 3 STATISTICS WIDGETS
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: AppColours.almostWhite,
                      child: Padding(
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 20.0, vertical: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(mainAxisAlignment: MainAxisAlignment.start,
                            children:[
                              SizedBox(width: 15),
                              Image.asset(
                                'assets/dashboard_assets/bar_chart.png',
                                height: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Statistics",
                                style: textStyleBlack,
                              ),
                            ]),

                          SizedBox(height: 2),
                          Row(children: [
                            StatisticsWidget(title: "Streak Count", iconFilePath: 'assets/dashboard_assets/fire.png', iconHeight: 55, displayedValue: howManyDaysInARow),
                            SizedBox(width: 10),
                            StatisticsWidget(title: "Total Days Revised", iconFilePath: 'assets/dashboard_assets/clock.png', iconHeight: 40, displayedValue: numberOfDecksRevised),
                            SizedBox(width: 10),
                            StatisticsWidget(
                              title: "Exam Countdown", iconFilePath: 'assets/dashboard_assets/calendar.png', iconHeight: 45,
                              // displayedValue: localExamDate != null
                              // ? (localExamDate.isAfter(todaysDate)
                              //   ? localExamDate.difference(todaysDate).inDays
                              //   : 0)
                              // : -1
                              displayedValue: 1, // PLACEHOLDER
                            ),
                          ]),
                        ])
                      )
                    )
                  )
                ]
              ),

              SizedBox(height: 16),

              // HOW DOES MEDICRECALL WORK, FAQ, FEEDBACK ICON BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _IconButton(
                    label: 'How does MedicRecall work?',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExplanationScreen(),
                        )
                      );
                    },
                  ),
                  _IconButton(
                    label: 'Frequently asked Questions',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FAQScreen(),
                        ),
                      );
                    },
                  ),
                  _IconButton(
                    label: 'Give us Feedback',
                    onPressed: () async {
                      landingService.onLanding = false;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
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

    Future<void> getExamDate() async {

    if (FirebaseWrapper.auth().currentUser == null) {
      return;
    }

    String userID = (await FirebaseWrapper.firestore().collection("users").where("userID", isEqualTo: FirebaseWrapper.auth().currentUser!.uid).get()).docs.last.id;
    var snapshots =  FirebaseWrapper.firestore().doc("users/$userID").snapshots();

    if (mounted) {
      stream = snapshots.listen((snapshot) {
        Timestamp? testDay = (snapshot.data()??{})["TestDay"];
        if (mounted) {
          if (testDay != null) {
            setState(() {
              daysUntilExam = "${testDay.toDate().difference(DateTime.now()).inDays} days";
            });
          } else {
            setState(() {
              daysUntilExam = "Date Not Set";
            });
          }
        }
      });

      setState(() {});
    }
  }
}

class _IconButton extends StatelessWidget {
  
  const _IconButton({super.key, 
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
            elevation: 4,
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
            color: AppColours.almostWhite,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              SizedBox(height: 4.0),
              Container(
                padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                child: Row(
                  children: [
                    _IconButton(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColours.almostWhite,
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
                            Text(
                              title,
                              style: textStyleBlack.copyWith(fontSize: 18),
                            ),
                            Text(
                              subtitle!,
                              style: textStyleBlack.copyWith(fontSize: 14),
                            ),
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
            color: AppColours.almostWhite,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              SizedBox(height: 4.0),
              Container(
                padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                child: Row(
                  children: [
                    _IconButton(
                      label: 'Full-Sized Mock',
                      iconFilePath: 'assets/dashboard_assets/play_circle.png',
                      onPressed: onPressed1,
                    ),
                    _IconButton(
                      label: 'Mini Mock',
                      iconFilePath: 'assets/dashboard_assets/target.png',
                      onPressed: onPressed2,
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
                    color: AppColours.almostWhite,
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
                            Text(
                              title,
                              style: textStyleBlack.copyWith(fontSize: 18),
                            ),
                            subtitle == null ? CircularProgressIndicator(color: Colors.black) : 
                            Text(
                              subtitle!,
                              style: textStyleBlack.copyWith(fontSize: 14),
                            ),
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

class StatisticsWidget extends StatelessWidget {
  const StatisticsWidget({super.key, 
    required this.title,
    required this.iconFilePath,
    required this.displayedValue,
    required this.iconHeight,
  });

  final String title;
  final String iconFilePath;
  final int displayedValue;
  final int iconHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10,15,10,10),
          child: Column(
            children: [
              Column(children: [
                SizedBox(height: 5),
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: textStyle1,
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                    "$displayedValue days",
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: AppColours.almostWhite,
                        fontWeight: FontWeight.w200,
                        fontSize: 40
                      )
                    ),
                    SizedBox(width: 20),
                    Container(
                      height: iconHeight.toDouble(),
                      child: Image.asset(
                        iconFilePath,
                      )
                    ),
                ])
              ])
            ],
          ),
        ),
      ),
    );
  }
}

final TextStyle textStyle1 = TextStyle(
  fontFamily: 'Lato',
  fontSize: 18,
  fontWeight: FontWeight.normal,
  color: AppColours.almostWhite,
);

final TextStyle textStyleBlack = TextStyle(
  fontFamily: 'Lato',
  fontSize: 18,
  fontWeight: FontWeight.normal,
  color: Colors.black,
);

final TextStyle bodyMedium = TextStyle(
  fontFamily: 'Lato',
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: AppColours.almostWhite,
);

class AppColours {
  static const Color darkBlue = Color.fromRGBO(20, 35, 52, 1);
  static const Color almostWhite = Color.fromRGBO(230, 230, 230, 1);
  static const Color orange = Color.fromRGBO(221, 117, 67, 1);
}