import '../../core/translation/translation_repository.dart';
import '../../services/translation_api_service.dart';
import '../../services/translation_cache_service.dart';

/// Implementation of TranslationRepository (Data Layer)
class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationApiService _apiService;

  TranslationRepositoryImpl({TranslationApiService? apiService})
      : _apiService = apiService ?? TranslationApiService();

  @override
  Future<Map<String, String>> fetchTranslationsFromApi(String language) async {
    final result = await _apiService.fetchTranslations(language);
    
    if (result['success'] == true) {
      return result['data'] as Map<String, String>;
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch translations');
    }
  }

  @override
  Future<void> cacheTranslations(String language, Map<String, String> translations) async {
    await TranslationCacheService.cacheTranslations(language, translations);
  }

  @override
  Future<Map<String, String>?> getCachedTranslations(String language) async {
    return await TranslationCacheService.getCachedTranslations(language);
  }

  @override
  Future<bool> hasValidCache(String language) async {
    return await TranslationCacheService.hasValidCache(language);
  }

  @override
  Future<void> clearCache() async {
    await TranslationCacheService.clearAllCache();
  }
}
