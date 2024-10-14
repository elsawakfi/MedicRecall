import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/widgets/design_main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import 'feedback_screen.dart';
import 'mark_scheme.dart';

// TODO: Add a button to the screen

import 'package:flutter/material.dart';


@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text("Extended FAB Example"),
        backgroundColor: Colors.transparent,
        elevation: 0, // No shadow for app bar
      ),
      body: const Center(
        child: Text(
          "Content goes here",
          style: TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        width: 175,
        height: 40.31,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 235, 230, 239), // Soft pastel background
          borderRadius: BorderRadius.circular(15.73), // Smooth rounded edges
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Soft shadow
              offset: const Offset(0, 2), // Vertical shadow
              blurRadius: 6, // Slight blur for shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/calendar_icon.png', // Calendar icon
              width: 20, // Match your design
              height: 20,
              color: const Color.fromARGB(255, 98, 86, 139), // Icon color
            ),
            const SizedBox(width: 8), // Space between icon and text
            const Text(
              "__ Days Until the Exam",
              style: TextStyle(
                color: Color.fromARGB(255, 98, 86, 139), // Text color
                fontSize: 14, // Match your design size
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
