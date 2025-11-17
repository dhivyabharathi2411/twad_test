import 'package:flutter/foundation.dart';
import '../../core/translation/translation_repository.dart';
import '../../core/translation/translation_manager.dart';
import '../../data/repositories/translation_repository_impl.dart';

/// Use case for managing translations with Clean Architecture
class GetTranslationsUseCase {
  final TranslationRepository _repository;

  GetTranslationsUseCase({TranslationRepository? repository})
      : _repository = repository ?? TranslationRepositoryImpl();

  /// Smart translation loading with cache-first strategy
  Future<Map<String, String>> execute(String language) async {

    try {
      // Step 1: Check if we have valid cache
      if (await _repository.hasValidCache(language)) {
        final cachedTranslations = await _repository.getCachedTranslations(language);
        if (cachedTranslations != null) {
          return cachedTranslations;
        }
      }

      final apiTranslations = await _repository.fetchTranslationsFromApi(language);

      // Step 3: Cache the fresh data
      await _repository.cacheTranslations(language, apiTranslations);

      return apiTranslations;

    } catch (e) {
      
      // Fallback: Try to return any cached data even if expired
      try {
        final cachedTranslations = await _repository.getCachedTranslations(language);
        if (cachedTranslations != null) {
          return cachedTranslations;
        }
      } catch (cacheError) {
        //
      }
      
      return <String, String>{};
    }
  }

  /// Load and merge translations with static translations
  Future<void> loadAndMergeTranslations(String language) async {
    try {
      
      // Get dynamic translations from API/cache
      final dynamicTranslations = await execute(language);
      
      // Update TranslationManager with merged data
      TranslationManager.instance.updateDynamicTranslations(language, dynamicTranslations);
    } catch (e) {
      // TranslationManager will fall back to static translations
    }
  }

  /// Refresh translations (force fresh fetch)
  Future<Map<String, String>> refreshTranslations(String language) async {
    try {
      
      // Fetch fresh data from API
      final apiTranslations = await _repository.fetchTranslationsFromApi(language);
      
      // Update cache
      await _repository.cacheTranslations(language, apiTranslations);
      
      // Update TranslationManager
      TranslationManager.instance.updateDynamicTranslations(language, apiTranslations);

      return apiTranslations;
    } catch (e) {
      rethrow;
    }
  }

  /// Load translations for multiple languages
  Future<void> loadMultipleLanguages(List<String> languages) async {
    
    for (final language in languages) {
      try {
        await loadAndMergeTranslations(language);
      } catch (e) {
        // Continue with other languages
      }
    }
  }

  /// Clear all translation cache
  Future<void> clearCache() async {
    try {
      await _repository.clearCache();

    } catch (e) {
 //
    }
  }
}
