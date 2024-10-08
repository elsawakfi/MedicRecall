import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides [ThemeData] to the custom AppBar toggle switch
class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  getTheme() => _themeData; // to get current theme of app

  setTheme(ThemeData themeData, val) async {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('darkMode', val);
    });
    _themeData = themeData;
    notifyListeners(); // to update theme of app
  }
}

class MyTheme {
  //**************   L  I  G  H  T     T  H  E  M  E   **************//

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Akshar',
    hintColor: const Color(0xFF0C91D6),
  ).copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            // Makes all my ElevatedButton white
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white))),
    appBarTheme: const AppBarTheme(
      color: Color(0xFFE6EDF2),
      iconTheme: IconThemeData(color: Color.fromRGBO(21, 58, 103, 1), size: 25),
      titleTextStyle: TextStyle(
        fontFamily: 'Akshar',
        color: Color.fromRGBO(21, 58, 103, 1),
        fontSize: 21,
        fontWeight: FontWeight.bold,
      ),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      // Set the color of the dropdown menu text
      textStyle: TextStyle(color: Colors.deepPurple),
      inputDecorationTheme: InputDecorationTheme(
        // Set the color of the underline for the dropdown menu
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurpleAccent), // Set underline color to white
        ),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: const Color.fromARGB(61, 71, 173, 224),
    ),
    scaffoldBackgroundColor: Colors.white,
    // using this for `Reset` button color
    primaryColor: const Color(0xFFE6EDF2),
    // using this for `Reset` shadow1 color
    shadowColor: const Color.fromARGB(255, 180, 193, 203),
    // using this for `Reset` shadow2 color
    splashColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.grey, fontFamily: 'Akshar'),
      // navbar text colour
      headlineSmall: TextStyle(color: Colors.black87, fontFamily: 'Akshar'),
      bodySmall: TextStyle(color: Colors.blueAccent, fontFamily: 'Akshar'),
      titleMedium: TextStyle(color: Colors.black, fontFamily: 'Akshar'),
      bodyMedium: TextStyle(
          color: Color.fromRGBO(21, 58, 103, 1), fontFamily: 'Akshar'),
      displayLarge: TextStyle(fontFamily: 'Akshar'),
      displayMedium: TextStyle(fontFamily: 'Akshar'),
      displaySmall: TextStyle(fontFamily: 'Akshar'),
      headlineMedium : TextStyle(fontFamily: 'Akshar'),
      titleLarge: TextStyle(fontFamily: 'Akshar'),
      titleSmall: TextStyle(fontFamily: 'Akshar'),
      labelLarge: TextStyle(fontFamily: 'Akshar'),
    ),
  );

  //*************   D  A  R  K     T  H  E  M  E   **************//

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Akshar',
    hintColor: Colors.blueGrey[200],
  ).copyWith(
    listTileTheme: const ListTileThemeData(iconColor: Colors.white),
    // to change list tile icons in navbar
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: // elevated buttons
                MaterialStateProperty.all<Color>(Colors.blueGrey))),
    appBarTheme: const AppBarTheme(
      color: Color.fromARGB(255, 34, 57, 79),
      iconTheme: IconThemeData(color: Colors.white, size: 25),
      titleTextStyle: TextStyle(
        fontFamily: 'Akshar',
        color: Colors.white,
        fontSize: 23,
        fontWeight: FontWeight.bold,
      ),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      // Set the color of the dropdown menu text
      textStyle: TextStyle(color: Colors.white),
  inputDecorationTheme: InputDecorationTheme(
  // Set the color of the underline for the dropdown menu
  enabledBorder: UnderlineInputBorder(
  borderSide: BorderSide(color: Colors.white), // Set underline color to white
  ),
  ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: const Color.fromARGB(255, 255, 255, 255),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 47, 106, 161),
    // using this for `Reset` button color
    primaryColor: const Color.fromARGB(255, 47, 106, 161),
    // using this for `Reset` shadow1 color
    shadowColor: Colors.black,
    // using this for `Reset` shadow2 color
    splashColor: Colors.white12,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Akshar'),
      // navbar text colour
      bodyMedium: TextStyle(color: Colors.white, fontFamily: 'Akshar'),
      headlineSmall: TextStyle(color: Colors.white, fontFamily: 'Akshar'),
      bodySmall: TextStyle(color: Color(0xFF253341), fontFamily: 'Akshar'),
      titleMedium: TextStyle(color: Colors.white, fontFamily: 'Akshar'),
      displayLarge: TextStyle(fontFamily: 'Akshar'),
      displayMedium: TextStyle(fontFamily: 'Akshar'),
      displaySmall: TextStyle(fontFamily: 'Akshar'),
      headlineMedium: TextStyle(fontFamily: 'Akshar'),
      titleLarge: TextStyle(fontFamily: 'Akshar'),
      titleSmall: TextStyle(fontFamily: 'Akshar'),
      labelLarge: TextStyle(fontFamily: 'Akshar'),
    ),
  );
}
