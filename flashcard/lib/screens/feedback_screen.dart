import 'dart:core';

import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/widgets/embedded_form.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const DrawMain(),
        appBar: AppBar(
            // backgroundColor: Colors.blue,
            title: Align(
              alignment: const Alignment(-0.05,0),
              child: Stack(
                children: [
                  Positioned(
                    top: 2.3,
                    child: Image.asset(
                      'assets/newlogo.png',
                      fit: BoxFit.cover,
                      height: 34,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 32),
                    padding: const EdgeInsets.all(8.0),
                    child: const Text('Feedback',
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: true,
            leading: Builder(
                builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(
                        Icons.menu,
                      ),
                    ))),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                              child: Center(
                                  child: Column(
                        children: const [
                            EmbeddedForm()
                          // Text.rich(TextSpan(
                          //     style: const TextStyle(
                          //         fontSize: 27, color: Colors.black),
                          //     children: [
                          //       const TextSpan(
                          //         style: TextStyle(
                          //             fontSize: 27, color: Colors.black),
                          //         text: "We would love to hear from you!\n",
                          //       ),
                          //       const TextSpan(
                          //           style: TextStyle(
                          //               fontSize: 27, color: Colors.black),
                          //           text:
                          //               "Please send your feedback and suggestions "),
                          //       TextSpan(
                          //           style: const TextStyle(
                          //               color: Colors.blue,
                          //               decoration: TextDecoration.underline),
                          //           //make link blue and underline
                          //           text: "here",
                          //           recognizer: TapGestureRecognizer()
                          //             ..onTap = () async {
                          //               //on tap code here, you can navigate to other page or URL
                          //               String url =
                          //                   "https://docs.google.com/forms/d/e/1FAIpQLSf10CDlLeFpaONtjS1pU0qcEsdQPfngeXh70-hhZpXUGCQDqA/viewform?usp=sf_link";
                          //               var urllaunchable =
                          //                   await canLaunchUrlString(
                          //                       url); //canLaunch is from url_launcher package
                          //               if (urllaunchable) {
                          //                 await launchUrlString(
                          //                     url); //launch is from url_launcher package to launch URL
                          //               } else {
                          //                 if (kDebugMode) {
                          //                   print("URL can't be launched.");
                          //                 }
                          //               }
                          //             }),
                          //     ])),
                        ],
                      )))),
                    ]))));
  }
}