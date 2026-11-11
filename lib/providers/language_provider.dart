import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isEnglish = false;

  bool get isEnglish => _isEnglish;
  String get currentLanguageCode => _isEnglish ? 'en' : 'vi';
  String get currentLanguageName => _isEnglish ? 'English' : 'Tiếng Việt';

  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    notifyListeners();
  }

  void setLanguage(bool isEnglish) {
    if (_isEnglish != isEnglish) {
      _isEnglish = isEnglish;
      notifyListeners();
    }
  }

  String tr(String vi, String en) {
    return _isEnglish ? en : vi;
  }
}

