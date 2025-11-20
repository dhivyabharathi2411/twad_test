import 'package:flutter_test/flutter_test.dart';
import 'package:twad/services/login_service.dart';

void main() {
  late LoginService loginService;

  setUp(() {
    loginService = LoginService();
  });

  group('Login Logic Unit Tests', () {
    test('Phone number validation fails for invalid number', () async {
      final result = await loginService.sendOtp('123'); 
      expect(result.isSuccess, false);
      expect(result.message, 'Invalid phone number format');
    });

    test('OTP validation fails for invalid OTP', () async {
      final result = await loginService.verifyOtp(
        phoneNumber: '8787878787',
        otp: '12ab', 
      );
      expect(result.isSuccess, false);
      expect(result.message, 'Invalid OTP format');
    });

    test('Complete login flow returns a LoginResult', () async {
      final result = await loginService.completeLoginFlow(
        phoneNumber: '8787878787',
        otp: '123456', 
      );
      expect(result, isA<LoginResult>());
    });

    test('Parsing OTP from string works correctly', () {
      final otpString = 'Test OTP: 123456';
      final otp = otpString.split('Test OTP:')[1].trim();
      expect(otp, '123456');
    });
  });
}
