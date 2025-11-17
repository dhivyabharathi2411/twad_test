import 'lib/core/translation/translation_manager.dart';

void debugLanguageState() {
  final manager = TranslationManager.instance;
  final stats = manager.getTranslationStats();
  


  // Test static translation
  final dashboard = manager.translate('dashboard');

  
  // Test a grievance title (if loaded dynamically)
  final grievance = manager.translate('BLOCKED DRAINAGE, SEWAGE OVERFLOW, BAD SMELL FROM DRAINS');

  
  // Test with spaces
  final grievanceWithSpaces = manager.translate(' BLOCKED DRAINAGE, SEWAGE OVERFLOW, BAD SMELL FROM DRAINS ');
}
