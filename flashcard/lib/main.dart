import 'package:firebase_core/firebase_core.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/landing_screen.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/screens/sign_up_screen.dart';
import 'package:flashcard_x/screens/verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/theme_provider.dart';

getSystemTheme() {
  var brightness = SchedulerBinding.instance.window.platformBrightness;
  bool lightModeOn = brightness == Brightness.light;
  return lightModeOn;
}

Future<void> main() async {
  /// For disabling landscape view in mobile & tablet devices
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  await Firebase.initializeApp();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive).then((_) {
    // full screen mode
    SharedPreferences.getInstance().then((prefs) {
      runApp(
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider(
                MyTheme.darkTheme),
            child: const Flashcard()),
        // child: Login(), //run to log into the app
        // child: SignInScreen()), //run to log into the app
      );
    });
  });
}

class Flashcard extends StatelessWidget {
  const Flashcard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Consumer<ThemeProvider>(builder: (context, appState, child) {
      return MaterialApp(
          title: 'MedicRecall',
          theme: themeProvider.getTheme(),
          debugShowCheckedModeBanner: false,
          // Remove the debug banner
          // home: const SignInScreen(),
          initialRoute: Landing.id,
          routes: {
            VerifyEmailScreen.id: (context) => const VerifyEmailScreen(),
            SignInScreen.id: (context) => const SignInScreen(),
            SignUpScreen.id: (context) => const SignUpScreen(),
            HomePage.id: (context) => const HomePage(title: "Medicine Upload"),
            Landing.id: (context) => const Landing(),
          }
          );
    });
  }
}
