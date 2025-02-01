import 'package:flashcard_x/questions/score_page.dart';
import 'package:flashcard_x/screens/minimock_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/minimock_exam.dart';
class MiniMock1Scoring extends StatefulWidget {
  final String title;
  final String questionDirectory;
  final String answerDirectory;
  
  const MiniMock1Scoring({
    super.key,
    required this.title,
    required this.questionDirectory,
    required this.answerDirectory,

  });
  @override
  State<MiniMock1Scoring> createState() => MiniMock1ScoringState();
}
class MiniMock1ScoringState extends State<MiniMock1Scoring> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.blue,
            elevation: 0,
            title:  Align(
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
                    child: const Text('Mini-Mock 1: Scoring',
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
                    ),
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () => MiniMockFeedBack(title: widget.title, questionDirectory: widget.questionDirectory, answerDirectory: widget.answerDirectory), // Call the endExam function
                        child: const Text('Complete Scoring'),
                      ),
                    ],
                  ),
                ),
              );
            }
          }







//             centerTitle: true,
//             leading: Builder(
//                 builder: (context) => GestureDetector(
//                   onTap: () => Scaffold.of(context).openDrawer(),
//                   child: const Icon(
//                     Icons.menu,
//                   ),
//                 ),
//                 ),
//                 ),
//         body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//           ElevatedButton(
//             onPressed: () => completeScoring(context),
//             child: const Text('Complete Scoring'),
//             ),],
//           ),
//         ),
//     );
//   }

//   void completeScoring(BuildContext context) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => endExam(context),
//         child:)),
//     );
//   }
// }






  // void completeScoring(BuildContext context) {

  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => MiniMock1Scoring()),
  //   );
  //     style: ElevatedButton.styleFrom(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(5),
  //       ),
  //     );
  //     child: Text('Review Answers', style: TextStyle(color:Colors.white));
  // }
  // }
