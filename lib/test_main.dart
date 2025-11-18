import 'package:flutter/material.dart';
import 'package:twad/pages/login_page.dart';
import 'pages/splash_screen.dart';

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginPage(),
      },
    );
  }
}

void testMain() {
  runApp(const TestApp());
}
