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

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Button Screen"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(1, 98,	86,	139),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("__ Days Until Exams"),
          style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(1, 235, 230, 239),
            elevation: 0,
          ),
          onPressed: () {},
        ),
      ),
    );
  }