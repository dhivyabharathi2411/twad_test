import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationCacheService {
  static const String _cachePrefix = 'merged_translations_';
  static const String _cacheVersionKey = 'translation_cache_version';
  static const String _currentCacheVersion = '1.0';
  static const Duration _cacheValidDuration = Duration(hours: 24);

  /// Cache merged translations with metadata
  static Future<void> cacheTranslations(
    String language, 
    Map<String, String> translations,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cacheData = {
        'translations': translations,
        'timestamp': DateTime.now().toIso8601String(),
        'version': _currentCacheVersion,
        'language': language,
        'count': translations.length,
      };
      
      await prefs.setString(
        '$_cachePrefix$language',
        jsonEncode(cacheData),
      );
      
      // Update cache version
      await prefs.setString(_cacheVersionKey, _currentCacheVersion);

    } catch (e) {
//
    }
  }

  /// Get cached translations if valid
  static Future<Map<String, String>?> getCachedTranslations(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_cachePrefix$language');
      
      if (cached == null) {
        return null;
      }
      
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      
      // Check version compatibility
      if (cacheData['version'] != _currentCacheVersion) {
        await _removeCachedTranslations(language);
        return null;
      }
      
      // Check expiration
      final timestamp = DateTime.parse(cacheData['timestamp'] as String);
      final isExpired = DateTime.now().difference(timestamp) > _cacheValidDuration;
      
      if (isExpired) {
        await _removeCachedTranslations(language);
        return null;
      }
      
      final translations = Map<String, String>.from(
        cacheData['translations'] as Map<String, dynamic>
      );
      
      return translations;
    } catch (e) {
      return null;
    }
  }

  /// Check if cache is valid without loading data
  static Future<bool> hasValidCache(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_cachePrefix$language');
      
      if (cached == null) return false;
      
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      
      // Check version
      if (cacheData['version'] != _currentCacheVersion) return false;
      
      // Check expiration
      final timestamp = DateTime.parse(cacheData['timestamp'] as String);
      final isExpired = DateTime.now().difference(timestamp) > _cacheValidDuration;
      
      return !isExpired;
    } catch (e) {
      return false;
    }
  }

  /// Remove cached translations for specific language
  static Future<void> _removeCachedTranslations(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$language');
    } catch (e) {
//
    }
  }

  /// Clear all cached translations
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final translationKeys = keys.where((key) => key.startsWith(_cachePrefix));
      
      for (final key in translationKeys) {
        await prefs.remove(key);
      }
      
    } catch (e) {
//
    }
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final translationKeys = keys.where((key) => key.startsWith(_cachePrefix));
      final stats = <String, dynamic>{
        'cachedLanguages': [],
        'totalCachedItems': 0,
        'cacheVersion': _currentCacheVersion,
        'validCaches': 0,
        'expiredCaches': 0,
      };
      
      for (final key in translationKeys) {
        try {
          final language = key.replaceFirst(_cachePrefix, '');
          final cached = prefs.getString(key);
          
          if (cached != null) {
            final cacheData = jsonDecode(cached) as Map<String, dynamic>;
            final timestamp = DateTime.parse(cacheData['timestamp'] as String);
            final isExpired = DateTime.now().difference(timestamp) > _cacheValidDuration;
            final itemCount = (cacheData['count'] as int?) ?? 0;
            
            stats['cachedLanguages'].add({
              'language': language,
              'itemCount': itemCount,
              'timestamp': cacheData['timestamp'],
              'isExpired': isExpired,
              'version': cacheData['version'],
            });
            
            stats['totalCachedItems'] += itemCount;
            
            if (isExpired) {
              stats['expiredCaches']++;
            } else {
              stats['validCaches']++;
            }
          }
        } catch (e) {
//
        }
      }
      
      return stats;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get cache age for language
  static Future<Duration?> getCacheAge(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_cachePrefix$language');
      
      if (cached != null) {
        final cacheData = jsonDecode(cached) as Map<String, dynamic>;
        final timestamp = DateTime.parse(cacheData['timestamp'] as String);
        return DateTime.now().difference(timestamp);
      }
    } catch (e) {
//
    }
    return null;
  }
}
