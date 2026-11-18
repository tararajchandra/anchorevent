import 'package:flutter_test/flutter_test.dart';
import 'package:services/services.dart';

void main() {
  test('RestApi isCloudConfigured is true by default', () {
    expect(RestApi.instance.isCloudConfigured, isTrue);
  });

  test('registerCloudDealerWithPin and pushBillHeader sync to Supabase', () async {
    const testPhone = '9999900001';
    final regResp = await RestApi.instance.registerCloudDealerWithPin(
      phone: testPhone,
      shopName: 'DART TEST SHOP',
      address: 'TEST LOCATION',
      pin: '54321',
    );
    expect(regResp.status.isSuccess, isTrue);

    // Verify pushing a bill header
    final billResp = await RestApi.instance.pushBillHeader(
      billNo: 'TEST-DART-BILL-001',
      billDate: '18/11/2026',
      createdTime: '11:45',
      partyName: 'DART TEST SHOP',
      deviceUuid: 'PHONE-$testPhone',
      salesmanName: testPhone,
      totalPairs: 12,
      totalAmount: 1200.0,
      items: <Map<String, dynamic>>[
        <String, dynamic>{
          'item_code': '3046',
          'product_name': '028 GRY 2X5',
          'company': 'AJANTA',
          'unit': 'PAIR',
          'qty_pairs': 12,
          'rate': 100.0,
          'mrp': 150.0,
        }
      ],
    );
    expect(billResp.status.isSuccess, isTrue);
  });
}
