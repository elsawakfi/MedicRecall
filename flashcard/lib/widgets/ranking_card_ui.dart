import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget {
  final String text;
  final bool overflow; // Is the text allowed to overflow?

  const OptionCard({
    required this.text,
    this.overflow = true,
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
            // As the 'feedback' cards aren't dynamically sized we must be careful of overflows
            softWrap: overflow,
            overflow: (overflow) ? null : TextOverflow.ellipsis,
            maxLines: (overflow) ? null : 3,
          ),
        )
    );
  }
}