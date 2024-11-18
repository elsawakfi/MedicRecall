import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';

class PageLayout extends StatelessWidget {
  final String titleText;  // Variable for the title text
  final Widget body;       // Body of the screen that can change on different screens

  const PageLayout({
    super.key,
    required this.titleText,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawMain(),
      appBar: AppBar(
        elevation: 0,
        title: Align(
          alignment: const Alignment(-1.0, 0),
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
                child: Text(titleText,  // Use the variable for the title text
                textAlign: TextAlign.left
                )
              ),
            ],
          ),
        ),
        centerTitle: false,
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu),
          ),
        ),
      ),
      body: body,  // Pass the body of the screen here
    );
  }
}
