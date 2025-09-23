import 'dart:core';
import 'package:flashcard_x/widgets/drawer_widget2.dart';
import 'package:flashcard_x/widgets/embedded_form.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/app_bar.dart';
class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawMain2(),
        appBar: CustomAppBar(
          title: 'Feedback',
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16),
                  child: Center(
                    child: EmbeddedForm()))));
  }
}