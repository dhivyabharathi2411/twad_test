import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/translation_provider.dart';

/// Global translation function for easy access
String tr(String key, [BuildContext? context]) {
  if (context != null) {
    try {
      final provider = Provider.of<TranslationProvider>(context, listen: false);
      return provider.translate(key);
    } catch (e) {
      // Fallback if provider not found
      return key;
    }
  }
  // Fallback: return the key itself
  return key;
}

/// Extension for easier translation access on BuildContext
extension TranslationExtension on BuildContext {
  /// Translate a key using the context
  String translate(String key) {
    try {
      final provider = Provider.of<TranslationProvider>(this, listen: false);
      return provider.translate(key);
    } catch (e) {
      // Fallback if provider not found
      return key;
    }
  }
  
  /// Shorter version for translation
  String tr(String key) => translate(key);
}
