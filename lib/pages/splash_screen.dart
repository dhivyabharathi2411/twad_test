import 'package:flutter/material.dart';
import '../utils/simple_encryption.dart';
import 'home_screen.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () async {
      bool isLoggedIn = false;
      try {
        isLoggedIn = await SimpleUsage.checkLogin();
      } catch (e) {
        isLoggedIn = false;
      }
      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
       Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/twad_logo.png',
            height: 120,
            fit: BoxFit.contain,
            key: const Key('splash_logo'),
          ),
        ],
      ),
    ),
  );
}
}
