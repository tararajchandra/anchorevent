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

  testWidgets(
    'new dealer registration with manual shop name should proceed on single click',
    (WidgetTester tester) async {
      await tester.pumpWidget(const DealerConnectApp());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      await tester.pumpAndSettle();

      // Enter unknown new phone number
      final phoneField = find.byKey(const ValueKey<String>('input_Mobile Number'));
      await tester.enterText(phoneField, '9830450252');
      await tester.pumpAndSettle();

      expect(find.text('New Dealer Registration'), findsOneWidget);

      // Enter manual shop name and address
      final shopField = find.byKey(const ValueKey<String>('input_Shop / Business Name'));
      final addrField = find.byKey(const ValueKey<String>('input_Shop Address / Market'));
      await tester.enterText(shopField, 'demo1');
      await tester.enterText(addrField, 'pandua');
      await tester.pump();

      // Tap Register on first click - should immediately proceed to Set 5-Digit PIN
      final registerBtn = find.text('Register & Set 5-Digit PIN');
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      // Should NOT show the error banner "Please enter your Shop / Business Name."
      expect(find.text('Please enter your Shop / Business Name.'), findsNothing);
      expect(find.text('Create 5-Digit Security PIN'), findsOneWidget);
    },
  );

  testWidgets(
    'scanner closes shutter on product detection and reopens on Add Pairs',
    (WidgetTester tester) async {
      await LocalStorage.instance.writeBool(
        StorageKeyConsts.isDealerLoggedIn,
        true,
      );
      await LocalStorage.instance.writeString(
        StorageKeyConsts.activeShopName,
        'DEMO1',
      );
      await LocalStorage.instance.writeString(
        StorageKeyConsts.activeDealerPhone,
        '9830450252',
      );

      await tester.pumpWidget(const DealerConnectApp());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      await tester.pumpAndSettle();

      // Navigate to Scan & Book tab
      final scanTab = find.text(GraphicsStringConsts.navScan);
      await tester.tap(scanTab);
      await tester.pumpAndSettle();

      // Shutter should initially be open
      expect(find.text(GraphicsStringConsts.shutterScannedBadge), findsNothing);

      // Simulate scanning a known shoe box
      final testScanBtn = find.text(GraphicsStringConsts.scanKnownSampleBtn);
      await tester.ensureVisible(testScanBtn);
      await tester.tap(testScanBtn);
      await tester.pumpAndSettle();

      // Shutter closes and shows scanned confirmation + rescan button
      expect(
        find.text(GraphicsStringConsts.shutterScannedBadge),
        findsOneWidget,
      );
      expect(find.text(GraphicsStringConsts.shutterRescanBtn), findsOneWidget);
      expect(find.text('Add Pairs'), findsOneWidget);

      // Tap "+ Add Pairs" -> adds to cart, hides stepper card, reopens shutter
      final addPairsBtn = find.text('Add Pairs');
      await tester.ensureVisible(addPairsBtn);
      await tester.tap(addPairsBtn);
      await tester.pumpAndSettle();

      expect(find.text(GraphicsStringConsts.shutterScannedBadge), findsNothing);
      expect(find.text('Add Pairs'), findsNothing);
      expect(find.textContaining('1 Items (12 Pairs)'), findsOneWidget);
    },
  );
}
