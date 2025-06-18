import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const Indicator({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(Icons.circle, color: color, size: 38),
      SizedBox(width: 8),
      Text(text, style: TextStyle(color: color, fontSize: 16))
    ]);
  }

}