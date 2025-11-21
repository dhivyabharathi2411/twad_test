import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:twad/main.dart';
import 'package:twad/services/login_service.dart';
import 'package:twad/services/api_setup.dart';
import 'package:twad/utils/simple_encryption.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Real API Login Tests', () {
    late LoginService loginService;
    const String testPhoneNumber = '8787878787';

    setUpAll(() async {
      await ApiSetup.initializeApiClient();
      loginService = LoginService();
    });

    testWidgets('Real API - Send OTP to valid phone number', (tester) async {
      await tester.pumpWidget(TWADApp());
      await tester.pumpAndSettle();
      final otpResult = await loginService.sendOtp(testPhoneNumber);
      
      expect(otpResult.isSuccess, isTrue, reason: 'OTP should be sent successfully to valid number');
      expect(otpResult.message, isNotNull, reason: 'API should return a message');
    });

    testWidgets('Real API - Complete login flow with real API calls', (tester) async {
      await tester.pumpWidget(TWADApp());
      await tester.pumpAndSettle();

      final otpResult = await loginService.sendOtp(testPhoneNumber);
      expect(otpResult.isSuccess, isTrue, reason: 'OTP sending should succeed');

      expect(find.byKey(Key('splash_logo')), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('app_title')), findsOneWidget);
      await tester.enterText(find.byKey(Key('login_mobile_field')), testPhoneNumber);
      await tester.tap(find.byKey(Key('otp_button')));
      await tester.pumpAndSettle();

      final otpTextFinder = find.textContaining('Test OTP:');
      expect(otpTextFinder, findsOneWidget);

      final otpTextWidget = otpTextFinder.evaluate().single.widget as Text;
      final otp = otpTextWidget.data!.split('Test OTP:')[1].trim();

      final verifyResult = await loginService.verifyOtp(
        phoneNumber: testPhoneNumber,
        otp: otp,
      );
      expect(verifyResult.isSuccess, isTrue, reason: 'OTP verification should succeed with real API');

      final loginResult = await loginService.completeLoginFlow(
        phoneNumber: testPhoneNumber,
        otp: otp,
      );
      expect(loginResult.isSuccess, isTrue, reason: 'Complete login flow should succeed');
      expect(loginResult.data, isNotNull, reason: 'Login should return user data');

      await tester.enterText(find.byType(TextField), otp);
      await tester.tap(find.byKey(Key('signin_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byKey(Key('welcome_title')), findsOneWidget);
      final currentUser = await SimpleUsage.getCurrentUser();
      expect(currentUser, isNotNull, reason: 'User should be stored after successful login');
      expect(currentUser!['contactno'], equals(testPhoneNumber), reason: 'Stored contact should match login contact');
    });

    testWidgets('Real API - Invalid phone number validation', (tester) async {
      await tester.pumpWidget(TWADApp());
      await tester.pumpAndSettle();

      final invalidNumbers = ['123', '12345', 'abc123', ''];
      
      for (final invalidNumber in invalidNumbers) {
        final result = await loginService.sendOtp(invalidNumber);
        expect(result.isSuccess, isFalse, reason: 'Invalid number $invalidNumber should fail');
      }
    });

    testWidgets('Real API - Invalid OTP validation', (tester) async {
      await tester.pumpWidget(TWADApp());
      await tester.pumpAndSettle();
      final invalidOtps = ['123', '12ab', 'invalid', ''];
      
      for (final invalidOtp in invalidOtps) {
        final result = await loginService.verifyOtp(
          phoneNumber: testPhoneNumber,
          otp: invalidOtp,
        );
        expect(result.isSuccess, isFalse, reason: 'Invalid OTP $invalidOtp should fail');
      }
    });
  });
}
