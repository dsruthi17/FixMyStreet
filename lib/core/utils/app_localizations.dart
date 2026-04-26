import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle
        .loadString('lib/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Helper getters for common strings
  String get appName => translate('appName');
  String get appTagline => translate('appTagline');
  String get welcomeBack => translate('welcomeBack');
  String get signIn => translate('signIn');
  String get signUp => translate('signUp');
  String get email => translate('email');
  String get password => translate('password');
  String get home => translate('home');
  String get map => translate('map');
  String get report => translate('report');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get language => translate('language');
  String get darkMode => translate('darkMode');
  String get logout => translate('logout');
  String get myComplaints => translate('myComplaints');
  String get pending => translate('pending');
  String get inProgress => translate('inProgress');
  String get resolved => translate('resolved');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get yes => translate('yes');
  String get no => translate('no');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'te'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
