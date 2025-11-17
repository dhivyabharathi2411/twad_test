import '../../api/api_client.dart';
import '../../api/api_config.dart';
import '../../services/api_setup.dart';

/// Translation API service for fetching dynamic translations
class TranslationApiService {
  final ApiClient _apiClient;

  TranslationApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiSetup.apiClient;

  String _mapLanguageCodeForApi(String internalCode) {
    switch (internalCode.toLowerCase()) {
      case 'en':
        return 'en'; 
      case 'ta': 
        return 'ta'; 
      default:
        return internalCode; 
    }
  }

  Future<Map<String, dynamic>> fetchTranslations(String language) async {
    try {
      // 🔧 Map internal language codes to API expected format
      String apiLanguage = _mapLanguageCodeForApi(language);
      
      // Make API call to get translations
      final response = await _apiClient.get(
        AppConfig.getTranslationKeywords,
        params: {
          'language': apiLanguage,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Handle successful response
        if (responseData['status'] == true && responseData['data'] != null) {
          final translationsData = responseData['data'] as Map<String, dynamic>;
          
          // Convert to Map<String, String>
          final translations = translationsData.map(
            (key, value) => MapEntry(key, value.toString()),
          );
        
          
          return {
            'success': true,
            'data': translations,
            'message': responseData['message'] ?? 'Translations fetched successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'No translation data available',
            'data': <String, String>{},
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch translations: ${response.statusCode}',
          'data': <String, String>{},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Translation fetch failed: $e',
        'error': e.toString(),
        'data': <String, String>{},
      };
    }
  }

  /// Fetch translations for multiple languages
  Future<Map<String, Map<String, String>>> fetchMultipleLanguageTranslations(
    List<String> languages,
  ) async {
    final results = <String, Map<String, String>>{};
    
    for (final language in languages) {
      try {
        final result = await fetchTranslations(language);
        if (result['success'] == true) {
          results[language] = result['data'] as Map<String, String>;
        }
      } catch (e) {
        results[language] = <String, String>{};
      }
    }
    
    return results;
  }

  Future<bool> isApiAvailable() async {
    try {
      final response = await _apiClient.get(
        AppConfig.getTranslationKeywords,
        params: {'language': 'en'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
