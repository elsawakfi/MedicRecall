import 'package:flutter/material.dart';
// import 'package:flashcard_x/main.dart';

class Notes extends StatelessWidget {
  const Notes({Key? key}) : super(key: key);

  void homepage(BuildContext context) {
    // this method returns the user to the main page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Notes"),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: (){homepage(context);},
              tooltip: 'Return to homepage',
            ),
          ],
        ),
        body: Column(
          children: const <Widget>[
            SizedBox(height: 30),
            ElevatedButton(
                style: null,
                onPressed: null,
                child: Text("back to home page"))
          ],
        ),
      ),
    );
  }
}
