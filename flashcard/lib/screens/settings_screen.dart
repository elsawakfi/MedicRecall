import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flashcard_x/screens/user_details_screen.dart';
//import 'package:flashcard_x/utils/page_transition.dart';
import 'package:flashcard_x/utils/theme_provider.dart';
import 'package:flashcard_x/widgets/drawer_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar_screen.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  late User user;
  bool isNotify = false;

  @override
  void initState() {
    super.initState();
    triggerSignIn('settings');
    checkNotify();
  }

//When the notification option is changed, update the change in the firebase
Future<void> changeNotify() async {
  CollectionReference collectionRef =
  FirebaseFirestore.instance.collection('users');
  QuerySnapshot querySnapshot =
  await collectionRef.where("userID", isEqualTo: user.uid).get();
  var userID = querySnapshot.docs.last.id;

  collectionRef.doc(userID).update({"notify": isNotify});

}

//Check if the notification field from the firebase for the user is set to true or false and shouw the value in the settings screen
Future<void> checkNotify() async {
  CollectionReference collectionRef =
  FirebaseFirestore.instance.collection('users');
  QuerySnapshot querySnapshot =
  await collectionRef.where("userID", isEqualTo: user.uid).get();
  var userFromDb = querySnapshot.docs.first;

  Map<String, dynamic> data = userFromDb.data() as Map<String, dynamic>;
  if (data["notify"] == true) {
    isNotify = true;
  } else if (data["notify"] == false) {
    isNotify = false;
  }
  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: const DrawMain(),
      appBar: AppBar(
          elevation: 0,
          title: Align(
            alignment: const Alignment(-0.06, 0),
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
                  child: const Text("Settings"),
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
                  ))),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Dark Mode'),
            contentPadding: const EdgeInsets.only(left: 16.0),
            trailing: Transform.scale(
              scale: 0.4,
              child: DayNightSwitcher(
                isDarkModeEnabled:
                    themeProvider.getTheme() == MyTheme.darkTheme,
                onStateChanged: (val) {
                  setState(() {
                    // bool _darkTheme = val;
                    themeProvider.setTheme(themeProvider.getTheme(), val);
                  });
                  onThemeChanged(val, themeProvider);
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('Email Notifications'),
            contentPadding: const EdgeInsets.only(left: 16.0),
            trailing: Row (
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.5,
                  child: Transform.translate(
                    offset: const Offset(-35.0, 0.0),
                    child: CupertinoSwitch(
                      value: isNotify,
                      onChanged: (x) {
                          setState(() {
                            isNotify = x;
                            changeNotify();
                          });
                      },
                    ),
                  ),
                ),
              ],
            )
          ),
          ListTile(
              title: const Text('Make a revision plan'),
              onTap: () {

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const Calendar(),
                //   ),
                // );

                triggerSignIn('Calendar');

              }),
          ListTile(
            key: const ValueKey('User Details'),
            title: const Text('User Details'),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MoveRightRoute(page: const UserDetailsPage()),

              triggerSignIn('UserDetailsPage');

            }
          ),
        ],
      ),
    );
  }

  void onThemeChanged(bool value, ThemeProvider themeProvider) async {
    (value)
        ? themeProvider.setTheme(
            MyTheme.darkTheme, value) // theme change takes place here
        : themeProvider.setTheme(MyTheme.lightTheme, value);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode',
        value); // save boolean value to localstorage. boolean value = darkmode on or off
  }

  Future<void> triggerSignIn(String screen) async{
    NavigatorState nav = Navigator.of(context);
    if (auth.currentUser == null) {
      var tmp = await auth
          .authStateChanges()
          .first;
      if (tmp == null) {
        nav.push(
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            )
        );
      } else {
        user = tmp;
      }
    } else {
      if (screen == 'UserDetailsPage'){
        nav.push(
            MaterialPageRoute(
              builder: (context) => const UserDetailsPage(),
            )
        );
      }
      else if (screen == 'Calendar'){
        nav.push(
            MaterialPageRoute(
              builder: (context) => const Calendar(),
            )
        );
      } else {
        user = auth.currentUser!;
      }
    }
  }
}
