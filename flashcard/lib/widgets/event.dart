//import 'package:flutter/cupertino.dart';

class Event {
  late final String title;

  Event({required this.title}); //@required?

  @override
  String toString() => title;
}
