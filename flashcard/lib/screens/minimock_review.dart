import 'package:flashcard_x/screens/minimock_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/screens/minimock_exam1.dart';


class MiniMock1Review extends StatefulWidget {
  const MiniMock1Review({super.key});

  @override
  State<MiniMock1Review> createState() => MiniMock1ReviewState();
}

class MiniMock1ReviewState extends State<MiniMock1Review> {
  List<bool> _isOpen = [false, false];
  @override
Widget build(BuildContext context) {
  return Scaffold(
    drawer: const DrawMain(),
    appBar: AppBar(
      elevation: 0,
      title: Align(
        alignment: const Alignment(-0.05, 0),
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
              child: const Text('Review'),
            ),
          ],
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: const Icon(Icons.menu),
        ),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
            ExpansionPanelList(
              elevation: 1,
              expandedHeaderPadding: EdgeInsets.all(4.0),
              expansionCallback: (i, isOpen) {
                setState(() {
                  _isOpen[i] = !_isOpen[i];
                });
              },
                children: [
                    ExpansionPanel(
                      canTapOnHeader: true,
                      backgroundColor: Colors.white,
                      headerBuilder: (context, isOpen) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Multiple Choice Questions (Question 1 - 20)',
                          style: TextStyle(color: Colors.black)),
                        );
                      },
                      body: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Content for multiple choice questions.',
                        style: TextStyle(color: Colors.black)),
                      ),
                      isExpanded: _isOpen[0],
                    ),
                    ExpansionPanel(
                      canTapOnHeader: true,
                      backgroundColor: Colors.white,
                      headerBuilder: (context, isOpen) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Ranking Questions (Question 21 - 50)',
                          style: TextStyle(color: Colors.black)),
                          
                        );
                      },
                      body: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Content for ranking questions.',
                        style: TextStyle(color: Colors.black)),
                      ),
                      isExpanded: _isOpen[1],
                    ),
                  ],
                ),
              ],
            ),   
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MiniMockFeedBack(),
          ),
        );
      }, label: Text('Complete Exam',  style: TextStyle(color: Colors.white, fontSize: 16))),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    /**bottomNavigationBar: Container(
      margin: const EdgeInsets.symmetric(horizontal: 650.0, vertical: 10.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MiniMockExam1(),
            ),
          );
        },
        
        child: const Text('Complete Exam'),
      ),
    ),**/
    
  );
}
}