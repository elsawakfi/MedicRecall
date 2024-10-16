import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomFloatingButton extends StatefulWidget {
  const CustomFloatingButton({Key? key}) : super(key: key);

  @override
  _CustomFloatingButtonState createState() => _CustomFloatingButtonState();
}

class _CustomFloatingButtonState extends State<CustomFloatingButton> {
  DateTime? _examDate;

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

  //  revision dialog 
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
                      _examDate = picked; // Update parent state
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
    final _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialog(
          title: 'How many repetitions of the official paper link?',
          content: TextField(
            controller: _controller,
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
                final int? repetitions = int.tryParse(_controller.text);
                if (repetitions != null && repetitions > 0) {
                  Navigator.of(context).pop();
                  // Add your action here after repetitions are submitted
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid number greater than zero'),
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
        onPressed: () {
          _showRevisionPlanDialog(context);
        },
        backgroundColor: const Color.fromARGB(255, 235, 230, 239),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(
          Icons.calendar_today,
          color: Color.fromARGB(255, 98, 86, 139),
        ),
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
      ),
    );
  }
}
