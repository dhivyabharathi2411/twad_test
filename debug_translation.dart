import 'lib/core/translation/translation_manager.dart';

void main() {
  // Test the TranslationManager directly
  final manager = TranslationManager.instance;
  
  // Test English
  manager.initialize('en');

  // Test Tamil
  manager.initialize('ta');  

}
