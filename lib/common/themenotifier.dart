import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeNotifier();

  refreshAppTheme() async {
    notifyListeners(); // to update the theme of the app
  }
}