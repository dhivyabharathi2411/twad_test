import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/translation_provider.dart';
import '../core/translation/app_translation_initializer.dart';

/// Example widget showing how to use the Translation System
class TranslationExampleWidget extends StatelessWidget {
  const TranslationExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('dashboard')), // Global translation function
        actions: [
          // Language switcher
          PopupMenuButton<String>(
            onSelected: (language) {
              AppTranslationInitializer.switchLanguage(language);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'ta', child: Text('தமிழ்')),
            ],
          ),
        ],
      ),
      body: Consumer<TranslationProvider>(
        builder: (context, translationProvider, child) {
          return Column(
            children: [
              // Loading indicator
              if (translationProvider.isLoading)
                const LinearProgressIndicator(),
              
              // Error display
              if (translationProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.shade100,
                  child: Text(
                    translationProvider.error!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              
              // Translation examples
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Using provider method
                    Card(
                      child: ListTile(
                        title: Text(translationProvider.translate('welcome')),
                        subtitle: Text('Static translation'),
                        leading: const Icon(Icons.translate),
                      ),
                    ),
                    
                    // Using global function
                    Card(
                      child: ListTile(
                        title: Text(tr('recentCardstitle')),
                        subtitle: Text('Static translation (global function)'),
                        leading: const Icon(Icons.recent_actors),
                      ),
                    ),
                    
                    // Dynamic translation from API
                    Card(
                      child: ListTile(
                        title: Text(tr('KILMURUNGAI')), // Will show "கீழ்முருங்கை" in Tamil
                        subtitle: Text('Dynamic translation from API'),
                        leading: const Icon(Icons.location_on),
                      ),
                    ),
                    
                    // Fallback example
                    Card(
                      child: ListTile(
                        title: Text(tr('unknown_key')), // Will show "unknown_key"
                        subtitle: Text('Fallback to key when translation not found'),
                        leading: const Icon(Icons.help_outline),
                      ),
                    ),
                    
                    // Language info
                    Card(
                      child: ListTile(
                        title: Text('Current Language: ${translationProvider.currentLanguage}'),
                        subtitle: Text('Initialized: ${translationProvider.isInitialized}'),
                        leading: const Icon(Icons.language),
                      ),
                    ),
                    
                    // Action buttons
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => translationProvider.refreshTranslations(),
                            child: Text(tr('retry')),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => translationProvider.clearCache(),
                            child: const Text('Clear Cache'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Extension for easy translation access in any widget
extension TranslationContext on BuildContext {
  String translate(String key) {
    return Provider.of<TranslationProvider>(this, listen: false).translate(key);
  }
}
