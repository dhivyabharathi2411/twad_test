import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/translation/translation_manager.dart';
import '../../domain/usecases/get_translations_usecase.dart';

/// Master-level Translation Provider with Clean Architecture
class TranslationProvider extends ChangeNotifier {
  final GetTranslationsUseCase _getTranslationsUseCase;
  
  String _currentLanguage = 'en';
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  TranslationProvider({GetTranslationsUseCase? getTranslationsUseCase})
      : _getTranslationsUseCase = getTranslationsUseCase ?? GetTranslationsUseCase();

  // Getters
  String get currentLanguage => _currentLanguage;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  List<String> get availableLanguages => ['en', 'ta'];

  /// Initialize translation system
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Get current language from TranslationManager (already initialized by LocaleProvider)
      _currentLanguage = TranslationManager.instance.currentLanguage;

      
      // Load dynamic translations in background (non-blocking)
      unawaited(_loadTranslationsInBackground());
      
      _isInitialized = true;
      notifyListeners();

    } catch (e) {
      _error = 'Failed to initialize translations: $e';
      
      // Fallback: Initialize with default language and static translations only
      initializeStaticOnly();
    }
  }

  /// Initialize with static translations only (fallback mode)
  void initializeStaticOnly() {
    try {
      _currentLanguage = 'en';
      TranslationManager.instance.initialize(_currentLanguage);
      _isInitialized = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Critical initialization failure: $e';
    }
  }

  /// Translate a key using TranslationManager
  String translate(String key) {
    return TranslationManager.instance.translate(key);
  }

  /// Force load dynamic translations synchronously (use sparingly)
  Future<void> ensureTranslationsLoaded() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      // Force load translations for current language if not already loaded
      final currentTranslations = TranslationManager.instance.getMergedTranslations(_currentLanguage);
      if (currentTranslations == null || currentTranslations.isEmpty) {
        await _getTranslationsUseCase.loadAndMergeTranslations(_currentLanguage);
        notifyListeners();
      }
    } catch (e) {
//
    }
  }

  /// Switch to a different language
  Future<void> switchLanguage(String newLanguage) async {
    if (!availableLanguages.contains(newLanguage) || newLanguage == _currentLanguage) {
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update current language
      _currentLanguage = newLanguage;
      TranslationManager.instance.setCurrentLanguage(newLanguage);
      
      // Load translations for new language
      await _getTranslationsUseCase.loadAndMergeTranslations(newLanguage);
      
      // Save language preference
      await _saveLanguagePreference(newLanguage);
    } catch (e) {
      _error = 'Failed to switch language: $e';

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sync language from external source (like LocaleProvider)
  void syncLanguage(String newLanguage) {
    if (availableLanguages.contains(newLanguage) && newLanguage != _currentLanguage) {
      _currentLanguage = newLanguage;
      
      // Load dynamic translations in background for the new language
      unawaited(_getTranslationsUseCase.loadAndMergeTranslations(newLanguage));
      notifyListeners();
    }
  }

  /// Refresh translations for current language
  Future<void> refreshTranslations() async {
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _getTranslationsUseCase.refreshTranslations(_currentLanguage);
    } catch (e) {
      _error = 'Failed to refresh translations: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load translations for all available languages
  Future<void> preloadAllLanguages() async {
    
    try {
      await _getTranslationsUseCase.loadMultipleLanguages(availableLanguages);
    } catch (e) {
     //
    }
  }

  /// Clear all translation cache
  Future<void> clearCache() async {
    
    try {
      await _getTranslationsUseCase.clearCache();
      TranslationManager.instance.clearDynamicTranslations();
      
      // Reload current language
      await _getTranslationsUseCase.loadAndMergeTranslations(_currentLanguage);
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear cache: $e';
      //
    }
  }

  /// Get translation statistics
  Map<String, dynamic> getTranslationStats() {
    return TranslationManager.instance.getTranslationStats();
  }

  /// Check if translations are available for language
  bool hasTranslationsFor(String language) {
    return TranslationManager.instance.hasTranslationsFor(language);
  }

  // Private methods

  /// Load translations in background without blocking UI
  Future<void> _loadTranslationsInBackground() async {
    try {
      await _getTranslationsUseCase.loadAndMergeTranslations(_currentLanguage);
      notifyListeners(); // Update UI with enhanced translations
    } catch (e) {
  //
    }
  }

  /// Save language preference
  Future<void> _saveLanguagePreference(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', language);
    } catch (e) {
      //
    }
  }

  /// Utility method to prevent awaiting in fire-and-forget scenarios
  void unawaited(Future<void> future) {
    future.catchError((error) {
    });
  }
}

/// Extension for convenient translation access in widgets
extension TranslationExtension on BuildContext {
  String tr(String key) {
    final provider = TranslationProvider();
    return provider.translate(key);
  }
}
