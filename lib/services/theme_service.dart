import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode mode;
  ThemeService(this.mode);

  void toggle() async {
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      mode = ThemeMode.dark;
      await prefs.setBool('isDark', true);
    } else {
      mode = ThemeMode.light;
      await prefs.setBool('isDark', false);
    }
    notifyListeners();
  }
}
