import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:twad/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create grievance flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.byKey(Key('welcome_title')), findsOneWidget);

    await tester.tap(find.byKey(Key('create_grievance_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('new_grievance')),findsOneWidget);
    await tester.pumpAndSettle();


    await tester.tap(find.byKey(Key('submit_grievance_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('grievance_success_message')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(Key('welcome_title')), findsOneWidget);
  });
}
