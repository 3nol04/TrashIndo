import 'package:flutter/material.dart';

enum ChatTheme { light, dark }

class ThemeProvider with ChangeNotifier {
  ChatTheme _currentTheme = ChatTheme.dark;

  ChatTheme get currentTheme => _currentTheme;

  ThemeData get themeData {
    switch (_currentTheme) {
      case ChatTheme.light:
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFFF0F0F0),
          ),
        );
      case ChatTheme.dark:
      default:
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1C1C1E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1C1C1E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF2C2C2E),
          ),
        );
    }
  }

  void toggleTheme() {
    _currentTheme = _currentTheme == ChatTheme.light
        ? ChatTheme.dark
        : ChatTheme.light;
    notifyListeners();
  }
}