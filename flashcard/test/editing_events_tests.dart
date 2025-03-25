
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flashcard_x/screens/study_session_manager.dart';
import 'package:flutter/material.dart';


//Embedded form gets triggered if i try to import event.dart so decided to just redefine the class
class Event {
  late final String title;
  final String? description;
  final Color color;

  Event({
    required this.title,
    this.description,
    required this.color,
    }); //@required?

  @override
  String toString() => title;
}

void main(){

  late Map<DateTime?, List<Event>> selectedEvents = {};
   List<String> updatedEvents = [];

  // DateTime today = DateTime.now();
  late Widget addEvent; 
  late String newTitle = "Cutsom Event";
  DateTime selectedDay = DateTime(2020, 1, 1);
  
  final TextEditingController _eventController = TextEditingController();
   Color _getEventColor(String title) {
    List<String> flashcards = [
      "Team working",
      "Effective communication",
      "Acting within your remit",
      "Patient focus",
      "Commitment to professionalism",
      "Coping with pressure",
      "Confidentiality"
    ];
    if (title == "Test Day") return const Color.fromARGB(255, 255, 89, 94);
    if (title.contains("Mini Mock")) return StudySessionManager.kMiniMockColor;
    if (title.contains("Full-sized Mock")) return StudySessionManager.kFullMockColor;
    if (title.contains("Official MSRA Practice Paper")) return StudySessionManager.kOfficialPaperColor;
    if (title.contains("Official SJT Practice Paper")) return StudySessionManager.kSJTPaperColor;

    for (String flashcard in flashcards) {
      if (title.contains(flashcard)) return StudySessionManager.kFlashcardColor;
    }

    return Color.fromARGB(200, 0, 0, 100);
  }
   Future<void> addSingleEvent(
      DateTime date, String eventTitle) async {
    date = DateTime(date.year, date.month, date.day);

    //The delete single event function updates the UI in real time so I just copied the structure of that function
    Event newEvent =
        Event(title: eventTitle, color: _getEventColor(eventTitle));

   
    selectedEvents[date] = [];
    
    selectedEvents[date]?.add(newEvent);
   

    updatedEvents =
        selectedEvents[date]?.map((e) => e.title).toList() ?? [];

  }

  Future<void> deleteSingleEvent(
      DateTime date, String eventTitle,) async {

    date = DateTime(date.year, date.month, date.day);

     if (!selectedEvents.containsKey(date)) {
      print("No events found for date: ${date.toString().split(' ')[0]}");
      return;
    }

    selectedEvents[date]?.removeWhere((event) => event.title == eventTitle);

    if (selectedEvents[date]?.isEmpty ?? false) {
      selectedEvents.remove(date);
    }
  }

  setUp((){
    selectedEvents = {};
    updatedEvents = [];
    //DateTime testDay = DateTime.now().add(const Duration(days: 50));
    //addSingleEvent(testDay,"Test Day");
    addEvent = MaterialApp(
      home: StatefulBuilder(builder: (context, setState){
        return AlertDialog(
        title: const Text("New Event"),
        content: TextFormField(controller: _eventController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(243, 90, 90, 1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45), // Sets minimum width and height
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            key: const ValueKey("Add"),
            onPressed: () async {
              // print("event controller bs ${_eventController.text}\n");
              // if (_eventController.text.isNotEmpty) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color.fromRGBO(51, 178, 73, 1),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Adding event...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(21, 58, 103, 1),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );

                
                await addSingleEvent(
                      selectedDay, newTitle);
                  // Close the loading dialog
                  Navigator.of(context).pop();
                  // Close the add event dialog
                  
                 
              
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45), // Sets minimum width and height
            ),
            child: const Text(
              "Add Event",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
   
  }));  
  });

  testWidgets("Adding an event",(WidgetTester tester)async{
    selectedDay = DateTime.now();
    await tester.pumpWidget(addEvent);
    await tester.pumpAndSettle();

    final addFinder = find.byKey(const ValueKey("Add"));
    await tester.tap(addFinder);
    await tester.pumpAndSettle();

    //expect(find.text("Adding event..."),findsOneWidget);

    print(selectedEvents);
    print(updatedEvents);
    expect(updatedEvents.length == 1,true);
    expect(updatedEvents.contains(newTitle),true);
    Event newEvent = Event(title: newTitle, color: _getEventColor(newTitle));
    print(" From calendar : ${selectedEvents[selectedDay]}");
    print("Newly defined event $newEvent");

    Event event = (selectedEvents[selectedDay]?.isNotEmpty ?? false) 
    ? selectedEvents[selectedDay]!.first 
    : Event(title: "Wrong", color: _getEventColor(newTitle));; 
    expect(event == (newEvent),true);



  });



}