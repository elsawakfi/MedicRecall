import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcard_x/utils/firebase_wrapper.dart';
import 'package:flutter/material.dart';

class ScreenTitleBar extends StatelessWidget {
  final String title;
  const ScreenTitleBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: Colors.blue[300],
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.black),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              DateTime? date = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365*2)),
              );
              if (date != null) {
                await _updateExamDate(date);
              }
            },
            icon: Icon(Icons.calendar_today, color: Colors.purple[700]),
            label: Text('Set your exam date', style: theme.textTheme.bodyMedium!.copyWith(color: Colors.purple[700])),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[50],
              padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateExamDate(DateTime newDate) async {

    String userID = (await FirebaseWrapper.firestore().collection("users").where("userID", isEqualTo: FirebaseWrapper.auth().currentUser!.uid).get()).docs.last.id;
    var ref = FirebaseWrapper.firestore().doc("users/$userID");
    ref.update({"TestDay" : Timestamp.fromDate(newDate)});

  }

}