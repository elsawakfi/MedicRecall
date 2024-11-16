//import 'package:flutter/cupertino.dart';

class Event {
  late final String title;
  final String? description;

  Event({
    required this.title,
    this.description,
    }); //@required?

  @override
  String toString() => title;
}
