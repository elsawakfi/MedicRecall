import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

Widget _buildCheckbox(ValueNotifier<bool> notifier, String text,
      {String? description, bool showInfo = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: Theme(
              data: ThemeData(
                unselectedWidgetColor: const Color.fromRGBO(21, 58, 103, 1),
                checkboxTheme: CheckboxThemeData(
                  side: const BorderSide(
                      color: Color.fromRGBO(21, 58, 103, 1), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: notifier,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      key: ValueKey(text),
                      value: value,
                      onChanged: (bool? newValue) {
                        notifier.value = newValue ?? false;
                      },
                      activeColor: const Color.fromRGBO(51, 178, 73, 1),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  notifier.value = !notifier.value;
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(21, 58, 103, 1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // if (showInfo && description != null)
                    //   _buildInfoIcon(
                    //       text, description), // Show only if required
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAlertDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    return AlertDialog(
      backgroundColor: const Color(0xFFE6EDF2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color.fromRGBO(21, 58, 103, 1),
          fontSize: 21,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: SizedBox(
        // height: 130,
        width: 300,
        child: SingleChildScrollView(child: content,),
      ),
      actions: actions,
    );
  }


void main() {
    List<String> daysOfTheWeek = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
  
  late Widget exclusionDialog;
   List<String> excludedDays = [];
    setUp((){
      excludedDays = [];

    Map<String, ValueNotifier<bool>> selectedDays = {
      for (var day in daysOfTheWeek) day: ValueNotifier<bool>(false),
    };

    exclusionDialog = MaterialApp(
    home: StatefulBuilder(builder: (context, setState){
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildAlertDialog(
              title: 'Select Days to Exclude from Study',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: selectedDays.keys.map((day) {
                  return _buildCheckbox(selectedDays[day]!, day,
                      showInfo: false); // ✅ Hide info icon
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Exam Date Dialog'),
                          content: Text('Show exam date dialog'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    excludedDays = selectedDays.entries
                        .where((entry) => entry.value.value)
                        .map((entry) => entry.key)
                        .toList();
                    
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      showDialog(context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Options Dialog'),
                          content: Text('Show options dialog'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
);;
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromRGBO(51, 178, 73, 1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    minimumSize: const Size(120, 45),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    ));
  });
  
  
  testWidgets("Exclusion Dialog has correct set up", (WidgetTester tester)async{
    await tester.pumpWidget(exclusionDialog);
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Tuesday'), findsOneWidget);
    expect(find.text('Wednesday'), findsOneWidget);
    expect(find.text('Thursday'), findsOneWidget);
    expect(find.text('Friday'), findsOneWidget);
    expect(find.text('Saturday'), findsOneWidget);
    expect(find.text('Sunday'), findsOneWidget);
  });

  testWidgets("Excluding one day", (WidgetTester tester) async {
    await tester.pumpWidget(exclusionDialog);
    await tester.pumpAndSettle();
    final checkboxFinder = find.text('Monday');

    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();
    expect(excludedDays.contains("Monday"), true);
  });

  testWidgets("Excluding no days",(WidgetTester tester)async {
    await tester.pumpWidget(exclusionDialog);
    await tester.pumpAndSettle();
     await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();
    expect(excludedDays.isEmpty, true);
  });

    testWidgets("Can exclude any day, excluding all days",(WidgetTester tester)async {
    await tester.pumpWidget(exclusionDialog);
    await tester.pumpAndSettle();
    final mondayFinder = find.text('Monday');
    final tuesdayFinder = find.text('Tuesday');
    final wednesdayFinder = find.text('Wednesday');
    final thursdayFinder = find.text('Thursday');
    final fridayFinder = find.text('Friday');
    final saturdayFinder = find.text('Saturday');
    final sundayFinder = find.text('Sunday');
    await tester.tap(mondayFinder);
    await tester.pumpAndSettle();
    await tester.tap(tuesdayFinder);
    await tester.pumpAndSettle();
    await tester.tap(wednesdayFinder);
    await tester.pumpAndSettle();
    await tester.tap(thursdayFinder);
    await tester.scrollUntilVisible(
           find.text('Friday'), 
           200.0, 
        );
    await tester.pumpAndSettle();
    await tester.tap(fridayFinder);
    await tester.pumpAndSettle();
    await tester.tap(saturdayFinder);
    await tester.pumpAndSettle();
    await tester.tap(sundayFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();
    expect(excludedDays.contains("Monday"),true);
    expect(excludedDays.contains("Tuesday"),true);
    expect(excludedDays.contains("Wednesday"),true);
    expect(excludedDays.contains("Thursday"),true);
    expect(excludedDays.contains("Friday"),true);
    expect(excludedDays.contains("Saturday"),true);
    expect(excludedDays.contains("Sunday"),true);
  });

  testWidgets("Pressing next triggers options dialog",(WidgetTester tester)async {
    await tester.pumpWidget(exclusionDialog);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Next"));
    await tester.pumpAndSettle();
    expect(find.text("Options Dialog"),findsOneWidget);
  });
  
  testWidgets("Pressing previous triggers exam date dialog",(WidgetTester tester)async {
    await tester.pumpWidget(exclusionDialog);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Previous"));
    await tester.pumpAndSettle();
    expect(find.text("Exam Date Dialog"),findsOneWidget);
  });







  }