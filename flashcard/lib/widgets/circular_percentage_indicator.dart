import 'package:flashcard_x/main.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/minimock_scoring.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';


  class ScoreIndicator extends StatelessWidget {
  final String title;
  final int totalScore;
  final double percentageScore;
  final double radius;
  final double lineWidth;
  final Color progressColor;
  final Color backgroundColor;
  // final circularPercentIndicator;

  const ScoreIndicator({
    Key? key,
    required this.title,
    required this.totalScore,
    required this.percentageScore,
    required this.radius,
    required this.lineWidth,
    required this.progressColor,
    required this.backgroundColor,
    // required this.circularPercentIndicator,
    // required this.circularPercentIndicator(),
    
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
        CircularPercentIndicator(
          radius: radius,
          lineWidth: lineWidth,
          percent: percentageScore,
          // circularPercentIndicator: circularPercentIndicator,
          center: Text(
            "${percentageScore.toStringAsFixed(2)}%",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          progressColor: progressColor,
          backgroundColor: backgroundColor,
          // circularStrokeCap: circularStrokeCap,
        ),
        SizedBox(height: 10),
        Text(
          'Score: $totalScore',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
  
  CircularPercentIndicator({required double radius, required double lineWidth, required double percent, required Text center, required Color progressColor, required Color backgroundColor}) {}
}