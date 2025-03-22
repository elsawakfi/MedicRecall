import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flashcard_x/screens/dashboard_screen.dart';
import 'package:flashcard_x/screens/landing_screen.dart';
import 'package:flashcard_x/screens/sign_in_screen.dart';
import 'package:flashcard_x/screens/sign_up_screen.dart';
import 'package:flashcard_x/screens/verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/theme_provider.dart';

getSystemTheme() {
  var brightness = PlatformDispatcher.instance.platformBrightness;
  bool lightModeOn = brightness == Brightness.light;
  return lightModeOn;
}

Future<void> main() async {
  /// For disabling landscape view in mobile & tablet devices
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive).then((_) {
    // full screen mode
    SharedPreferences.getInstance().then((prefs) {
      bool isDarkMode =
          prefs.getBool('darkMode') ?? true; // Default to dark mode
      runApp(
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider(
                isDarkMode ? MyTheme.lightTheme : MyTheme.darkTheme),
            child: const Flashcard()),
      );
    });
  });
}

class Flashcard extends StatelessWidget {
  const Flashcard({super.key});

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
          initialRoute: SignInScreen.id,
          routes: {
            VerifyEmailScreen.id: (context) => const VerifyEmailScreen(),
            SignInScreen.id: (context) => const SignInScreen(),
            SignUpScreen.id: (context) => const SignUpScreen(),
            HomePage.id: (context) => const HomePage(title: "Medicine Upload"),
            Landing.id: (context) => const Landing(),
          });
    });
  }
}
