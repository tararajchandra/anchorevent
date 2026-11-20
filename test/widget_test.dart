import 'dart:convert';

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

  testWidgets(
    'rapid article QR detections open one sheet and size badge fits cleanly',
    (WidgetTester tester) async {
      await LocalStorage.instance.writeBool(
        StorageKeyConsts.isDealerLoggedIn,
        true,
      );
      await LocalStorage.instance.writeString(
        StorageKeyConsts.activeShopName,
        'AJANTA SHOE',
      );
      await LocalStorage.instance.writeString(
        StorageKeyConsts.activeDealerPhone,
        '9883433169',
      );
      final mappingsJson = jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{
          'article_no': '5221',
          'brand': 'N FASHION (JA TRADERS)',
          'qr_payload': 'MARG_ART:N FASHION (JA TRADERS)|5221',
          'variants': <Map<String, dynamic>>[
            <String, dynamic>{
              'item_code': '5221-LG-6X10',
              'color': 'L. GRY/ BK',
              'size': '6X10',
              'rate': 220.0,
              'mrp': 220.0,
            },
            <String, dynamic>{
              'item_code': '5221-WB-6X9',
              'color': 'WHT/BLK',
              'size': '6X9',
              'rate': 245.0,
              'mrp': 245.0,
            },
          ],
        },
      ]);
      await LocalStorage.instance.writeString(
        StorageKeyConsts.articleQrMappingsJson,
        mappingsJson,
      );
      addTearDown(() async {
        await LocalStorage.instance.writeString(
          StorageKeyConsts.articleQrMappingsJson,
          '',
        );
      });

      await tester.pumpWidget(const DealerConnectApp());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(GraphicsStringConsts.navScan));
      await tester.pumpAndSettle();

      final mapping = MasterDataHandler.instance.lookupArticleQrMapping(
        'MARG_ART:N FASHION (JA TRADERS)|5221',
      );
      expect(mapping, isNotNull);

      final viewfinder = tester.widget<ScannerViewfinderCard>(
        find.byType(ScannerViewfinderCard),
      );

      for (var i = 0; i < 6; i++) {
        viewfinder.onBarcodeDetected('MARG_ART:N FASHION (JA TRADERS)|5221');
      }
      await tester.pump();
      expect(
        tester
            .widget<ScannerViewfinderCard>(find.byType(ScannerViewfinderCard))
            .isShutterClosed,
        isTrue,
      );
      await tester.pumpAndSettle();

      expect(find.byType(ArticleVariantSelectionSheet), findsOneWidget);
      expect(find.text('Size: 6X10'), findsOneWidget);
      expect(find.text('Size: 6X9'), findsOneWidget);

      final updatedViewfinder = tester.widget<ScannerViewfinderCard>(
        find.byType(ScannerViewfinderCard),
      );
      expect(updatedViewfinder.isShutterClosed, isTrue);

      final sizeContainer = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Size: 6X10'),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = sizeContainer.decoration as BoxDecoration?;
      expect(decoration?.color, GraphicsColorConsts.backgroundLight);

      final submitBtn = find.text('Submit Order');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.byType(ArticleVariantSelectionSheet), findsNothing);
      expect(find.textContaining('2 Items (24 Pairs)'), findsOneWidget);

      final postSubmitViewfinder = tester.widget<ScannerViewfinderCard>(
        find.byType(ScannerViewfinderCard),
      );
      expect(postSubmitViewfinder.isShutterClosed, isFalse);

      postSubmitViewfinder
          .onBarcodeDetected('MARG_ART:N FASHION (JA TRADERS)|5221');
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(ArticleVariantSelectionSheet), findsNothing);
    },
  );

  testWidgets(
    'ArticleVariantSelectionSheet lays out cleanly at 360px phone width',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360.0, 780.0);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final variants = <ArticleVariantBookingItem>[
        ArticleVariantBookingItem(
          itemCode: '5221-LG-6X10',
          color: 'L. GRY/ BK',
          size: '6X10',
          rate: 220.0,
          mrp: 220.0,
          company: 'N FASHION (JA TRADERS)',
          productName: '5221 L. GRY/ BK 6X10',
        ),
        ArticleVariantBookingItem(
          itemCode: '5221-WB-6X9',
          color: 'WHT/BLK',
          size: '6X9',
          rate: 245.0,
          mrp: 245.0,
          company: 'N FASHION (JA TRADERS)',
          productName: '5221 WHT/BLK 6X9',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: GraphicsTheme.lightTheme,
          home: Scaffold(
            body: ArticleVariantSelectionSheet(
              brand: 'N FASHION (JA TRADERS)',
              articleNo: '5221',
              initialVariants: variants,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Size: 6X10'), findsOneWidget);
      expect(find.text('L. GRY/ BK'), findsOneWidget);
      expect(find.text('Submit Order'), findsOneWidget);
    },
  );

  testWidgets(
    'orders and schemes stay isolated per logged-in retailer with unique billNo',
    (WidgetTester tester) async {
      const sampleItem = BillItemEntity(
        itemCode: '5221-LG-6X10',
        barcode: '5221-LG-6X10',
        productName: '5221 L. GRY/ BK 6X10',
        company: 'N FASHION (JA Traders)',
        unit: 'PAIR',
        qtyPairs: 12,
        rate: 220.0,
        mrp: 220.0,
      );

      final respA = await BillingHandler.instance.createAndSaveBill(
        partyName: 'ALPONA SHOE HOUSE',
        deviceUuid: 'PHONE-7063326901',
        salesmanName: '7063326901',
        cartItems: const <BillItemEntity>[sampleItem],
      );
      final respB = await BillingHandler.instance.createAndSaveBill(
        partyName: 'MAA TARA FOOTWEAR',
        deviceUuid: 'PHONE-9876543210',
        salesmanName: '9876543210',
        cartItems: <BillItemEntity>[sampleItem.copyWithQty(24)],
      );

      final billA = respA.data;
      final billB = respB.data;
      expect(billA, isNotNull);
      expect(billB, isNotNull);
      expect(billA?.billNo, startsWith('ORD-6901-001-'));
      expect(billB?.billNo, startsWith('ORD-3210-001-'));
      expect(billA?.billNo, isNot(equals(billB?.billNo)));

      final aOrders = BillingHandler.instance.getSavedBillsForRetailer(
        phone: '7063326901',
        partyName: 'ALPONA SHOE HOUSE',
      );
      final bOrders = BillingHandler.instance.getSavedBillsForRetailer(
        phone: '9876543210',
        partyName: 'MAA TARA FOOTWEAR',
      );
      expect(aOrders.length, 1);
      expect(aOrders.first.totalPairs, 12);
      expect(bOrders.length, 1);
      expect(bOrders.first.totalPairs, 24);

      await LocalStorage.instance.writeBool(
        StorageKeyConsts.isDealerLoggedIn,
        true,
      );
      await LocalStorage.instance.writeString(
        StorageKeyConsts.activeShopName,
        'ALPONA SHOE HOUSE',
      );
      await LocalStorage.instance.writeString(
        StorageKeyConsts.activeDealerPhone,
        '7063326901',
      );

      await tester.pumpWidget(const DealerConnectApp());
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      await tester.pumpAndSettle();

      expect(find.text('12 / 100 Pairs'), findsOneWidget);
      expect(find.textContaining('Booked: 12 Pairs'), findsOneWidget);
      expect(find.text('24 / 100 Pairs'), findsNothing);
      expect(find.textContaining('Booked: 24 Pairs'), findsNothing);

      await tester.tap(find.text(GraphicsStringConsts.navMyOrders));
      await tester.pumpAndSettle();
      expect(find.text('12 Prs'), findsOneWidget);
      expect(find.text('24 Prs'), findsNothing);

      await tester.tap(find.text(GraphicsStringConsts.navSchemes));
      await tester.pumpAndSettle();
      expect(find.text('12 Pairs'), findsOneWidget);
      expect(find.text('24 Pairs'), findsNothing);
    },
  );
}
