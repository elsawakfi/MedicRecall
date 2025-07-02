import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';


  class ScoreIndicator extends StatelessWidget {
  final String title;
  final totalScore;
  final double percentageScore;
  final double radius;
  final double lineWidth;
  final Color progressColor;
  final Color backgroundColor;
  final Color textColor;

  const ScoreIndicator({
    super.key,
    required this.title,
    required this.totalScore,
    required this.percentageScore,
    required this.radius,
    required this.lineWidth,
    required this.progressColor,
    required this.backgroundColor, 
    required this.textColor,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        SizedBox(height: 10),
        CircularPercentIndicator(
          radius: radius,
          lineWidth: lineWidth,
          percent: 1 - (percentageScore/100),
          center: Text(
            "${percentageScore.toStringAsFixed(2)}%",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          ),
          progressColor: progressColor,
          backgroundColor: backgroundColor,
          //textColor: textColor,
        ),
        SizedBox(height: 10),
        Text(
          'Score: $totalScore',
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ],
    );
  }
  }