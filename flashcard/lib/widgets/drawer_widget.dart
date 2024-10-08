import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/faq.dart';
import 'package:flashcard_x/screens/feedback_screen.dart';
import 'package:flashcard_x/screens/landing_screen.dart';
import 'package:flashcard_x/screens/mark_scheme.dart';
import 'package:flashcard_x/screens/settings_screen.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/utils/authentication.dart';
import 'package:flashcard_x/utils/page_transition.dart';
import 'package:flutter/material.dart';

import '../screens/calendar_screen.dart';
import '../screens/flashcard_editor_screen.dart';

class DrawMain extends StatelessWidget {
  const DrawMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        const SizedBox(width: 100, height: 32),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "MedicRecall",
                    textAlign: TextAlign.center,
                    //style: TextStyle(
                      //fontSize: 2,
                    //),
                  ),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: FittedBox(
                      child: Image(
                        image: AssetImage("assets/newlogo.png"),
                      ),
                    ),
                  )
                ]),
            onTap: () => Navigator.push(
                  context,
                  MoveRightRoute(page: const Landing()),
                )
          )
          ),
        ListTile(
            key: const ValueKey('Flashcards'),
            leading: const Icon(Icons.amp_stories),
            title: const Text('Flashcard Tutor'),
            onTap: () => Navigator.push(
                  context,
                  MoveNoneRoute(
                      page: const HomePage(
                    title: 'Home',
                  )),
                )),
        ListTile(
            key: const ValueKey('Mark Scheme'),
            leading: const Icon(Icons.check),
            title: const Text('Mark Scheme'),
            onTap: () => Navigator.push(
                  context,
                  MoveRightRoute(page: const UMS()),
                )),
        ListTile(
            key: const ValueKey('Flashcard Editor'),
            leading: const Icon(Icons.rate_review),
            title: const Text('Create New Flashcards'),

            onTap: () {
              Navigator.push(
                context,
                MoveRightRoute(page: const FlashcardEditor()),
              );
            }),
        ListTile(
            key: const ValueKey('Calendar'),
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text('Revision Calendar'),
            onTap: () => Navigator.push(
                  // ListTile(
                  //   leading: Icon(Icons.supervised_user_circle_rounded),
                  //   title: Text('Study'),
                  //   onTap: study,
                  // ),
                  // ListTile(
                  //   key: const ValueKey('Questions'),
                  //   leading: Icon(Icons.quiz_rounded),
                  //   title: Text('Questions'),
                  //   onTap: () => Navigator.push(
                  //     context,
                  //     MoveRightRoute(page: Questions()),
                  //   ),
                  // ),

                  context,
                  MaterialPageRoute(builder: (context) => const Calendar()),
                )),
        /*
        ListTile(
           leading: Icon(Icons.supervised_user_circle_rounded),
           title: Text('Study'),
           onTap: study,
         ),

         */
        // ListTile(
        //   key: const ValueKey('Questions'),
        //   leading: Icon(Icons.quiz_rounded),
        //   title: Text('Questions'),
        //   onTap: () => Navigator.push(
        //     context,
        //     MoveRightRoute(page: Questions()),
        //   ),
        // ),

        // ListTile(
        //   key: const ValueKey('User Details'),
        //   leading: const Icon(Icons.supervised_user_circle_rounded),
        //   // title: const Text('User Details'),
        //   title: const Text('User Details'),
        //   onTap: () => Navigator.push(
        //     context,
        //     MoveRightRoute(page: const UserDetailsPage()),
        //   ),
        // ),
        ListTile(
            key: const ValueKey('Settings'),
            leading: const Icon(Icons.settings),
            // title: const Text('Settings'),
            title: const Text('Settings'),
            onTap: () => Navigator.push(
                  context,
                  MoveRightRoute(page: const Settings()),
                )),
        ListTile(
            key: const ValueKey('Feedback'),
            leading: const Icon(Icons.announcement),
            title: const Text('Feedback'),
            onTap: () {
              Navigator.push(
                context,
                MoveRightRoute(page: const FeedbackScreen()),
              );
            }),
        ListTile(
            key: const ValueKey('FAQ'),
            leading: const Icon(Icons.help),
            title: const Text('FAQs'),
            onTap: () {
              Navigator.push(
                context,
                MoveRightRoute(page: const FAQScreen()),
              );
            }),

        // ListTile(
        //     key: const ValueKey('Folder Grid View'),
        //     leading: Icon(Icons.book),
        //     title: Text('Folder Grid View'),
        //     onTap: () => Navigator.push(
        //           context,
        //           MoveRightRoute(page: FolderGridView()),
        //
        //         )),

        Expanded(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: ListTile(
              key: const ValueKey('Log Out Button'),
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Authentication.signOut(context: context);
                Navigator.of(context).pushNamedAndRemoveUntil(
                    SignInScreen.id, (Route<dynamic> route) => false);
              },
            ),
          ),
        ),
      ],
    ));
  }
}

