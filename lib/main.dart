import 'package:twad/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twad/pages/profile/profile_provider.dart';
import 'package:twad/presentation/providers/file_upload_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:twad/presentation/providers/locale_provider.dart';
import 'package:twad/presentation/providers/maintenance_provider.dart';
import 'constants/app_constants.dart';
import 'presentation/providers/acknowledgement_provider.dart';
import 'presentation/providers/contact_provider.dart';
import 'presentation/providers/feedback_provider.dart';
import 'presentation/providers/grievance_provider.dart';
import 'presentation/providers/master_list_provider.dart';
import 'presentation/providers/organization_provider.dart';
import 'presentation/providers/translation_provider.dart';
import 'core/translation/app_translation_initializer.dart';
import 'services/api_setup.dart';
import 'utils/simple_encryption.dart';
import 'utils/fast_encryption_service.dart';
import 'injection_container.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/smart_dropdown_manager.dart';
import 'api/api_client.dart';
import 'pages/login_page.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleUsage.initialize();
  await FastEncryptionService.initialize();
  
  await ApiSetup.initializeApiClient(
    defaultAccessToken:
        'your_twad_api_key_here', 
  );
  ApiClient.setInvalidTokenCallback(() {
    _handleGlobalLogout();
  });
  
  await ServiceLocator.instance.init();
  
  await AppTranslationInitializer.initialize();
  
  runApp(const TWADApp());
}
void _handleGlobalLogout() {
  SimpleUsage.logout();
  if (navigatorKey.currentState != null) {
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  } else {
  }
}

class TWADApp extends StatelessWidget {
  const TWADApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider<GrievanceProvider>(
          create: (_) => GrievanceProvider(),
        ),
        ChangeNotifierProvider<MasterListProvider>(
          create: (_) => MasterListProvider(),
        ),
        ChangeNotifierProvider<MaintenanceProvider>(
          create: (_) => MaintenanceProvider(),
        ),
        ChangeNotifierProvider<FeedbackProvider>(
          create: (_) => FeedbackProvider(),
        ),
        ChangeNotifierProvider<AcknowledgementProvider>(
          create: (_) => AcknowledgementProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider<SmartDropdownManager>(
          create: (context) => SmartDropdownManager(
            Provider.of<MasterListProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<UploadProvider>(
          create: (_) => UploadProvider(),
        ),
        ChangeNotifierProvider<OrganizationProvider>(
          create: (_) => OrganizationProvider(),
        ),
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) {
            final provider = LocaleProvider();
            provider.initialize(); 
            return provider;
          },
        ),
        ChangeNotifierProvider<TranslationProvider>(
          create: (_) => AppTranslationInitializer.translationProvider,
        ),
        ChangeNotifierProvider<ContactProfileProvider>(
          create: (_) => ContactProfileProvider(),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey, 
            title: AppConstants.appName,
            locale: localeProvider.locale,
            supportedLocales: const [Locale('en'), Locale('ta')],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/login': (context) => const LoginPage(),
            },
            
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4.0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.black26,
        foregroundColor: Colors.black87,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4.0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.black87,
        shadowColor: Colors.white24,
        foregroundColor: Colors.white,
      ),
    );
  }
}
