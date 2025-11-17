import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/translation/translation_manager.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Start with English by default

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      
      // Sync with TranslationManager when locale changes
      TranslationManager.instance.setCurrentLanguage(locale.languageCode);
      // Save language preference
      _saveLanguagePreference(locale.languageCode);
      notifyListeners();
    }
  }

  /// Initialize the translation system
  Future<void> initialize() async {
    // Load saved language preference first
    final savedLanguage = await _getSavedLanguage();
    _locale = Locale(savedLanguage);
    
    // Initialize TranslationManager with saved locale
    TranslationManager.instance.initialize(_locale.languageCode);
    
    // Notify listeners of the initial language
    notifyListeners();
  }

  /// Get saved language preference
  Future<String> _getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('selected_language') ?? 'ta'; // Default to English
    } catch (e) {
      return 'ta'; // Default to English on error
    }
  }

  /// Save language preference
  Future<void> _saveLanguagePreference(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', languageCode);
    } catch (e) {
      // Silent fail - not critical
    }
  }
}
