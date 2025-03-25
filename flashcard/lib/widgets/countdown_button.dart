import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Internal imports
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/screens/calendar_screen.dart';
import 'package:flashcard_x/screens/study_session_manager.dart';
import 'package:flashcard_x/screens/landing_service.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomFloatingButton extends StatefulWidget {
  const CustomFloatingButton({super.key});

  @override
  CustomFloatingButtonState createState() => CustomFloatingButtonState();
}

class CustomFloatingButtonState extends State<CustomFloatingButton> {
  DateTime? _examDate;
  DateTime? _firstStudyDate;
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  int buildCount = 0;
  bool testDayBool = true;
  bool buttonPressed = false;
  bool stopShowing = false;
  late String testDayString = "Test day not set";

  final Map<String, bool> _isHovered = {};

  @override
  void initState() {
    super.initState();
    getUser();
    getTestDay();
    getStopShowing(user!);
    getFirstStudyDay();
    if (mounted) setState(() {});
    _isHovered['checkbox1'] = false;
    _isHovered['checkbox2'] = false;
    _isHovered['checkbox3'] = false;
    _isHovered['checkbox4'] = false;
  }

  Future<void> setStopShowing(User user, [bool value = false]) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'stopShowing': value,
      'popUpTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // Merge to avoid overwriting other fields
  }

  Future<void> getStopShowing(User user) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      Timestamp? timestamp = doc['popUpTime'];

      if (doc['stopShowing'] != null && timestamp != null) {
        DateTime savedTime = timestamp.toDate();
        DateTime currentTime = DateTime.now();

        if (currentTime.difference(savedTime).inMinutes >= 1) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'stopShowing': false,
          });
        }
      } else {
        setStopShowing(user);
      }
      stopShowing = doc['stopShowing'];
    }
  }

  // Helper method
  Widget _buildAlertDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
    bool showScrollIndicator = false,
  }) {
    return Builder(builder: (context) {
      // Get screen width to determine layout
      final screenWidth = MediaQuery.of(context).size.width;

      return AlertDialog(
        backgroundColor: const Color(0xFFE6EDF2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: const Color.fromRGBO(21, 58, 103, 1),
                fontSize: screenWidth < 600 ? 18 : 21,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showScrollIndicator && screenWidth <= 375) ...[
              const SizedBox(height: 5),
              // Scroll indicator at the top
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.swipe_vertical,
                    size: 16,
                    color: Color.fromRGBO(21, 58, 103, 0.6),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Scroll for more options',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(21, 58, 103, 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        content: SizedBox(
          width: screenWidth < 450 ? screenWidth * 0.8 : 300,
          child: SingleChildScrollView(
            child: content,
          ),
        ),
        actions: actions,
        // actions: [
        //     if (useHorizontalLayout)
        //       // Horizontal layout for larger screens
        //       Container(
        //         width: double.infinity,
        //         child: Row(
        //           mainAxisAlignment: actions.length <= 2 ? MainAxisAlignment.end : MainAxisAlignment.center,
        //           children: [
        //             for (int i = 0; i < actions.length; i++) ...[
        //               Flexible(
        //                 child: Container(
        //                   constraints: BoxConstraints(
        //                     maxWidth: actions.length <= 2 
        //                         ? screenWidth * 0.35 
        //                         : screenWidth * 0.28,
        //                   ),
        //                   child: actions[i],
        //                 ),
        //               ),
        //               if (i < actions.length - 1) 
        //                 const SizedBox(width: 8),
        //             ],
        //           ],
        //         ),
        //       )
        //     else
        //       // Vertical layout for smaller screens
        //       for (int i = 0; i < actions.length; i++) ...[
        //         Container(
        //           width: double.infinity,
        //           child: actions[i],
        //         ),
        //         if (i < actions.length - 1) 
        //           const SizedBox(height: 8),
        //       ],
        //   ],
        // actionsPadding: const EdgeInsets.all(16),
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth < 450 ? 20 : 40,
          vertical: 24,
        ),
      );
    });
  }

  // Repurposed getter from calendar_screen.dart
  Future<void> getTestDay() async {
    if (user != null) {
      QuerySnapshot querySnapshot =
          await _userCollectionRef.where("userID", isEqualTo: user?.uid).get();

      var userFromDb = querySnapshot.docs.first;
      Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
      // If the Test Day field isn't null and is in the database we update the UI with it. Otherwise it is displayed as being not set.
      if ((data.containsKey("TestDay") || data["TestDay"] != null) &&
          (buildCount <= 2 || (_examDate != null && buildCount > 2))) {
        testDayBool = false;
        _examDate = DateTime.fromMicrosecondsSinceEpoch(userFromDb["TestDay"]
            .microsecondsSinceEpoch); // Firebase is weird. Conversion from TimeStamp to DateTime object
        String? day = _examDate?.day.toString();
        // String? month = _examDate?.month.toString();

        // Convert month number to month name
        String? month = _examDate?.month != null
            ? DateFormat('MMMM')
                .format(DateTime(_examDate!.year, _examDate!.month))
            : null;
        String? year = _examDate?.year.toString();
        // testDayString = '$day-$month-$year';
        testDayString = '$day ${month} $year';
      } else {
        testDayBool = true;
      }
      if (mounted) setState(() {});
    }
  }

  // Repurposed setter from calendar_screen.dart
  Future<void> updateTestDay(DateTime date) async {
    QuerySnapshot u =
        await _userCollectionRef.where("userID", isEqualTo: user?.uid).get();

    /*  FIRST update on database */
    var id = u.docs.last.id; // id being where the user's id details

    var userFromDb = u.docs.first;
    Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;

    _userCollectionRef.doc(id).update({
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

  Future<void> getUser() async {
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth.authStateChanges().first;
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
    getStopShowing(user!);
  }

  Future<void> getFirstStudyDay() async {
    if (user != null) {
      QuerySnapshot u =
          await _userCollectionRef.where("userID", isEqualTo: user?.uid).get();

      var userFromDb = u.docs.first;
      Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
      // If the Test Day field isn't null and is in the database we update the UI with it. Otherwise it is displayed as being not set.
      if (data.containsKey("firstStudyDay") && data["firstStudyDay"] != null) {
        // firstDayBool = false;
        _firstStudyDate = DateTime.fromMicrosecondsSinceEpoch(
            userFromDb["firstStudyDay"].microsecondsSinceEpoch);
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> shouldShowDialog() async {
    await getTestDay();
    await getStopShowing(user!);

    if (mounted &&
        testDayBool &&
        _examDate == null &&
        landingService.onLanding &&
        !stopShowing) {
      _showRevisionPlanDialog(context);
    }
  }

  // Revision dialog
  void _showRevisionPlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            bool isSmallScreen = constraints.maxWidth < 600;

            // Create responsive button layouts
            Widget noButton = TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromRGBO(243, 90, 90, 1),
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 24,
                    vertical: isSmallScreen ? 8 : 12),
                minimumSize:
                    Size(isSmallScreen ? 80 : 120, isSmallScreen ? 40 : 45),
              ),
              child: Text(
                'No',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
            );

            Widget yesButton = TextButton(
              key: const ValueKey('yesButton'),
              onPressed: () {
                Navigator.of(context).pop();
                _setFirstStudyDay();
                _showExamDateDialog(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromRGBO(51, 178, 73, 1),
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 24,
                    vertical: isSmallScreen ? 8 : 12),
                minimumSize:
                    Size(isSmallScreen ? 80 : 120, isSmallScreen ? 40 : 45),
              ),
              child: Text(
                'Yes',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
            );

            Widget dontShowButton = TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setStopShowing(user!, true);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 160, 160, 160),
                backgroundColor: Colors.transparent,
                minimumSize:
                    Size(isSmallScreen ? 160 : 120, isSmallScreen ? 40 : 45),
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 24,
                    vertical: isSmallScreen ? 8 : 12),
              ),
              child: Text(
                'Don\'t Show Again',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                textAlign: TextAlign.center,
              ),
            );

            return AlertDialog(
              backgroundColor: const Color(0xFFE6EDF2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              title: Text(
                'Do you want to start your revision plan today?',
                style: TextStyle(
                  color: const Color.fromRGBO(21, 58, 103, 1),
                  fontSize: isSmallScreen ? 18 : 21,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Container(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(flex: 1, child: yesButton),
                        SizedBox(width: isSmallScreen ? 3 : 4),
                        Flexible(flex: 1, child: noButton),
                        SizedBox(width: isSmallScreen ? 3 : 4),
                        Flexible(flex: 2, child: dontShowButton),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    buttonPressed
                        ? SizedBox()
                        : Text(
                            'If you want to stop seeing this pop up, press the "Don\'t Show Again" button',
                            style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: const Color.fromRGBO(21, 58, 103, 1))),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (mounted) setState(() {});
  }

  // Show the date picker dialog to select exam date
  void _showExamDateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialog(
          title: 'When is your exam date?',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('en', 'GB'),
                  );
                  if (picked != null) {
                    if (mounted) {
                      setState(() {
                        _examDate = picked;
                        updateTestDay(picked); // Update parent state
                        testDayBool = false;
                      });
                    }

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      _showExclusionDialog(context); // Proceed to next dialog
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Text color
                  backgroundColor: const Color.fromRGBO(
                      51, 178, 73, 1), // Same color as 'Yes' button
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(120, 45),
                ),
                child: const Text(
                  'Select Exam Date',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _examDate != null
                    ? 'Selected Date: ${DateFormat('dd MMM, yyyy').format(_examDate!)}' // UK Format
                    : 'No Date Selected',
                style: TextStyle(
                  color: _examDate != null
                      ? Colors.black
                      : const Color.fromRGBO(21, 58, 103, 1),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '• If you have not booked your exam date yet, you can enter an approximate date during the exam period window and edit it later. \n'
                '• For August starts, the exam window is usually between the 4th and 16th of January, and for February starts, this is the 2nd to 12th of September.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(21, 58, 103, 1),
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          actions: [],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //waits for build function to complete and then calls back to call the condition checking function
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shouldShowDialog();
    });
  }

  // Method to save firstStudyDay
  Future<void> _setFirstStudyDay() async {
    QuerySnapshot u =
        await _userCollectionRef.where("userID", isEqualTo: user?.uid).get();
    var id = u.docs.last.id;

    // Save the first study day only once when the revision plan starts
    await _userCollectionRef.doc(id).update({
      "firstStudyDay":
          DateTime.now(), // Save the current date as first study day
    });
    // Optionally, retrieve the first study day
    await getFirstStudyDay();
  }

  void _showOptionsDialog(BuildContext context) {
    final checkbox1 = ValueNotifier<bool>(false);
    final checkbox2 = ValueNotifier<bool>(false);
    final checkbox3 = ValueNotifier<bool>(false);
    final checkbox4 = ValueNotifier<bool>(false);
    final checkbox5 = ValueNotifier<bool>(false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            bool isSmallScreen = constraints.maxWidth < 600;

            return _buildAlertDialog(
              title: 'Which resources would you like to use?',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCheckbox(
                    checkbox1,
                    'Official MSRA Practice Paper',
                    description:
                        'The official past paper is available on the Health Education England website. '
                        'It contains 22 Professional Dilemma questions with realistic scenarios and reliable rationales created '
                        'by the same people who write the questions for the MSRA, making it a very valuable resource.\n\n'
                        'You will be prompted to specify your preferred number of practice attempts upon selection.',
                    showInfo: true,
                  ),
                  _buildCheckbox(
                    checkbox2,
                    'Full-sized Mock Exam',
                    description:
                        'Our full-sized mock exam has been designed to mimic the exact conditions you will have on exam day, '
                        'helping you optimize timings while exposing you to different professional scenarios. It includes 50 questions that '
                        'have been carefully created to align with official rationales and GMC guidelines.\n\n'
                        'You will be prompted to specify your preferred number of practice attempts upon selection.',
                    showInfo: true,
                  ),
                  _buildCheckbox(
                    checkbox3,
                    'Mini-mocks',
                    description:
                        'We have two mini-mocks available on the platform, which each contain 25 reliable questions. '
                        'They have been created to help track your progress, fine-tune exam timings and increase your exposure to different professional scenarios.',
                    showInfo: true,
                  ),
                  _buildCheckbox(
                    checkbox4,
                    'Flashcard Decks',
                    description:
                        'Our pre-made flashcard decks contain high-yield principles derived from GMC guidelines and official rationales. '
                        'This resource uses our unique, evidence-based algorithms to help you harness the power of spaced repetition and active recall!',
                    showInfo: true,
                  ),
                  _buildCheckbox(
                    checkbox5,
                    'Official SJT Practice Paper',
                    description:
                        'This is a practice paper released by the UKFPO as a resource for doctors preparing for the FY2 Situational Judgement Test, '
                        'which is part of the application process for stand-alone FY2 training. Be aware that this paper only includes 18 RATING questions '
                        '(not a format of questions that appears in the MSRA). '
                        'Nevertheless, increasing your exposure to questions and rationales created by the UKFPO is helpful when preparing for the Professional Dilemmas Paper.',
                    showInfo: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showExamDateDialog(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromRGBO(73, 148, 236, 1),
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 24,
                        vertical: isSmallScreen ? 8 : 12),
                    minimumSize: Size(120, 45),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
                TextButton(
                  key: const ValueKey('submitButton1'),
                  onPressed: () async {
                    // Check which resources were selected
                    List<String> selectedResources = [];
                    if (checkbox1.value)
                      selectedResources.add('Official MSRA Practice Paper');
                    if (checkbox2.value)
                      selectedResources.add('Full-sized Mock Exam');
                    if (checkbox3.value) selectedResources.add('Mini-mocks');
                    if (checkbox4.value) selectedResources.add('Flashcards');
                    if (checkbox5.value)
                      selectedResources.add('Official SJT Practice Paper');

                    if (selectedResources.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select at least one resource'),
                        ),
                      );
                      return;
                    }
                    QuerySnapshot u = await _userCollectionRef
                        .where("userID", isEqualTo: user?.uid)
                        .get();

                    var id = u.docs.last.id;
                    await _userCollectionRef.doc(id).update({
                      'selectedResources': selectedResources,
                    });
                    StudySessionManager().startStudySession(selectedResources);
                    Navigator.of(context).pop();

                    bool showRepetitionDialog =
                        checkbox1.value || checkbox2.value;

                    if (showRepetitionDialog) {
                      _showRepetitionDialog(context, selectedResources);
                    } else {
                      _scheduleCompleteDialog(context);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(51, 178, 73, 1),
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 24,
                        vertical: isSmallScreen ? 8 : 12),
                    minimumSize: Size(120, 45),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show dialog to ask for number of repetitions
  void _showRepetitionDialog(
      BuildContext context, List<String> selectedResources) {
    final List<int> repetitionOptions = [1, 2, 3, 4, 5, 6];

    // Define separate variables for each resource's repetition count
    int? officialMSRARepetitions;
    int? fullSizedMockRepetitions;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 600;

            Widget buildChoiceChips(List<int> options,
                bool isSelected(int value), Function(int) onSelected) {
              if (isSmallScreen) {
                // For mobile, split into two rows
                return Column(
                  children: [
                    // First row (1-3)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: options
                          .take(3)
                          .map((value) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: Text(value.toString()),
                                  selected: isSelected(value),
                                  onSelected: (_) => onSelected(value),
                                  selectedColor:
                                      const Color.fromRGBO(73, 148, 236, 1),
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected(value)
                                        ? Colors.white
                                        : const Color.fromRGBO(21, 58, 103, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    // Second row (4-6)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: options
                          .skip(3)
                          .map((value) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: Text(value.toString()),
                                  selected: isSelected(value),
                                  onSelected: (_) => onSelected(value),
                                  selectedColor:
                                      const Color.fromRGBO(73, 148, 236, 1),
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected(value)
                                        ? Colors.white
                                        : const Color.fromRGBO(21, 58, 103, 1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                );
              } else {
                // For desktop, single row
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: options
                      .map((value) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(value.toString()),
                              selected: isSelected(value),
                              onSelected: (_) => onSelected(value),
                              selectedColor:
                                  const Color.fromRGBO(73, 148, 236, 1),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected(value)
                                    ? Colors.white
                                    : const Color.fromRGBO(21, 58, 103, 1),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ))
                      .toList(),
                );
              }
            }

            return _buildAlertDialog(
              title: 'How many times would you like to repeat each resource?',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We recommend completing the official MSRA practice paper at least three times and the full-sized mock at least twice.\n'
                    'Your chosen number of repetitions will apply to each resource individually.',
                    style: TextStyle(
                      color: const Color.fromRGBO(21, 58, 103, 1),
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (selectedResources
                      .contains('Official MSRA Practice Paper'))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Official MSRA Practice Paper',
                          style: TextStyle(
                            color: const Color.fromRGBO(21, 58, 103, 1),
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildChoiceChips(
                          repetitionOptions,
                          (value) => officialMSRARepetitions == value,
                          (value) =>
                              setState(() => officialMSRARepetitions = value),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  if (selectedResources.contains('Full-sized Mock Exam'))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Full-sized Mock Exam',
                          style: TextStyle(
                            color: const Color.fromRGBO(21, 58, 103, 1),
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildChoiceChips(
                          repetitionOptions,
                          (value) => fullSizedMockRepetitions == value,
                          (value) =>
                              setState(() => fullSizedMockRepetitions = value),
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showOptionsDialog(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromRGBO(73, 148, 236, 1),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 24,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    minimumSize: Size(120, 45),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    bool isValid = true;
                    if (selectedResources
                            .contains('Official MSRA Practice Paper') &&
                        officialMSRARepetitions == null) {
                      isValid = false;
                    }
                    if (selectedResources.contains('Full-sized Mock Exam') &&
                        fullSizedMockRepetitions == null) {
                      isValid = false;
                    }

                    if (isValid) {
                      QuerySnapshot u = await _userCollectionRef
                          .where("userID", isEqualTo: user?.uid)
                          .get();

                      var id = u.docs.last.id;
                      await _userCollectionRef.doc(id).update({
                        'officialMSRARepetitions': officialMSRARepetitions,
                        'fullSizedMockRepetitions': fullSizedMockRepetitions,
                      });

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        _scheduleCompleteDialog(context);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please select repetition counts for all resources'),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(51, 178, 73, 1),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 24,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    minimumSize: Size(120, 45),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExclusionDialog(BuildContext context) {
    List<String> daysOfTheWeek = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

    Map<String, ValueNotifier<bool>> selectedDays = {
      for (var day in daysOfTheWeek) day: ValueNotifier<bool>(false),
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 600;

            return _buildAlertDialog(
              title:
                  'Would you like to have any days of the week off studying?',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: selectedDays.keys.map((day) {
                  return _buildCheckbox(selectedDays[day]!, day,
                      showInfo: false); // Hide info icon
                }).toList(),
              ),
              actions: [
                // Previous button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showExamDateDialog(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromRGBO(73, 148, 236, 1),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 24,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    minimumSize: Size(120, 45),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
                // Next button
                TextButton(
                  onPressed: () async {
                    List<String> excludedDays = selectedDays.entries
                        .where((entry) => entry.value.value)
                        .map((entry) => entry.key)
                        .toList();

                    // Save excluded days to the database
                    QuerySnapshot u = await _userCollectionRef
                        .where("userID", isEqualTo: user?.uid)
                        .get();

                    var id = u.docs.last.id;
                    await _userCollectionRef.doc(id).update({
                      'excludedDays': excludedDays,
                    });

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      _showOptionsDialog(context);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(51, 178, 73, 1),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 24,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    minimumSize: Size(120, 45),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ],
              showScrollIndicator: screenWidth <= 375,
            );
          },
        );
      },
    );
  }

  void _scheduleCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 600;

            return _buildAlertDialog(
              title: 'Schedule Complete!',
              content: Text(
                'Your study schedule has been successfully generated.',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: const Color.fromRGBO(21, 58, 103, 1),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 160, 160, 160),
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 24,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    minimumSize: Size(120, 45),
                  ),
                  child: Text(
                    'Ok',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // Show loading indicator while processing
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color.fromRGBO(51, 178, 73, 1),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Generating your personalised revision schedule...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(21, 58, 103, 1),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    try {
                      // Generate and save study sessions before navigating to calendar
                      final studySessionManager = StudySessionManager();
                      final events = await studySessionManager
                          .generateStudySessions(user!);
                      await studySessionManager.saveStudySessionsToDB(
                          user!, events);

                      // Close the loading dialog
                      Navigator.of(context).pop();
                      // Close the current dialog
                      Navigator.of(context).pop();

                      // Navigate to Calendar screen to see the new schedule
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Calendar(),
                        ),
                      );
                    } catch (e) {
                      // Close the loading dialog
                      Navigator.of(context).pop();
                      // Show error dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: Text(
                                'Failed to generate schedule: ${e.toString()}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(51, 178, 73, 1),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 24,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    minimumSize: Size(120, 45),
                  ),
                  child: Text(
                    'View Schedule',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoIcon(String id, String description) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Track if the tooltip is being manually shown (for mobile)
        bool isTooltipVisible = _isHovered[id] ?? false;

        return Container(
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                // Show info dialog for mobile
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color.fromRGBO(21, 58, 103, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white, width: 1),
                      ),
                      content: SizedBox(
                        width: 200,
                        child: Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered[id] = true),
                onExit: (_) => setState(() => _isHovered[id] = false),
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween<double>(
                    begin: 0,
                    end: isTooltipVisible ? 1.0 : 0.0,
                  ),
                  builder: (context, double value, child) {
                    final primaryColor = const Color.fromRGBO(21, 58, 103, 1);

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated effects - only shown on hover (desktop) not on tap (mobile)
                        if (value > 0 &&
                            Theme.of(context).platform !=
                                TargetPlatform.android &&
                            Theme.of(context).platform !=
                                TargetPlatform.iOS) ...[
                          // Position the wave effects in fixed positions with absolute positioning
                          Positioned.fill(
                            child: Center(
                              child: Transform.scale(
                                scale: 1.0 + (value * 0.8),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryColor
                                          .withOpacity(0.45 * value),
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Transform.scale(
                                scale: 1.0 + (value * 0.5),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryColor
                                          .withOpacity(0.55 * value),
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Transform.scale(
                                scale: 1.0 + (value * 0.2),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryColor
                                          .withOpacity(0.65 * value),
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Base icon (always shown)
                        Tooltip(
                          richMessage: WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: SizedBox(
                              width: 200,
                              child: Text(
                                description,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          preferBelow: true,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(21, 58, 103, 1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(21, 58, 103, 1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromRGBO(21, 58, 103, 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.info,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckbox(ValueNotifier<bool> notifier, String text,
      {String? description, bool showInfo = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: Theme(
              data: ThemeData(
                unselectedWidgetColor: const Color.fromRGBO(21, 58, 103, 1),
                checkboxTheme: CheckboxThemeData(
                  side: const BorderSide(
                      color: Color.fromRGBO(21, 58, 103, 1), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: notifier,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      key: ValueKey(text),
                      value: value,
                      onChanged: (bool? newValue) {
                        notifier.value = newValue ?? false;
                      },
                      activeColor: const Color.fromRGBO(51, 178, 73, 1),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  notifier.value = !notifier.value;
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(21, 58, 103, 1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (showInfo && description != null)
                      _buildInfoIcon(
                          text, description), // Show only if required
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Calculate number of days until the exam
  int _calculateDaysUntilExam(DateTime examDate) {
    final now = DateTime.now();
    final difference = examDate.difference(now);
    return difference.inDays + 1; // Ensure "today" counts as a day
  }

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 600;

        return Container(
          margin: const EdgeInsets.only(bottom: 55, right: 0),
          height: 40.31,
          child: FloatingActionButton.extended(
            label: Text(
              _examDate == null
                  ? isSmallScreen
                      ? 'Set Exam Date'
                      : 'Set Your Exam Date'
                  : _calculateDaysUntilExam(_examDate!) < 0
                      ? isSmallScreen
                          ? 'Passed'
                          : 'Exam has already passed'
                      : _calculateDaysUntilExam(_examDate!) == 0
                          ? isSmallScreen
                              ? "Today"
                              : "Exam is Today"
                          : isSmallScreen
                              ? '${_calculateDaysUntilExam(_examDate!)} Days'
                              : '${_calculateDaysUntilExam(_examDate!)} Days to Your Exam',
              style: const TextStyle(
                color: Color.fromARGB(255, 98, 86, 139),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              buttonPressed = true;
              getTestDay();
              if (testDayBool) {
                _showRevisionPlanDialog(context);
              } else if (!testDayBool) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return _buildAlertDialog(
                        title: 'Exam Date Already Set',
                        content: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Your exam date is already set to ',
                                style: TextStyle(
                                  color: const Color.fromRGBO(21, 58, 103, 1),
                                  fontSize: isSmallScreen ? 16 : 17,
                                ),
                              ),
                              TextSpan(
                                text: '${testDayString}',
                                style: TextStyle(
                                  color: const Color.fromRGBO(21, 58, 103, 1),
                                  fontSize: isSmallScreen ? 16 : 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '.\nDo you want to change it?',
                                style: TextStyle(
                                  color: const Color.fromRGBO(21, 58, 103, 1),
                                  fontSize: isSmallScreen ? 16 : 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    minimumSize: Size(120, 45),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 12 : 24,
                                      vertical: isSmallScreen ? 8 : 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        fontSize: isSmallScreen ? 13 : 16),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Calendar()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        Color.fromRGBO(243, 90, 90, 1),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 12 : 24,
                                        vertical: isSmallScreen ? 8 : 12),
                                    minimumSize: Size(120, 45),
                                  ),
                                  child: Text(
                                    'Change Exam Date',
                                    style: TextStyle(
                                        fontSize: isSmallScreen ? 13 : 16),
                                  )),
                            ],
                          ),
                        ],
                      );
                    });
              }
            },
            clipBehavior: Clip.none,
            backgroundColor: const Color.fromARGB(255, 235, 230, 239),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: isSmallScreen
                ? null
                : const Icon(
                    Icons.calendar_today,
                    color: Color.fromARGB(255, 98, 86, 139),
                  ),
          ),
        );
      },
    );
  }
}
