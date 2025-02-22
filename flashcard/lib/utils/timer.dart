import 'dart:async';
import 'package:flutter/material.dart';

class TimerController {
  late int _startTime; // in seconds
  late Timer _timer;
  final void Function(String) onTimeUpdate; // Callback for time updates
  final VoidCallback onTimerComplete; // Callback when timer is complete

  TimerController({
    required int startTime,
    required this.onTimeUpdate,
    required this.onTimerComplete,
  }) {
    _startTime = startTime;
  }
  
  void startTimer(){
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_startTime == 0){
        timer.cancel();
        onTimerComplete();
      }else{
        _startTime--;
        onTimeUpdate(_formatTime(_startTime));
      }
    });
  }

  String _formatTime(int seconds){
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void stopTimer(){
    _timer.cancel();
  }
}