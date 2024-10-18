import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/minimock_exam1.dart';
import 'package:flashcard_x/screens/minimock_exam2.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';


class MiniMockLanding extends StatefulWidget {
  const MiniMockLanding({Key? key}) : super(key: key);
  
  @override
  State<MiniMockLanding> createState() => MiniMockLandingState();
}

class MiniMockLandingState extends State<MiniMockLanding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawMain(),
        appBar: AppBar(
          // backgroundColor: Colors.blue,
            elevation: 0,
            title:  Align(
              alignment: const Alignment(-1.0,0),
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
                    child: const Text('Mini-Mocks',
                    textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),

            centerTitle: false,
            leading: Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const Icon(
                    Icons.menu,
                  ),
                ))),
      body: Container(
        //color:Color.fromARGB(255, 33, 100, 159), 
        padding: const EdgeInsets.all(16.0), // Add some padding
        child: Center( // Center the column vertically and horizontally
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              SizedBox(
                height: 50,
                width: 1000, // Set a fixed width for the button
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MiniMockExam1(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: const Icon(
                    Icons.lock_open_sharp,
                    size: 30,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Mini Mock 1',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 50,
                width: 1000, // Set a fixed width for the button
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MiniMockExam2(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: const Icon(
                    Icons.lock_clock_sharp,
                    size: 30,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Mini Mock 2',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
