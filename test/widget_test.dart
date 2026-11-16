import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphics/graphics.dart';
import 'package:marg_sync_pro/main.dart';
import 'package:services/services.dart';

void main() {
  setUp(() async {
    await LocalStorage.instance.writeBool(
      StorageKeyConsts.isDealerLoggedIn,
      false,
    );
    await LocalStorage.instance.writeString(
      StorageKeyConsts.registeredDealersJson,
      '',
    );
  });

  testWidgets(
    '3-step registration with 5-digit PIN and login verification',
    (WidgetTester tester) async {
      await tester.pumpWidget(const DealerConnectApp());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DealerRegistrationCard), findsOneWidget);
      expect(find.text('Register & Set 5-Digit PIN'), findsOneWidget);

      // Step 1: Enter 10-digit mobile number and verify shop auto-fetch.
      final phoneField = find.byType(TextField).first;
      await tester.enterText(phoneField, '9163316261');
      await tester.pumpAndSettle();

      expect(find.text('Registered Marg Dealer Found'), findsOneWidget);
      expect(find.text('A.R.SHOE COLLECTION'), findsOneWidget);

      // Proceed to Step 2 (Set 5-Digit PIN).
      final registerBtn = find.text('Register & Set 5-Digit PIN');
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      expect(find.text('Create 5-Digit Security PIN'), findsOneWidget);
      expect(find.text('Save 5-Digit PIN'), findsOneWidget);

      // Step 2: Enter 5-digit PIN and save.
      final setPinField = find.byType(TextField).first;
      await tester.enterText(setPinField, '12345');
      await tester.pump();

      final savePinBtn = find.text('Save 5-Digit PIN');
      await tester.ensureVisible(savePinBtn);
      await tester.tap(savePinBtn);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      // Transitions to Step 3 (Login with Mobile Number & 5-Digit PIN).
      expect(find.text('Enter 5-Digit Security PIN'), findsOneWidget);
      expect(find.text('Login & Start Booking'), findsOneWidget);

      // Step 3a: Wrong 5-digit PIN should show error and block entry.
      final loginPinField = find.byType(TextField).last;
      await tester.enterText(loginPinField, '99999');
      await tester.pump();

      final loginBtn = find.text('Login & Start Booking');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Incorrect 5-digit PIN'), findsOneWidget);
      expect(find.text('Login & Start Booking'), findsOneWidget);

      // Step 3b: Correct 5-digit PIN should enter main app screen.
      await tester.enterText(loginPinField, '12345');
      await tester.pump();

      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login & Start Booking'), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );
}
