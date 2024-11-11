import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'calendar_screen.dart';
import 'study_session_manager.dart';

class CustomFloatingButton extends StatefulWidget {
  const CustomFloatingButton({Key? key}) : super(key: key);

  @override
  _CustomFloatingButtonState createState() => _CustomFloatingButtonState();
}

class _CustomFloatingButtonState extends State<CustomFloatingButton> {
  DateTime? _examDate;
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('users');

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;

  int buildCount = 0;
  bool testDayBool = true;
  late String testDayString = "Test day not set";

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

  // Repurposed getter from calendar_screen.dart
  Future<void> getTestDay() async {
    QuerySnapshot querySnapshot =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();

    var userFromDb = querySnapshot.docs.first;
    Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
    // If the Test Day field isn't null and is in the database we update the UI with it. Otherwise it is displayed as being not set.
    if ((data.containsKey("TestDay") || data["TestDay"] != null) &&
        (buildCount <= 2 || (_examDate != null && buildCount > 2))) {
      testDayBool = false;
      _examDate = DateTime.fromMicrosecondsSinceEpoch(userFromDb["TestDay"]
          .microsecondsSinceEpoch); // Firebase is weird. Conversion from TimeStamp to DateTime object
      String? day = _examDate?.day.toString();
      String? month = _examDate?.month.toString();
      String? year = _examDate?.year.toString();
      testDayString = '$day-$month-$year';
    } else {
      testDayBool = true;
    }
    setState(() {});
  }

  // Repurposed setter from calendar_screen.dart
  Future<void> updateTestDay(DateTime date) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    QuerySnapshot u =
        await _userCollectionRef.where("userID", isEqualTo: user.uid).get();

    /*  FIRST update on database */
    var id = u.docs.last.id; // id being where the user's id details
    users.doc(id).update({
      "TestDay": _examDate,
    }); // update field testday to what is passed as param
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
    );
  }

  // Show the date picker dialog to select exam date
  void _showExamDateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialog(
          title: 'What is your exam date?',
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
                  );
                  if (picked != null) {
                    setState(() {
                      _examDate = picked;
                      updateTestDay(picked); // Update parent state
                      testDayBool = false;
                    });
                    Navigator.of(context).pop();
                    _showRepetitionDialog(context); // Proceed to next dialog
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(21, 58, 103, 1),
                ),
                child: const Text('Pick Date'),
              ),
              const SizedBox(height: 10),
              Text(
                _examDate != null
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
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialog(
          title: 'How many repetitions of the official paper link?',
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter number of repetitions',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showExamDateDialog(context);
              },
              child: const Text('Previous'),
            ),
            TextButton(
              onPressed: () {
                final int? repetitions = int.tryParse(controller.text);
                if (repetitions != null &&
                    repetitions > 0 &&
                    repetitions < 10) {
                  Navigator.of(context).pop();
                  _showOptionsDialog(context); // Proceed to next dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a number between 1 and 9'),
                    ),
                  );
                }
              },
              child: const Text('Submit'), // change it to 'Next' once we have more questions in
            ),
          ],
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
                if (checkbox1.value ||
                    checkbox2.value ||
                    checkbox3.value ||
                    checkbox4.value) {
                  List<String> selectedResources = [];
                  if (checkbox1.value) selectedResources.add('Official paper');
                  if (checkbox2.value) selectedResources.add('Full-sized mock exam');
                  if (checkbox3.value) selectedResources.add('Mini-mocks');
                  if (checkbox4.value) selectedResources.add('Flashcards');

                  // Update the Firestore document with the selected resources
                  _userCollectionRef
                      .doc(user.uid)
                      .update({'selectedResources': selectedResources});

                  // Start the study session with the selected resources
                  StudySessionManager().startStudySession(selectedResources);
                  
                  Navigator.of(context).pop();
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

  // Calculate number of days until the exam
  int _calculateDaysUntilExam(DateTime examDate) {
    final now = DateTime.now();
    final difference = examDate.difference(now);
    return difference.inDays + 1; // Ensure "today" counts as a day
  }

  @override
  Widget build(BuildContext context) {
    buildCount++;
    getUser();
    getTestDay();
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
          _examDate != null
              ? '${_calculateDaysUntilExam(_examDate!)} Days to Your Exam'
              : 'Set Your Exam Date',
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
                  content: Text(
                    'Your exam date is already set to $testDayString.\nDo you want to change it?',
                    style: TextStyle(
                      color: const Color.fromRGBO(21, 58, 103, 1),
                      fontSize: 16,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Calendar()),
                        );
                      },
                      child: Text('Change Exam Date'),
                    ),
                  ],
                );
              },
            );
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
