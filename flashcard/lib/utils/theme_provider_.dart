import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = MyTheme.darkTheme(GoogleFonts.lato().fontFamily!, 0);
  bool _isDarkMode = true;
  String _fontFamily = GoogleFonts.lato().fontFamily!;
  double _offset = 0;

  ThemeData get theme => _themeData;
  bool get isDarkMode => _isDarkMode;
  String get fontFamily => _fontFamily;
  double get offset => _offset;

  SharedPreferencesAsync? prefs;


  ThemeProvider({bool testing = false}) {
    prefs = testing ? MockSharedPreferencesAsync() : SharedPreferencesAsync();
    initialize();
  }
  
  Future<void> initialize() async {
    _isDarkMode = await prefs?.getBool('darkMode') ?? true;
    _fontFamily = await prefs?.getString('fontFamily') ?? GoogleFonts.lato().fontFamily!;
    _offset = await prefs?.getDouble('fontSize') ?? 0;

    _themeData = _isDarkMode
        ? MyTheme.darkTheme(_fontFamily, _offset)
        : MyTheme.lightTheme(_fontFamily, _offset);
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? MyTheme.darkTheme(_fontFamily, _offset) : MyTheme.lightTheme(_fontFamily, _offset);

    _themeData = _themeData.copyWith(
      textTheme: _themeData.textTheme.apply(fontFamily: _fontFamily),
    );

    await _saveThemePreference();
    notifyListeners();
  }

  Future<void> setLightTheme() async {
    _isDarkMode = false;
    _themeData = MyTheme.lightTheme(_fontFamily, _offset);

    await _saveThemePreference();
    notifyListeners();
  }

  Future<void> setDarkTheme() async {
    _isDarkMode = true;
    _themeData = MyTheme.darkTheme(_fontFamily, _offset);

    await _saveThemePreference();
    notifyListeners();
  }

  Future<void> setFontFamily(String fontFamily) async {
    _fontFamily = fontFamily;
    await _saveFontPreference();
    _isDarkMode ? setDarkTheme() : setLightTheme();
  }

  Future<void> setFontSize(double offset) async {
    _offset = offset;
    await _saveFontPreference();
    _isDarkMode ? setDarkTheme() : setLightTheme();
  }

  Future<void> _saveThemePreference() async {
    await prefs?.setBool('darkMode', _isDarkMode);
  }

  Future<void> _saveFontPreference() async {
    await prefs?.setString('fontFamily', _fontFamily);
    await prefs?.setDouble('fontSize', _offset);
  }
}

class MockSharedPreferencesAsync implements SharedPreferencesAsync {
  final Map<String, dynamic> _dataStore = {};

  @override
  Future<bool> getBool(String key) async {
    return _dataStore[key] ?? false;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _dataStore[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _dataStore[key] as String?;
  }

  @override
  Future<void> setString(String key, String value) async {
    _dataStore[key] = value;
  }

  @override
  Future<double?> getDouble(String key) async {
    return _dataStore[key] as double?;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    _dataStore[key] = value;
  }

  @override
  Future<void> clear({Set<String>? allowList}) {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  Future<bool> containsKey(String key) {
    // TODO: implement containsKey
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<int?> getInt(String key) {
    // TODO: implement getInt
    throw UnimplementedError();
  }

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) {
    // TODO: implement getKeys
    throw UnimplementedError();
  }

  @override
  Future<List<String>?> getStringList(String key) {
    // TODO: implement getStringList
    throw UnimplementedError();
  }

  @override
  Future<void> remove(String key) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future<void> setInt(String key, int value) {
    // TODO: implement setInt
    throw UnimplementedError();
  }

  @override
  Future<void> setStringList(String key, List<String> value) {
    // TODO: implement setStringList
    throw UnimplementedError();
  }
}


class MyTheme {
  //**************   L  I  G  H  T     T  H  E  M  E   **************//
  static ThemeData lightTheme(String fontFamily, double offset) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color.fromRGBO(49, 119, 174, 1.0),
      scaffoldBackgroundColor: Color.fromRGBO(0x2F, 0x4E, 0x6E, 1),
      hintColor: const Color(0xFF0C91D6),
      shadowColor: const Color(0xFFB4C1CB),
      splashColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF0C91D6),
        secondary: Colors.blueAccent,
        surface: const Color(0xFFE6EDF2),
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
      ),
      inputDecorationTheme: ThemeData.light().inputDecorationTheme.copyWith(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.black, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Colors.black, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14+offset),
        labelStyle: TextStyle(color: Colors.black87, fontSize: 14+offset),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      appBarTheme: AppBarTheme(
        color: Color(0xFFE6EDF2),
        iconTheme: IconThemeData(color: Color(0xFF153A67), size: 25),
        titleTextStyle: TextStyle(
          color: Color(0xFF153A67),
          fontSize: 21+offset,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Color.fromRGBO(44, 44, 44, 1)),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Color.fromRGBO(44, 44, 44, 1)),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: TextStyle(fontSize: 18+offset, fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(fontSize: 16+offset),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: Colors.white),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(Colors.black),
          shadowColor: WidgetStateProperty.all(Colors.grey),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
      fontFamily: fontFamily,
      textTheme: TextTheme(
        // bodyLarge: TextStyle(color: Colors.white),
        // headlineSmall: TextStyle(color: Colors.black87),
        // bodySmall: TextStyle(color: Colors.blueAccent),
        displayMedium: TextStyle(fontSize: 45+offset),
        titleMedium: TextStyle(fontSize: 20+offset, fontWeight: FontWeight.w500),
        titleLarge: TextStyle(fontSize: 23+offset, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16+offset),
        bodyMedium: TextStyle(fontSize: 14+offset),
        bodySmall: TextStyle(fontSize: 12+offset)
      ),
    );
  }

  //*************   D  A  R  K     T  H  E  M  E   **************//
  static ThemeData darkTheme(String fontFamily, double offset) {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.lato().fontFamily,
      hintColor: Colors.blueGrey[200],
      listTileTheme: const ListTileThemeData(iconColor: Colors.white),
      // to change list tile icons in navbar
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Color.fromRGBO(44, 44, 44, 1)),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Color.fromRGBO(44, 44, 44, 1)),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      inputDecorationTheme: ThemeData.light().inputDecorationTheme.copyWith(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.black, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Colors.black, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14+offset),
        labelStyle: TextStyle(color: Colors.black87, fontSize: 14+offset),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      appBarTheme: AppBarTheme(
        color: Color.fromARGB(255, 34, 57, 79),
        iconTheme: IconThemeData(color: Colors.white, size: 25),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 23+offset,
          fontWeight: FontWeight.bold,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18+offset, fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: Colors.white70, fontSize: 16+offset),
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
          brightness: Brightness.dark
      ),
      scaffoldBackgroundColor: const Color.fromRGBO(0x2F, 0x4E, 0x6E, 1),
      // using this for `Reset` button color
      primaryColor: const Color.fromARGB(255, 47, 106, 161),
      // using this for `Reset` shadow1 color
      shadowColor: Colors.black,
      // using this for `Reset` shadow2 color
      splashColor: Colors.white12,
      textTheme: TextTheme(
        displayMedium: TextStyle(fontSize: 45+offset),
        titleMedium: TextStyle(fontSize: 20+offset, fontWeight: FontWeight.w500),
        titleLarge: TextStyle(fontSize: 23+offset, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16+offset),
        bodyMedium: TextStyle(fontSize: 14+offset),
        bodySmall: TextStyle(fontSize: 12+offset)
      ),
    );
  }
}