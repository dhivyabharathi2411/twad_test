import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/error/exceptions.dart';

/// Local storage interface
abstract class LocalStorage {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> saveMap(String key, Map<String, dynamic> value);
  Future<Map<String, dynamic>?> getMap(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
}

/// Local storage implementation using SharedPreferences
class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _prefs;

  LocalStorageImpl(this._prefs);

  @override
  Future<void> saveString(String key, String value) async {
    try {
      final success = await _prefs.setString(key, value);
      if (!success) {
        throw CacheException.writeError('Failed to save string for key: $key');
      }
    } catch (e) {
      throw CacheException.writeError('Error saving string: ${e.toString()}');
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw CacheException('Error reading string: ${e.toString()}', 'CACHE_READ_ERROR');
    }
  }

  @override
  Future<void> saveInt(String key, int value) async {
    try {
      final success = await _prefs.setInt(key, value);
      if (!success) {
        throw CacheException.writeError('Failed to save int for key: $key');
      }
    } catch (e) {
      throw CacheException.writeError('Error saving int: ${e.toString()}');
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      throw CacheException('Error reading int: ${e.toString()}', 'CACHE_READ_ERROR');
    }
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    try {
      final success = await _prefs.setBool(key, value);
      if (!success) {
        throw CacheException.writeError('Failed to save bool for key: $key');
      }
    } catch (e) {
      throw CacheException.writeError('Error saving bool: ${e.toString()}');
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      throw CacheException('Error reading bool: ${e.toString()}', 'CACHE_READ_ERROR');
    }
  }

  @override
  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      await saveString(key, jsonString);
    } catch (e) {
      throw CacheException.writeError('Error saving map: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>?> getMap(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;
      
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException('Error reading map: ${e.toString()}', 'CACHE_READ_ERROR');
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      throw CacheException('Error removing key: ${e.toString()}', 'CACHE_REMOVE_ERROR');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e) {
      throw CacheException('Error clearing cache: ${e.toString()}', 'CACHE_CLEAR_ERROR');
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      throw CacheException('Error checking key: ${e.toString()}', 'CACHE_CHECK_ERROR');
    }
  }
}

/// Storage keys constants
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String user = 'user';
  static const String isLoggedIn = 'is_logged_in';
  static const String lastLoginTime = 'last_login_time';
  static const String appSettings = 'app_settings';
  static const String cacheVersion = 'cache_version';
}
