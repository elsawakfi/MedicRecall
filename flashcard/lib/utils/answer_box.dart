import 'package:flutter/material.dart';

class AnswerBox extends StatelessWidget {
  //const AnswerBox({Key? key}) : super(key: key);

  final String answerText;
  final Color? answerColor;
  final VoidCallback
      answerTap; //void call back used as a shorthand for void function, cannot just just funciton

  const AnswerBox(
      {Key? key,
      required this.answerText,
      required this.answerColor,
      required this.answerTap})
      : super(key: key);

  answer({answerText, answerColor}) {
    // TODO: implement Answer
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // where the answers will go, allows for tap functionality over what you wrapped it
      onTap: answerTap,
      child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: answerColor,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(answerText, style: const TextStyle(color: Colors.black))),
    );
  }
}
