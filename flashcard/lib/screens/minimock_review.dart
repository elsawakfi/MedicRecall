import 'package:flutter/material.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flashcard_x/screens/minimock_exam1.dart';


class MiniMock1Review extends StatefulWidget {
  const MiniMock1Review({super.key});

  @override
  State<MiniMock1Review> createState() => MiniMock1ReviewState();
}

class MiniMock1ReviewState extends State<MiniMock1Review> {
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
            GridView.count(crossAxisCount: 5,
            children: List.generate(10, (index) {
          return Center(
            child: ElevatedButton.icon(
            //should lead to the appropraite question on the minimock ideally
            onPressed: () {
              Navigator.of(context).push(
              MaterialPageRoute(
             builder: (context) => const MiniMockExam1(),
                ),
              );
            },
            label:  Text(
                    'Question $index',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),)
            );}
            )
            
        )])
        )
    );
  }
}

