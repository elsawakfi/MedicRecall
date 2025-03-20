import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget {
  final String text;

  const OptionCard({
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 3,
        color:Color.fromARGB(255, 222, 221, 222),
        child: ListTile(
          title: Text(text,
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 20),
          ),
        )
    );
  }
}