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
          // backgroundColor: Colors.blue,
            elevation: 0,
            title:  Align(
              alignment: const Alignment(-0.05,0),
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
                    child: const Text('Review',
                    
                    ),
                  ),
                ],
              ),
            ),

            centerTitle: true,
            leading: Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const Icon(
                    Icons.menu,
                  ),
                ),
                ),
                
                ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /**Expanded(
              child: GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 1.0,
                children: List.generate(10, (index) {
                  return Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MiniMockExam1(),
                          ),
                        );
                      },
                      label: Text(
                        'Question ${index + 1}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          Expanded(
              child: GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 1.0,
                children: List.generate(10, (index) {
                  return Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MiniMockExam1(),
                          ),
                        );
                      },
                      label: Text(
                        'Question ${index + 1}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),**/
            ExpansionPanelList(
  expansionCallback: (i, isOpen) {
    setState(() {
      _isOpen[i] = !_isOpen[i];
    });
  },
  children: [
    ExpansionPanel(
      canTapOnHeader: true,
      headerBuilder: (context, isOpen) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Multiple Choice Questions (Question 1 - 20)'),
        );
      },
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Content for multiple choice questions.'),
      ),
      isExpanded: _isOpen[0],
    ),
    ExpansionPanel(
      canTapOnHeader: true,
      headerBuilder: (context, isOpen) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Ranking Questions (Question 21 - 50)'),
        );
      },
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Content for ranking questions.'),
      ),
      isExpanded: _isOpen[1],
    ),
  ],
)
],
        ),
      ),
      bottomNavigationBar: Container(
          child: ElevatedButton(
            onPressed:() {Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MiniMockExam1(),
                ),
              );
            },
          child: const Text('Complete Exam')),

    ));
  }
}