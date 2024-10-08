import 'dart:core';

import 'package:flutter/material.dart';

class QuestionFAQ extends StatelessWidget {
  const QuestionFAQ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.blue,
          elevation: 0,
          title: const Text('Question type information'),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: SingleChildScrollView(
                    child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("Multiple Choice", style: TextStyle(fontSize: 35)),
                const SizedBox(height: 20),
                const Text(
                    " - These questions are marked out of 12, with 4 marks awarded per correct question. \n"
                    "\n"
                    " - This means you pick the 3 most suitable answers. \n"
                    "\n"
                    " - You are given the topics that these questions are based on. (i.e Patient Focus) \n"
                    "\n"
                    " - The rationale behind the correct answers are given once you submit \n",
                    style: TextStyle(fontSize: 20)),
                const Divider(height: 20, thickness: 5),
                const Text("Rating", style: TextStyle(fontSize: 35)),
                const SizedBox(height: 20),
                const Text(
                    " - You are given a scenario and some options that can be taken \n"
                    "\n"
                    " - Rate the options in terms of appropriateness \n"
                    "\n"
                    " - Max marks given for a correct guess, down to 0 marks if you are very incorrect \n ",
                    style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                Image.asset('assets/rating_image.png'),
                const Divider(height: 20, thickness: 5),
                const Text("Ranking", style: TextStyle(fontSize: 35)),
                const SizedBox(height: 20),
                const Text(
                    " - You are given a scenario and a number of actions that you can take. \n"
                    "\n"
                    " - Rank them in terms of how appropriate each action is  for the given situation. \n"
                    "\n"
                    " - 1 = Very appropriate, 2 = Somewhat appropriate, 3 = Somewhat inappropriate, 4 = Very inappropriate \n"
                    "\n"
                    " - You are given 4 marks for correctly assigning the responses to their appropriate ranking. \n"
                    "\n"
                    " - Less marks per choice for being slightly off, 0 marks if you give the wrong answer (ie. very appropriate when it is not appropriate) \n",
                    style: TextStyle(fontSize: 20)),
                Image.asset('assets/ranking_image.png'),
                const SizedBox(height: 20),
              ],
            )))
          ],
        )));
  }
}
