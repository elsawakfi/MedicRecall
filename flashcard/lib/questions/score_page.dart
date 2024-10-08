
import 'package:flutter/material.dart';

/*
SCORING PAGE

This class takes in the user's score and other suitable parameters in order to tell them the result of their quiz


 */

/*
What needs to be taken as parameter

- score
- threshold - right now do simple green or red
- max mark
- question rationale
 */

class ScorePage extends StatefulWidget {
  final int score, threshold, maxMark;

  final String questionRationale;

  const ScorePage({
    Key? key,
    required this.score,
    required this.threshold,
    required this.maxMark,
    required this.questionRationale,
  }) : super(key: key);

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: (widget.score >= widget.threshold) ?
        //Colors.green : Colors.red,
        appBar: AppBar(
          // backgroundColor: Colors.blue,
          elevation: 0,
          title: const Text('Your Score'),
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
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: (widget.score > widget.threshold)
                        ? Colors.green
                        : Colors.red,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Text(
                    "Your Score is ${widget.score} / ${widget.maxMark}",
                    style: const TextStyle(fontSize: 35, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    //color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Text(
                    widget.questionRationale,
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )))
          ],
        )));
  }
}
