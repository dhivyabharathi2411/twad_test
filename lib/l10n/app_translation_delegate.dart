import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/translation/translation_manager.dart';

/// Master-level Translation Delegate that combines static + dynamic translations
/// This integrates with Flutter's localization system seamlessly
class AppTranslationDelegate extends LocalizationsDelegate<AppTranslations> {
  const AppTranslationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ta'].contains(locale.languageCode);

  @override
  Future<AppTranslations> load(Locale locale) async {
    final translations = AppTranslations(locale);
    await translations._load();
    return translations;
  }

  @override
  bool shouldReload(AppTranslationDelegate old) => false;
}

/// Master Translation Class - Combines static + dynamic seamlessly
class AppTranslations {
  final Locale locale;
  
  AppTranslations(this.locale);

  /// The magic method - works for both static and dynamic translations
  String translate(String key) {
    return TranslationManager.instance.translate(key, language: locale.languageCode);
  }

  /// Shorter alias
  String tr(String key) => translate(key);

  /// Load translations (called automatically by delegate)
  Future<void> _load() async {
    // Initialize TranslationManager for this locale
    TranslationManager.instance.initialize(locale.languageCode);
  }

  // Static translations (for existing localizations compatibility)
  String get grievanceCardComplaintno => translate('grievanceCardComplaintno');
  String get welcome => translate('welcome');
  String get dashboard => translate('dashboard');
  String get totalGrievances => translate('totalGrievances');
  String get grievancesInProgress => translate('grievancesInProgress');
  String get grievancesClosed => translate('grievancesClosed');
  String get addGrievance => translate('addGrievance');
  String get noRecentGrievances => translate('noRecentGrievances');
  String get unableToLoadStatistics => translate('unableToLoadStatistics');
  String get pleaseTryAgainLater => translate('pleaseTryAgainLater');
  String get retry => translate('retry');
  String get featureComingSoon => translate('featureComingSoon');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get recentCardstitle => translate('recentCardstitle');

  /// Static accessor for current instance
  static AppTranslations? _current;
  static AppTranslations of(BuildContext context) {
    return Localizations.of<AppTranslations>(context, AppTranslations) ??
           _current ??
           AppTranslations(const Locale('en'));
  }
}
