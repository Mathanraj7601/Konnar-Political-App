import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isTamil = false; // false = English, true = Tamil
  static const String _langKey = "isTamil";

  LanguageProvider() {
    _loadLanguage();
  }

  bool get isTamil => _isTamil;

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _isTamil = prefs.getBool(_langKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _isTamil = !_isTamil;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_langKey, _isTamil);
    notifyListeners();
  }
}