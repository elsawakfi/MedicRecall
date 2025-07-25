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
    fontFamily: 'Lato',
    hintColor: const Color(0xFF0C91D6),
  ).copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            // Makes all my ElevatedButton white
            backgroundColor: WidgetStateProperty.all<Color>(Colors.white))),
    appBarTheme: const AppBarTheme(
      color: Color(0xFFE6EDF2),
      iconTheme: IconThemeData(color: Color.fromRGBO(21, 58, 103, 1), size: 25),
      titleTextStyle: TextStyle(
        fontFamily: 'Lato',
        color: Color.fromRGBO(21, 58, 103, 1),
        fontSize: 23,
        fontWeight: FontWeight.bold,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: Color.fromRGBO(21, 58, 103, 1)),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      // Set the color of the dropdown menu text
      textStyle: TextStyle(color: Colors.deepPurple),
      inputDecorationTheme: InputDecorationTheme(
        // Set the color of the underline for the dropdown menu
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.deepPurpleAccent), // Set underline color to white
        ),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: const Color.fromARGB(61, 71, 173, 224),
    ),
    scaffoldBackgroundColor: Colors.grey[200],
    // using this for `Reset` button color
    primaryColor: const Color(0xFFE6EDF2),
    // using this for `Reset` shadow1 color
    shadowColor: const Color.fromARGB(255, 180, 193, 203),
    // using this for `Reset` shadow2 color
    splashColor: Colors.white,
    textTheme: TextTheme(
      bodyLarge: const TextStyle(color: Colors.grey, fontFamily: 'Lato'),
      // navbar text colour
      headlineSmall:
          const TextStyle(color: Colors.black87, fontFamily: 'Lato'),
      bodySmall:
          const TextStyle(color: Colors.blueAccent, fontFamily: 'Lato'),
      titleMedium: const TextStyle(color: Colors.black, fontFamily: 'Lato'),
      bodyMedium: const TextStyle(
          color: Color.fromRGBO(21, 58, 103, 1), fontFamily: 'Lato'),
      displayLarge: const TextStyle(fontFamily: 'Lato'),
      displayMedium: const TextStyle(fontFamily: 'Lato'),
      displaySmall: const TextStyle(fontFamily: 'Lato'),
      headlineMedium: const TextStyle(fontFamily: 'Lato'),
      titleLarge: TextStyle(color: Colors.blueGrey[700], fontFamily: 'Lato'),
      titleSmall: TextStyle(color: Colors.blueGrey[400], fontFamily: 'Lato'),
      labelLarge: const TextStyle(fontFamily: 'Lato'),
    ),
    disabledColor: Colors.red,
  );

  //*************   D  A  R  K     T  H  E  M  E   **************//

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Lato',
    hintColor: Colors.blueGrey[200],
  ).copyWith(
    listTileTheme: const ListTileThemeData(
        iconColor: Colors.white, textColor: Colors.white),
    // to change list tile icons in navbar
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: // elevated buttons
                WidgetStateProperty.all<Color>(Colors.blueGrey))),
    appBarTheme: const AppBarTheme(
      color: Color.fromARGB(255, 34, 57, 79),
      iconTheme: IconThemeData(color: Colors.white, size: 25),
      titleTextStyle: TextStyle(
        fontFamily: 'Lato',
        color: Colors.white,
        fontSize: 23,
        fontWeight: FontWeight.bold,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: Colors.white),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      // Set the color of the dropdown menu text
      textStyle: TextStyle(color: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        // Set the color of the underline for the dropdown menu
        enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Colors.white), // Set underline color to white
        ),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: const Color.fromARGB(255, 255, 255, 255),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 47, 78, 110),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color.fromARGB(255, 47, 78, 110),
    ),
    // using this for `Reset` button color
    primaryColor: const Color.fromARGB(255, 47, 78, 110),
    // using this for `Reset` shadow1 color
    shadowColor: Colors.black,
    // using this for `Reset` shadow2 color
    splashColor: Colors.white12,
    textTheme: TextTheme(
      bodyLarge: const TextStyle(color: Colors.white, fontFamily: 'Lato'),
      // navbar text colour
      bodyMedium: const TextStyle(color: Colors.white, fontFamily: 'Lato'),
      headlineSmall: const TextStyle(color: Colors.white, fontFamily: 'Lato'),
      bodySmall:
          const TextStyle(color: Color(0xFF253341), fontFamily: 'Lato'),
      titleMedium: const TextStyle(color: Colors.white, fontFamily: 'Lato'),
      displayLarge: const TextStyle(fontFamily: 'Lato'),
      displayMedium: const TextStyle(fontFamily: 'Lato'),
      displaySmall: const TextStyle(fontFamily: 'Lato'),
      headlineMedium: const TextStyle(fontFamily: 'Lato'),
      titleLarge: TextStyle(color: Colors.blueGrey[300], fontFamily: 'Lato'),
      titleSmall: TextStyle(color: Colors.grey[400], fontFamily: 'Lato'),
      labelLarge: const TextStyle(fontFamily: 'Lato'),
    ),
    disabledColor: Colors.grey[400],
  );
}
