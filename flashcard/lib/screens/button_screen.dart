import 'package:flutter/material.dart';

// TODO: Add a button to the screen
class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 40.31,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add your onPressed code here!

        },
        backgroundColor: const Color.fromARGB(255, 235, 230, 239),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(
          Icons.calendar_today,
          color: Color.fromARGB(255, 98, 86, 139),
        ),
        label: const Text(
          'Set Your Exam Date',
          style: TextStyle(
            color: Color.fromARGB(255, 98, 86, 139),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
