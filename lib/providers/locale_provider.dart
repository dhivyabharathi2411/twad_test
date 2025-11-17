import 'package:flutter/material.dart';
import '../core/translation/translation_manager.dart';

/// Master-level Locale Provider that unifies static + dynamic translations
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ta');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      // Update TranslationManager for the new locale
      TranslationManager.instance.setCurrentLanguage(locale.languageCode);
      notifyListeners();
    }
  }

  /// Master translation method - works for both static and dynamic
  String translate(String key) {
    return TranslationManager.instance.translate(key, language: _locale.languageCode);
  }

  /// Shorter alias for translation
  String tr(String key) => translate(key);

  /// Initialize the locale provider with translation system
  Future<void> initialize() async {
    TranslationManager.instance.initialize(_locale.languageCode);
  }
}
