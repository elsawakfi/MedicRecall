import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MiniMockHelpButton extends StatefulWidget {
  const MiniMockHelpButton({super.key});

  @override
  MiniMockHelpButtonState createState() => MiniMockHelpButtonState();
}

class MiniMockHelpButtonState extends State<MiniMockHelpButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: (){
        _helpPopup(context);
      },
      clipBehavior: Clip.none,
      backgroundColor: const Color.fromARGB(255, 235, 230, 239),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.question_mark, color: Color.fromARGB(255, 98, 86, 139),),
    );
  }

  void _helpPopup(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: const Color(0xFFE6EDF2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            title: Text(
              'Mini-Mock Help Menu',
              style: const TextStyle(
                color: Color.fromRGBO(21, 58, 103, 1),
                fontSize: 21,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _reviewPopup(context);
                  },
                  child: const Text('Flagging/Review'),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                    },
                    child: const Text('Close'),
                  ),
                ],
              )
            ]
        );
      },
    );
  }

  void _reviewPopup(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: const Color(0xFFE6EDF2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            title: Text(
              'Flagging/Review Help',
              style: const TextStyle(
                color: Color.fromRGBO(21, 58, 103, 1),
                fontSize: 21,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'The flagging feature is used to help users navigate back to question at a later date.',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _helpPopup(context);
                    },
                    child: const Text('Back'),
                  )
                ],
              )
            ]
        );
      },
    );
  }

}