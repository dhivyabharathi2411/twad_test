import '../../presentation/providers/translation_provider.dart';

/// Master-level App Translation Initializer
class AppTranslationInitializer {
  static TranslationProvider? _translationProvider;
  
  /// Initialize translation system for the app
  static Future<void> initialize() async {
    
    try {
      // Create translation provider instance
      _translationProvider = TranslationProvider();
      
      // Initialize the translation system
      await _translationProvider!.initialize();
    } catch (e) {
      
      // Create fallback provider for static translations only
      try {
        _translationProvider = TranslationProvider();
        // Initialize with fallback method that doesn't make API calls
        _translationProvider!.initializeStaticOnly();
      } catch (fallbackError) {
        // Create minimal provider that at least won't crash
        _translationProvider = TranslationProvider();
      }
    }
  }

  /// Get the global translation provider instance
  static TranslationProvider get translationProvider {
    if (_translationProvider == null) {
      throw Exception('Translation system not initialized. Call AppTranslationInitializer.initialize() first.');
    }
    return _translationProvider!;
  }

  /// Quick translation method for global access
  static String translate(String key) {
    return translationProvider.translate(key);
  }

  /// Quick language switch for global access
  static Future<void> switchLanguage(String language) async {
    await translationProvider.switchLanguage(language);
  }

  /// Get current language
  static String get currentLanguage => translationProvider.currentLanguage;

  /// Preload all languages for better performance
  static Future<void> preloadAllLanguages() async {
    try {
      await translationProvider.preloadAllLanguages();

    } catch (e) {
//
    }
  }

  /// Update translations in background (for periodic updates)
  static Future<void> updateTranslationsInBackground() async {
    try {
      await translationProvider.refreshTranslations();
    } catch (e) {
  //
    }
  }

  /// Get translation statistics for debugging
  static Map<String, dynamic> getStats() {
    return translationProvider.getTranslationStats();
  }
}

/// Global translation function for easy access
String tr(String key) => AppTranslationInitializer.translate(key);
