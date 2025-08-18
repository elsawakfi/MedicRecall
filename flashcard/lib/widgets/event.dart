//import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class Event {
  late final String title;
  final String? description;
  final Color color;
  bool complete;

  Event({
    required this.title,
    this.description,
    required this.color,
    this.complete = false
    }); //@required?

  @override
  String toString() => title;
}
