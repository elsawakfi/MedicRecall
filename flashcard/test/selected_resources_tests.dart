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
void main(){
  
  late Widget optionsDialog; 
  
  //Making the selected resources variable global but reseting it after every test, makes testing easier
  //no because, the tests run asynchronously so this will not work 
  List<String> selectedResources = [];


  //Set up is run before every test 
  setUp((){
  final checkbox1 = ValueNotifier<bool>(false);
  final checkbox2 = ValueNotifier<bool>(false);
  final checkbox3 = ValueNotifier<bool>(false);
  final checkbox4 = ValueNotifier<bool>(false);
  final checkbox5 = ValueNotifier<bool>(false);
     selectedResources = [];
  optionsDialog = MaterialApp(
    home: StatefulBuilder(builder: (context, setState){
      return  _buildAlertDialog(
          title: 'Which resources would you like to use?',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCheckbox(
                checkbox1,
                'Official MSRA Practice Paper',
                description:
                    'The official past paper is available on the Health Education England website. '
                    'It contains 22 Professional Dilemma questions with realistic scenarios and reliable rationales created '
                    'by the same people who write the questions for the MSRA, making it a very valuable resource.\n\n'
                    'You will be prompted to specify your preferred number of practice attempts upon selection.',
                showInfo: true,
              ),
              _buildCheckbox(
                checkbox2,
                'Full-sized Mock Exam',
                description:
                    'Our full-sized mock exam has been designed to mimic the exact conditions you will have on exam day, '
                    'helping you optimize timings while exposing you to different professional scenarios. It includes 50 questions that '
                    'have been carefully created to align with official rationales and GMC guidelines.\n\n'
                    'You will be prompted to specify your preferred number of practice attempts upon selection.',
                showInfo: true,
              ),
              _buildCheckbox(
                checkbox3,
                'Mini-mocks',
                description:
                    'We have two mini-mocks available on the platform, which each contain 25 reliable questions. '
                    'They have been created to help track your progress, fine-tune exam timings and increase your exposure to different professional scenarios.',
                showInfo: true,
              ),
              _buildCheckbox(
                checkbox4,
                'Flashcard Decks',
                description:
                    'Our pre-made flashcard decks contain high-yield principles derived from GMC guidelines and official rationales. '
                    'This resource uses our unique, evidence-based algorithms to help you harness the power of spaced repetition and active recall!',
                showInfo: true,
              ),
              _buildCheckbox(
                checkbox5,
                'Official SJT Practice Paper',
                description:
                    'This is a practice paper released by the UKFPO as a resource for doctors preparing for the FY2 Situational Judgement Test, '
                    'which is part of the application process for stand-alone FY2 training. Be aware that this paper only includes 18 RATING questions '
                    '(not a format of questions that appears in the MSRA). '
                    'Nevertheless, increasing your exposure to questions and rationales created by the UKFPO is helpful when preparing for the Professional Dilemmas Paper.',
                showInfo: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              key: const ValueKey('previous'),
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Exclusion Dialog'),
                          content: Text('Exclusion shown to user'),
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
                foregroundColor: const Color.fromRGBO(73, 148, 236, 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                minimumSize: const Size(120, 45),
              ),
              child: const Text(
                'Previous',
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              key: const ValueKey('submitButton1'),
              onPressed: () async {
                // Check which resources were selected
                
                if (checkbox1.value) selectedResources.add('Official MSRA Practice Paper');
                if (checkbox2.value) selectedResources.add('Full-sized Mock Exam');
                if (checkbox3.value) selectedResources.add('Mini-mocks');
                if (checkbox4.value) selectedResources.add('Flashcards');
                if (checkbox5.value) selectedResources.add('Official SJT Practice Paper');

               
                if (selectedResources == [] || selectedResources.isEmpty || selectedResources.length == 0) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Please select at least one resource.'),
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
                    return ; // Stop execution if no resources are selected
                }
                
                // Close current dialog
                Navigator.of(context).pop();
                // Check if any of the resources requiring repetitions are selected
                bool showRepetitionDialog = checkbox1.value || checkbox2.value;
                // If no repetition dialog is needed, show the completion dialog
                if (showRepetitionDialog) {
                 
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Repetition Dialog'),
                          content: Text('The repetition dialog is shown to the user'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );});
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Completion Dialog'),
                          content: Text('The Completion dialog is shown to the user'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );});
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromRGBO(51, 178, 73, 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
    }));});

    testWidgets('Options dialog displays the correct resources', (WidgetTester tester) async {
    await tester.pumpWidget(optionsDialog);
    await tester.pumpAndSettle();
    expect(find.text('Official MSRA Practice Paper'), findsOneWidget);
    // print("Found MSRA\n");
    expect(find.text('Full-sized Mock Exam'), findsOneWidget);
    // print("Found Full Mock\n");
    expect(find.text('Mini-mocks'), findsOneWidget);
    // print("Found Mini Mocks\n");
    expect(find.text('Flashcard Decks'), findsOneWidget);
    // print("Found Flahscards\n");
    expect(find.text('Official SJT Practice Paper'), findsOneWidget);
    // print("Found SJT\n");
  });

    testWidgets('Ticking checkbox updates selected resources', (WidgetTester tester) async{
      await tester.pumpWidget(optionsDialog);
      await tester.pumpAndSettle();
      final checkboxFinder = find.byKey(const ValueKey('Official MSRA Practice Paper'));
      expect((tester.widget<Checkbox>(checkboxFinder)).value, false);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();
      expect((tester.widget<Checkbox>(checkboxFinder)).value, true);
      final submitButtonFinder = find.byKey(const ValueKey('submitButton1'));
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();
      expect(selectedResources.contains("Official MSRA Practice Paper"),true);
      expect(selectedResources.length, 1);
      
    });

    testWidgets("Selecting no resources returns an error ", (WidgetTester tester) async{
      await tester.pumpWidget(optionsDialog);
      final submitButtonFinder = find.byKey(const ValueKey('submitButton1'));
      await tester.tap(submitButtonFinder);
      await tester.pump();
      expect(find.text('Please select at least one resource.'),findsOneWidget);
    });

    testWidgets("Can unselect checkboxes ",(WidgetTester tester) async{
       await tester.pumpWidget(optionsDialog);
       final msraFinder = find.byKey(const ValueKey('Official MSRA Practice Paper'));
       final mockFinder = find.byKey(const ValueKey('Full-sized Mock Exam'));
       final miniFinder = find.byKey(const ValueKey('Mini-mocks'));
       final flashcardFinder = find.byKey(const ValueKey('Flashcard Decks'));
       final sjtFinder = find.byKey(const ValueKey('Official SJT Practice Paper'));


       //Selecting all options
       await tester.tap(msraFinder);
       await tester.pumpAndSettle();

       await tester.tap(mockFinder);
       await tester.pumpAndSettle();

       await tester.tap(miniFinder);
       await tester.pumpAndSettle();

       await tester.scrollUntilVisible(
           find.text('Official SJT Practice Paper'), 
           200.0, 
        );

       await tester.tap(flashcardFinder);
       await tester.pumpAndSettle();

       await tester.tap(sjtFinder);
       await tester.pumpAndSettle();

       //Unselecting two options
       await tester.tap(mockFinder);
       await tester.pumpAndSettle();

       await tester.tap(sjtFinder);
       await tester.pumpAndSettle();

      final submitButtonFinder = find.byKey(const ValueKey('submitButton1'));
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();
      expect(selectedResources.contains("Official MSRA Practice Paper"),true);
      expect(selectedResources.contains("Full-sized Mock Exam"),false);
      expect(selectedResources.contains("Mini-mocks"),true);
      expect(selectedResources.contains("Flashcards"),true);
      expect(selectedResources.contains("Official SJT Practice Paper"),false);
      expect(selectedResources.length == 3,true );
    });
    
    testWidgets("Selecting MSRA triggers repetition dialog",(WidgetTester tester) async{
      await tester.pumpWidget(optionsDialog);
      await tester.pumpAndSettle();
      final checkboxFinder = find.byKey(const ValueKey('Official MSRA Practice Paper'));
      expect((tester.widget<Checkbox>(checkboxFinder)).value, false);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();
      expect((tester.widget<Checkbox>(checkboxFinder)).value, true);
      final submitButtonFinder = find.byKey(const ValueKey('submitButton1'));
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text("Repetition Dialog"),findsOneWidget);
    });

    testWidgets("Selecting Full-sized mock triggers repetition dialog",(WidgetTester tester) async{
      await tester.pumpWidget(optionsDialog);
      await tester.pumpAndSettle();
      final checkboxFinder = find.byKey(const ValueKey('Full-sized Mock Exam'));
      expect((tester.widget<Checkbox>(checkboxFinder)).value, false);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();
      expect((tester.widget<Checkbox>(checkboxFinder)).value, true);
      final submitButtonFinder = find.byKey(const ValueKey('submitButton1'));
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text("Repetition Dialog"),findsOneWidget);
    });

    testWidgets("Selecting neither MSRA or Full Mock triggers completion dialog",(WidgetTester tester)async{
       await tester.pumpWidget(optionsDialog);
       final miniFinder = find.byKey(const ValueKey('Mini-mocks'));
       final flashcardFinder = find.byKey(const ValueKey('Flashcard Decks'));
       final sjtFinder = find.byKey(const ValueKey('Official SJT Practice Paper'));

       await tester.tap(miniFinder);
       await tester.pumpAndSettle();

       await tester.scrollUntilVisible(
           find.text('Official SJT Practice Paper'), 
           200.0, 
        );

       await tester.tap(flashcardFinder);
       await tester.pumpAndSettle();

       await tester.tap(sjtFinder);
       await tester.pumpAndSettle();


      final submitButtonFinder = find.byKey(const ValueKey('submitButton1'));
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text("Completion Dialog"),findsOneWidget);
    });
    
    testWidgets("Selecting previous takes user to Exclusion Dialog",(WidgetTester tester) async{
      await tester.pumpWidget(optionsDialog);
      expect(find.text("Previous"),findsOneWidget);
      final previousFinder = find.byKey(const ValueKey('previous'));
      await tester.tap(previousFinder);
      await tester.pumpAndSettle();

      expect(find.text("Exclusion Dialog"),findsOneWidget);

    });
    }

    