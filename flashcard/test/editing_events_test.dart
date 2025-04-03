
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
  late Widget editEvent; 
  late String newTitle = "Cutsom Event";
  late String editedTitle = "Edited Event";
  DateTime selectedDay = DateTime.now();
  DateTime editedDay = DateTime(selectedDay.year,selectedDay.month,selectedDay.day+3,0,0,0,0);
  
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
  setUp((){
    selectedEvents = {};
    updatedEvents = [];
    newTitle = newTitle;
    selectedDay = selectedDay;
  
  final TextEditingController _eventController = TextEditingController();
   
   Future<void> addSingleEvent(
      DateTime date, String eventTitle) async {
     
    //The delete single event function updates the UI in real time so I just copied the structure of that function
    Event newEvent =
        Event(title: eventTitle, color: _getEventColor(eventTitle));

   
    selectedEvents[DateTime(date.year, date.month, date.day,0,0,0,0)] = [];
    
    selectedEvents[DateTime(date.year, date.month, date.day,0,0,0,0)]?.add(newEvent);
   

    updatedEvents =
        selectedEvents[DateTime(date.year, date.month, date.day,0,0,0,0)]?.map((e) => e.title).toList() ?? [];

  }

  Future<void> deleteSingleEvent(
      DateTime date, String eventTitle) async {
     if (!selectedEvents.containsKey(date)) {
      print("No events found for date: ${date.toString().split(' ')[0]}");
      return;
    }
    selectedEvents[date]!.removeLast();
    //selectedEvents[date]!.removeWhere((event) => event.title == eventTitle);
    // selectedEvents[date]!.remove();
    if (selectedEvents[date]?.isEmpty ?? false) {
      selectedEvents.remove(date);
    }
  }
  
  Future<void> updateOneEvent(
      Event oldEvent, String newTitle_, DateTime newDate) async {
    DateTime normalizedOldDate =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    DateTime normalizedNewDate =
        DateTime(newDate.year, newDate.month, newDate.day);
    await deleteSingleEvent(normalizedOldDate, oldEvent.title);
    await addSingleEvent(normalizedNewDate, newTitle_);
    selectedDay = normalizedNewDate;
  }
  editEvent = MaterialApp(
    home: StatefulBuilder(builder:(context,setState){
      return AlertDialog(backgroundColor: const Color(0xFFE6EDF2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        title: const Text(
          "Edit Event",
          style: TextStyle(
            color: Color.fromRGBO(21, 58, 103, 1),
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editable Event Title
            TextFormField(
              controller: _eventController,
              style: const TextStyle(
                color: Color.fromRGBO(21, 58, 103, 1),
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                labelText: "Event Title",
                labelStyle: TextStyle(
                  color: Color.fromRGBO(21, 58, 103, 1),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Row with "Date:" label and button displaying the selected date
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "Date:",
                  style: TextStyle(
                    color: Color.fromRGBO(21, 58, 103, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                StatefulBuilder(
                  builder: (context, setDialogState) => ElevatedButton(
                    onPressed: () async {
                      // final DateTime? pickedDate = await showDatePicker(
                      //   context: context,
                      //   initialDate: selectedDay,
                      //   firstDate: DateTime(2000),
                      //   lastDate: DateTime(2100),
                      //   locale: const Locale('en', 'GB'),
                      // );
                      // if (pickedDate != null && pickedDate != selectedDay) {
                      //   setDialogState(() {
                      //     editedDay = pickedDate;
                      //   });
                      // }
                    },
                    key: const ValueKey("Date Picker"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(21, 58, 103, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      '$editedDay',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromRGBO(243, 90, 90, 1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45),
            ),
            child: const Text("Cancel", style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () async {
              // if (_eventController.text.isNotEmpty) {
                // Show loading indicator while saving
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
                            'Updating event...',
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

               
                
                Event toEdit = selectedEvents[selectedDay]!.first;
                    // For other events, use updateOneEvent
                await updateOneEvent(
                        toEdit, editedTitle, editedDay);
                  

                  // Close the loading dialog
                  Navigator.of(context).pop();
                  // Close the event edit dialog
                  Navigator.of(context).pop();

                  // Update the state
                  
                
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromRGBO(21, 58, 103, 1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 45),
              
            ),
            key: const ValueKey("Save"),
            child: const Text("Save", style: TextStyle(fontSize: 16)),
          ),
        ],
      );}));

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
          TextButton(
            key: const ValueKey("Delete"),
            onPressed: () async {
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
                            'Deleting event...',
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

                
                await deleteSingleEvent(
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
              "Delete Event",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
   
  })); 
 
  });

  testWidgets("Adding an event to today's date",(WidgetTester tester)async{
    DateTime today = DateTime.now();
    selectedDay = DateTime(today.year,today.month,today.day,0,0,0,0);
    await tester.pumpWidget(addEvent);
    await tester.pumpAndSettle();
    final addFinder = find.byKey(const ValueKey("Add"));
    await tester.tap(addFinder);
    await tester.pumpAndSettle();
    expect(selectedEvents.toString().contains(newTitle),true);
    expect(selectedEvents.toString().contains("$selectedDay"),true);
    expect(selectedEvents[selectedDay]?.isNotEmpty,true);
    expect(updatedEvents.length == 1,true);
    expect(updatedEvents.contains(newTitle),true);
  });

  testWidgets("Adding and then deleting an event returns an empty selectedEvents",(WidgetTester tester)async{
        //Selected Day will still be the same after the previous test
        //Adding an event manually so we can delete it 
        await tester.pumpWidget(addEvent);
        await tester.pumpAndSettle();
        selectedEvents[selectedDay] = [];
        selectedEvents[selectedDay]!.add(
        Event(title: "Delete This", color: _getEventColor("Delete This")));

        final deleteFinder = find.byKey(const ValueKey("Delete"));
        expect(selectedEvents.isEmpty,false);
        await tester.tap(deleteFinder);
        await tester.pumpAndSettle();
        
        expect(selectedEvents.isEmpty,true);
        expect(updatedEvents.isEmpty,true);
    });

  testWidgets("Editing one event from today to the future",(WidgetTester tester) async {
        await tester.pumpWidget(editEvent);
        await tester.pumpAndSettle();
        selectedEvents[selectedDay] = [];
        selectedEvents[selectedDay]!.add(
        Event(title: "Edit This", color: _getEventColor("Edit This")));      
        editedDay = DateTime(editedDay.year,editedDay.month,editedDay.day+3);
        
        final saveFinder = find.byKey(const ValueKey("Save"));
        await tester.scrollUntilVisible(
           find.text('Save'), 
           200.0, 
        );
        expect(selectedEvents.isEmpty,false);
        expect(selectedEvents[selectedDay] != null,true);
        expect(selectedEvents.toString().contains("$editedDay"),false);
        expect(selectedEvents.toString().contains("Edit This"),true);
        await tester.tap(saveFinder);
        await tester.pumpAndSettle();
        expect(selectedEvents.toString().contains(editedTitle),true);
        expect(selectedEvents.toString().contains("$editedDay"),true);
        expect(selectedEvents.toString().contains("Edit This"),false);
    });

    testWidgets("Event colour stays the same after editing it",(WidgetTester tester) async{
        //The test above simulated the user changing the name and date of an event, this one will test
        //Only the user changing the date
        await tester.pumpWidget(editEvent);
        await tester.pumpAndSettle();
        selectedEvents[selectedDay] = [];
        selectedEvents[selectedDay]!.add(
        Event(title: "Team working", color: _getEventColor("Team working"))); 
        editedTitle = "Team working";
        editedDay = editedDay.add(Duration(days: 5));
        final saveFinder = find.byKey(const ValueKey("Save"));
        await tester.scrollUntilVisible(
           find.text('Save'), 
           200.0, 
        );  
        Event before = selectedEvents[selectedDay]!.first;
        await tester.tap(saveFinder);
        await tester.pumpAndSettle();
        Event after = selectedEvents[editedDay]!.first;     
        expect(before.color == after.color,true);
    });

    testWidgets("Event colour changes after editing name as well as date",(WidgetTester tester) async{
        //This is the same as the above test, except that we are changing from a flashcard event 
        //To a custom event, as the name is being changes as well
        await tester.pumpWidget(editEvent);
        await tester.pumpAndSettle();
        selectedEvents[selectedDay] = [];
        selectedEvents[selectedDay]!.add(
        Event(title: "Team working", color: _getEventColor("Team working"))); 
        editedTitle = "Individual Disfunctioning";
        editedDay = editedDay.add(Duration(days: 5));
        final saveFinder = find.byKey(const ValueKey("Save"));
        await tester.scrollUntilVisible(
           find.text('Save'), 
           200.0, 
        );  
        Event before = selectedEvents[selectedDay]!.first;
        await tester.tap(saveFinder);
        await tester.pumpAndSettle();
        Event after = selectedEvents[editedDay]!.first;     
        expect(before.color == after.color,false);
        expect(after.color == Color.fromARGB(200, 0, 0, 100),true );
    });




}