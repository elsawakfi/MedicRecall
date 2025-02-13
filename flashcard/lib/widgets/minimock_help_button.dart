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
            title: Center(
              child:Text(
                'Mini-Mock Help Menu',
                style: const TextStyle(
                  color: Color.fromRGBO(21, 58, 103, 1),
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                ),
              )
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigationPopup(context);
                    },
                    child: const Text('Navigation',
                        style: TextStyle(fontSize: 16))
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _reviewPopup(context);
                  },
                  child: const Text('Flagging/Review System',
                      style: TextStyle(fontSize: 16))
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _rankingPopup(context);
                  },
                  child: const Text('Ranking Questions',
                      style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _multipleChoicePopup(context);
                  },
                  child: const Text('Multiple Choice Questions',
                      style: TextStyle(fontSize: 16)),
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

  void _navigationPopup(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: const Color(0xFFE6EDF2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            title: Text(
              'Navigation Help',
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
                  'Next moves you to the next question. \nBack moves you to the previous question. \nReview moves you to the review page.',
                  style: TextStyle(color: Colors.black, fontSize: 16),
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
                  'To flag/unflag a question click the flag button.\nQuestions that have been flagged can then be easily viewed on the review page.\nOn the review page click on either of the drop down menus to see a list of the questions.\nThe flagged questions represent the questions you previously flagged for revisit.\nBy clicking on a question you are taken back to that question.',
                  style: TextStyle(color: Colors.black, fontSize: 16),
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

  void _rankingPopup(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: const Color(0xFFE6EDF2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            title: Text(
              'Ranking Question Help',
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
                  'To move an option please hold down your left mouse button with the cursor above\nthe option\'s bar and drop it where you feel is correct to reorder the list',
                  style: TextStyle(color: Colors.black, fontSize: 16),
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

  void _multipleChoicePopup(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: const Color(0xFFE6EDF2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            title: Text(
              'Multiple Choice Question Help',
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
                  'Click on 3 of the possible options to fully answer the question.\nTo select a different option, unselect the option you believe\nis wrong (by clicking it again) and select another option.',
                  style: TextStyle(color: Colors.black, fontSize: 16),
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