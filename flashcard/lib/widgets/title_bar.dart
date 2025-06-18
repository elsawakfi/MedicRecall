
import 'package:flutter/material.dart';
import '../widgets/countdown_button.dart';

class ScreenTitleBar extends StatelessWidget {
  final String title;
  const ScreenTitleBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: Colors.blue[300],
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.black),
            ),
          ),
          const CustomFloatingButton(),
        ],
      ),
     
    );
  }
}