import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  List<Locale> get supportedLocales => const [
        Locale('en'),
        Locale('hi'),
        Locale('te'),
      ];

  void setLocale(Locale locale) {
    if (locale != _locale) {
      _locale = locale;
      notifyListeners();
    }
  }

  void toggleLocale() {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('hi');
    } else if (_locale.languageCode == 'hi') {
      _locale = const Locale('te');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
  }

  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी';
      case 'te':
        return 'తెలుగు';
      default:
        return 'English';
    }
  }

  List<Map<String, dynamic>> get availableLanguages => [
        {'code': 'en', 'name': 'English', 'nativeName': 'English'},
        {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
        {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు'},
      ];
}
