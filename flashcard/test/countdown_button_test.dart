
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flashcard_x/widgets/countdown_button.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';

void main (){
  
  setUpAll(() async {
    // Ensure Firebase is initialized for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });
    testWidgets("Stop showing pop up",(WidgetTester tester) async {
    //const CustomFloatingButton button = CustomFloatingButton();
    final mockUser = MockUser(
      uid: "12345",
      email: "test@example.com",
      displayName: "Test User",
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CustomFloatingButton(),)
    );

    final button = tester.state<CustomFloatingButtonState>(
      find.byType(CustomFloatingButton),
    );

    button.setStopShowing(mockUser);

    await tester.pump();

    expect(button.stopShowing, false);

    button.getFirstStudyDay();

    
  });
}