import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:twad/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Splash -> Login -> Dashboard -> Logout', (tester) async {
      app.main();
      await tester.pump();               
      await tester.pump(const Duration(seconds: 1)); 
      expect(find.byKey(Key('splash_logo')), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byKey(Key('app_title')), findsOneWidget);
      await tester.enterText(find.byKey(Key('login_mobile_field')), '8787878787');
      await tester.tap(find.byKey(Key('otp_button')),);
      await tester.pumpAndSettle();
      final otpTextFinder = find.textContaining('Test OTP:');
      expect(otpTextFinder, findsOneWidget);

      final otpText = otpTextFinder.evaluate().single.widget as Text;
      final otp = otpText.data!.split('Test OTP:')[1].trim();

      await tester.enterText(find.byType(TextField), otp);
      await tester.tap(find.byKey(Key('signin_button'))); 
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byKey(Key('welcome_title')),findsOneWidget);
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle(const Duration(seconds: 20));
      expect(find.byKey(Key('app_title')), findsOneWidget);
  });
}
