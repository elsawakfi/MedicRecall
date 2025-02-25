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

/*import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/widgets/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:table_calendar/table_calendar.dart';*/

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
  late String testDayString = "Test day not set";

  final Map<String, bool> _isHovered = {};

  @override
  void initState() {
    super.initState();
    getUser();
    getTestDay();
    getFirstStudyDay();
    setState(() {});
    _isHovered['checkbox1'] = false;
    _isHovered['checkbox2'] = false;
    _isHovered['checkbox3'] = false;
    _isHovered['checkbox4'] = false;
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
      content: SizedBox(
        width: 300,
        child: content,
      ),
      actions: actions,
    );
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
            ? DateFormat('MMMM').format(DateTime(_examDate!.year, _examDate!.month))
            : null;
        String? year = _examDate?.year.toString();
        // testDayString = '$day-$month-$year';
        testDayString = '$day ${month} $year';
      } else {
        testDayBool = true;
      }
      setState(() {});
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

      "firstStudyDay": data.containsKey("firstStudyDay") && data["firstStudyDay"] != null
        ? data["firstStudyDay"] // Keep existing firstStudyDay if it exists
        : DateTime.now(), // Otherwise, set it to now
      });

    // update field testday to what is passed as param
    await getTestDay();
    setState(() {});
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

      setState(() {});
    }
  }

  // Revision dialog
  void _showRevisionPlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialog(
          title: 'Do you want to start your revision plan today?',
          content: const SizedBox(), // Empty content for this dialog
          actions: [
            TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(243, 90, 90, 1),
              // backgroundColor: const Color.fromRGBO(243, 90, 90, 1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45), // Sets minimum width and height
            ),
            child: const Text(
              'No',
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            key: const Key('yesButton'),
            onPressed: () {
              Navigator.of(context).pop();
              _setFirstStudyDay(); // Ensure this function is defined
              _showExamDateDialog(context); // Ensure this function is defined
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(51, 178, 73, 1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45), // Sets minimum width and height
            ),
            child: const Text(
              'Yes',
              style: TextStyle(fontSize: 16),
            ),
          ),
            
          ],
        );
      },
    );
  }
    Future<void> shouldShowDialog() async{
      await getTestDay();
      
      if (mounted && testDayBool && _examDate == null && landingService.onLanding){
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

   @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    //waits for build function to complete and then calls back to call the condition checking function 
    WidgetsBinding.instance.addPostFrameCallback((_){
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

  // Show the date picker dialog to select exam date
  void _showExamDateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialog(
          title: 'When is your exam date?',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            // If statement to check if firebase already has exam date in database
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
                    setState(() {
                      _examDate = picked;
                      updateTestDay(picked); // Update parent state
                      testDayBool = false;
                    });

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      _showOptionsDialog(context); // Proceed to next dialog
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Text color
                  backgroundColor: const Color.fromRGBO(51, 178, 73, 1), // Same color as 'Yes' button
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(120, 45),
                ),
                child: const Text(
                  'Select Exam Date',
                  style: TextStyle(fontSize: 16),
                  ),
              ),
              const SizedBox(height: 10),
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
                    'How many times would you like to practice the selected resources?',
                    style: const TextStyle(
                      color: Color.fromRGBO(21, 58, 103, 1),
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8), // Add spacing between lines
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text:
                              'It is recommended to practice at least three times.\nYour chosen number of repetition will apply to both the ',
                          style: TextStyle(
                            color: Color.fromRGBO(21, 58, 103, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w400, // Regular font weight
                          ),
                        ),
                        TextSpan(
                          text: 'Official Paper and Full-sized Mock Exam.',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, // Make it bold
                            color: Color.fromRGBO(21, 58, 103, 1),
                            fontSize: 16,
                          ),
                        ),
                      ],
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
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(73, 148, 236, 1),
                      // backgroundColor: const Color.fromRGBO(243, 90, 90, 1),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      minimumSize: const Size(120, 45), // Sets minimum width and height
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                    TextButton(
                      onPressed: () async {
                        if (selectedRepetition != null) {
                          // Save selectedRepetition to the database
                          QuerySnapshot u = await _userCollectionRef
                              .where("userID", isEqualTo: user?.uid)
                              .get();

                          var id = u.docs.last.id;
                          await _userCollectionRef.doc(id).update({
                            'selectedRepetition': selectedRepetition,
                          });

                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please enter number of repetitions'),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromRGBO(51, 178, 73, 1),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        minimumSize: const Size(120, 45), // Sets minimum width and height
                      ),
                      child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 16),
                      ),
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

  void _showOptionsDialog(BuildContext context) {
    final checkbox1 = ValueNotifier<bool>(false);
    final checkbox2 = ValueNotifier<bool>(false);
    final checkbox3 = ValueNotifier<bool>(false);
    final checkbox4 = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialog(
          title: 'Which resources would you like to use?',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCheckbox(
                checkbox1, 
                'Official Practice Paper',
                'The official past paper is available on the Health Education England website. It contains 22 Professional Dilemma questions with realistic scenarios and reliable rationales created by the same people who write the questions for the MSRA, making it a very valuable resource. You will be prompted to specify your preferred number of practice attempts upon selection.'
              ),
              _buildCheckbox(
                checkbox2, 
                'Full-sized Mock Exam',
                'Our full-sized mock exam has been designed to mimic the exact conditions you will have on exam day, helping you optimise timings while exposing you to different professional scenarios. It includes 50 questions that have been carefully created to align with official rationales and GMC guidelines. You will be prompted to specify your preferred number of practice attempts upon selection.'
              ),
              _buildCheckbox(
                checkbox3, 
                'Mini-mocks',
                'We have two mini-mocks available on the platform, which each contain 25 reliable questions. They have been created to help track your progress, fine-tune exam timings and increase your exposure to different professional scenarios.'
              ),
              _buildCheckbox(
                checkbox4, 
                'Flashcard Decks',
                'Our pre-made flashcard decks contain high-yield principles derived from GMC guidelines and official rationales. This resource uses our unique, evidence-based algorithms to help you harness the power of spaced repetition and active recall!'
              ),
            ],
          ),
          actions: [
            TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(73, 148, 236, 1),
              // backgroundColor: const Color.fromRGBO(243, 90, 90, 1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45), // Sets minimum width and height
            ),
            child: const Text(
              'Previous',
              style: TextStyle(fontSize: 16),
            ),
          ),
            TextButton(
              onPressed: () async {
                // Check which resources were selected
                List<String> selectedResources = [];
                if (checkbox1.value) selectedResources.add('Official paper');
                if (checkbox2.value) selectedResources.add('Full-sized mock exam');
                if (checkbox3.value) selectedResources.add('Mini-mocks');
                if (checkbox4.value) selectedResources.add('Flashcards');

                if (selectedResources.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select at least one resource'),
                    ),
                  );
                  return; // Stop execution if no resources are selected
                }

                QuerySnapshot u = await _userCollectionRef
                    .where("userID", isEqualTo: user?.uid)
                    .get();

                // Update Firestore with selected resources
                var id = u.docs.last.id;
                _userCollectionRef.doc(id).update({
                  'selectedResources': selectedResources,
                });

                // Start study session
                StudySessionManager().startStudySession(selectedResources);

                // Close current dialog
                Navigator.of(context).pop();

                // If either Official Paper or Full-sized Mock is selected, show Repetition Dialog
                if (checkbox1.value || checkbox2.value) {
                  _showRepetitionDialog(context);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromRGBO(51, 178, 73, 1),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                minimumSize: const Size(120, 45), // Sets minimum width and height
              ),
              child: const Text(
              'Submit',
              style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoIcon(String id, String description) {
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered[id] = true),
          onExit: (_) => setState(() => _isHovered[id] = false),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(
              begin: 0,
              end: _isHovered[id] ?? false ? 1.0 : 0.0,
            ),
            builder: (context, double value, child) {
              final primaryColor = const Color.fromRGBO(21, 58, 103, 1);

              return SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer wave
                    if (value > 0)
                      Transform.scale(
                        scale: 1.0 + (value * 0.8),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withOpacity(0.45 * value),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                    // Middle wave
                    if (value > 0)
                      Transform.scale(
                        scale: 1.0 + (value * 0.5),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withOpacity(0.55 * value),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                    // Inner wave
                    if (value > 0)
                      Transform.scale(
                        scale: 1.0 + (value * 0.2),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withOpacity(0.65 * value),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                    // Base icon
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
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCheckbox(ValueNotifier<bool> notifier, String text, String description) {
    String id = text.toLowerCase().replaceAll(' ', '_');
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
                  side: const BorderSide(color: Color.fromRGBO(21, 58, 103, 1), width: 2),
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
                    _buildInfoIcon(id, description),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 55),
      width: 210,
      height: 40.31,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        label: Text(
          _examDate == null
              ? 'Set Your Exam Date'
              : _calculateDaysUntilExam(_examDate!) < 0
                  ? 'Exam has already passed'
                  : _calculateDaysUntilExam(_examDate!) == 0
                      ? "Exam is Today"
                      : '${_calculateDaysUntilExam(_examDate!)} Days to Your Exam',
          style: const TextStyle(
            color: Color.fromARGB(255, 98, 86, 139),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: () {
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
                              fontSize: 17,
                            ),
                          ),
                          TextSpan(
                            text: '${testDayString}',
                            style: TextStyle(
                              color: const Color.fromRGBO(21, 58, 103, 1),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '.\nDo you want to change it?',
                            style: TextStyle(
                              color: const Color.fromRGBO(21, 58, 103, 1),
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            minimumSize:
                                Size(120, 45), // Sets minimum width and height
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16),
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
                            backgroundColor: Color.fromRGBO(243, 90, 90, 1),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            minimumSize:
                                Size(120, 45), // Sets minimum width and height
                          ),
                          child: Text(
                            'Change Exam Date',
                            style: TextStyle(fontSize: 16),
                          )),
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
        icon: const Icon(
          Icons.calendar_today,
          color: Color.fromARGB(255, 98, 86, 139),
        ),
      ),
    );
  }
}
