/// Abstract repository interface for translations (Domain Layer)
abstract class TranslationRepository {
  /// Fetch translations from API
  Future<Map<String, String>> fetchTranslationsFromApi(String language);
  
  /// Cache translations locally
  Future<void> cacheTranslations(String language, Map<String, String> translations);
  
  /// Get cached translations
  Future<Map<String, String>?> getCachedTranslations(String language);
  
  /// Check if cache is valid
  Future<bool> hasValidCache(String language);
  
  /// Clear cache
  Future<void> clearCache();
}
