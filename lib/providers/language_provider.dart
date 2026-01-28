import 'package:flutter/material.dart';

enum AppLanguage { russian, german }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.german; // Немецкий по умолчанию

  AppLanguage get currentLanguage => _currentLanguage;
  
  String get languageCode => _currentLanguage == AppLanguage.german ? 'de_DE' : 'ru_RU';
  
  bool get isGerman => _currentLanguage == AppLanguage.german;

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == AppLanguage.german 
        ? AppLanguage.russian 
        : AppLanguage.german;
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }
}
