import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:twad/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Splash -> Login -> Dashboard -> Logout', (tester) async {
    await tester.pumpWidget(TWADApp());

    await tester.pumpAndSettle();

    expect(find.byKey(Key('splash_logo')), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('app_title')), findsOneWidget);

  
    await tester.enterText(find.byKey(Key('login_mobile_field')), '8787878787');
    await tester.tap(find.byKey(Key('otp_button')));
    await tester.pumpAndSettle();

    final otpTextFinder = find.textContaining('Test OTP:');
    expect(otpTextFinder, findsOneWidget);

    final otpTextWidget = otpTextFinder.evaluate().single.widget as Text;
    final otp = otpTextWidget.data!.split('Test OTP:')[1].trim();

    await tester.enterText(find.byType(TextField), otp);
    await tester.tap(find.byKey(Key('signin_button')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byKey(Key('welcome_title')), findsOneWidget);
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byKey(Key('app_title')), findsOneWidget);
  });
}
