import 'dart:convert';

import 'package:services/services.dart';

import '../models/billing/converter/sales_bill_converter.dart';
import '../models/billing/entity/bill_item_entity.dart';
import '../models/billing/entity/sales_bill_entity.dart';

class BillingRepository {
  BillingRepository._();

  static final BillingRepository instance = BillingRepository._();
  static const String _storageKeyBills = 'marg_saved_bills_store_v1';

  final List<SalesBillEntity> _savedBills = <SalesBillEntity>[];
  bool _hasLoadedFromStorage = false;

  void _ensureLoadedFromStorage() {
    if (_hasLoadedFromStorage) {
      return;
    }
    _hasLoadedFromStorage = true;
    final storedJsonList =
        LocalStorage.instance.readStringList(_storageKeyBills);
    _savedBills.clear();
    for (final jsonStr in storedJsonList) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          _savedBills.add(SalesBillEntity.fromJson(decoded));
        }
      } catch (_) {
        // Skip malformed bill entry gracefully
      }
    }
  }

  Future<void> _persistBillsToStorage() async {
    final jsonList = _savedBills
        .map((SalesBillEntity bill) => jsonEncode(bill.toJson()))
        .toList();
    await LocalStorage.instance.writeStringList(_storageKeyBills, jsonList);
  }

  List<SalesBillEntity> getSavedBills() {
    _ensureLoadedFromStorage();
    return List<SalesBillEntity>.unmodifiable(_savedBills);
  }

  Future<ServiceResponse<SalesBillEntity>> saveBill({
    required String partyName,
    required String deviceUuid,
    required String salesmanName,
    required List<BillItemEntity> cartItems,
  }) async {
    _ensureLoadedFromStorage();
    if (cartItems.isEmpty) {
      return ServiceResponse<SalesBillEntity>.error(
        message: 'Cannot save an empty booking cart.',
      );
    }

    final nextSeq = _savedBills.length + 1;
    final newBill = SalesBillConverter.createNewBill(
      sequenceNumber: nextSeq,
      partyName: partyName,
      deviceUuid: deviceUuid,
      salesmanName: salesmanName,
      cartItems: cartItems,
    );
    _savedBills.insert(0, newBill);
    await _persistBillsToStorage();

    await RestApi.instance.pushBillHeader(
      billNo: newBill.billNo,
      billDate: newBill.billDate,
      createdTime: newBill.createdTime,
      partyName: newBill.partyName,
      deviceUuid: newBill.deviceUuid,
      salesmanName: newBill.salesmanName,
      totalPairs: newBill.totalPairs,
      totalAmount: newBill.totalAmount,
      items: newBill.items
          .map((BillItemEntity item) => item.toJson())
          .toList(),
    );

    return ServiceResponse<SalesBillEntity>.success(data: newBill);
  }

  String generateMargExportCsv() {
    _ensureLoadedFromStorage();
    return SalesBillConverter.toMargImportCsv(_savedBills);
  }
}
