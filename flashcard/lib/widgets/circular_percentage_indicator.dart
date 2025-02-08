import 'package:flashcard_x/main.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/minimock_scoring.dart';

class ScoreIndicator extends StatelessWidget{
  final String title;
  final int totalScore;
  final double percentageScore;

  const ScoreIndicator({
    Key? key,
    required this.title,
    required this.totalScore,
    required this.percentageScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container( 
          width:160,
          height:160,
          // child:Stack(
            // alignment: Alignment.center,
            child: CircularProgressIndicator(
                value: percentageScore,
                strokeWidth: 12,
                backgroundColor: Colors.green, 
                // progressColor: Colors.red,
                // circularStrokeCap: CircularStrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black,
                ),
            ),),
      ],
            // Text(
            //   "${percentageScore.toStringAsFixed(2)}%",
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            
            // ),
          );
        
        
      
    }
  }