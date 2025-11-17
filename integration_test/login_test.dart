import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:twad/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Splash -> Login -> Dashboard -> Logout', (tester) async {
      app.main();
      await tester.pump();
      expect(find.byKey(Key('splash_logo')), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byKey(Key('app_title')), findsOneWidget);
      await tester.enterText(find.byKey(Key('login_mobile_field')), '8787878787');
      await tester.tap(find.byKey(Key('otp_button')),);
      await tester.pumpAndSettle();
  });
}
