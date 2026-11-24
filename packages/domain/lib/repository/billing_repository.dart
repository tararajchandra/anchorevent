import 'dart:async';
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

  List<SalesBillEntity> getSavedBillsForRetailer({
    required String phone,
    required String partyName,
  }) {
    _ensureLoadedFromStorage();
    return List<SalesBillEntity>.unmodifiable(
      _savedBills.where(
        (SalesBillEntity bill) => bill.belongsToRetailer(
          phone: phone,
          partyName: partyName,
        ),
      ),
    );
  }

  Future<List<SalesBillEntity>> syncRetailerBillsFromCloud({
    required String phone,
    required String partyName,
  }) async {
    _ensureLoadedFromStorage();
    final resp = await RestApi.instance.fetchCloudBillsForRetailer(
      phone: phone,
      partyName: partyName,
    );
    final cloudRows = resp.data;
    if (cloudRows != null && cloudRows.isNotEmpty) {
      var changed = false;
      for (final row in cloudRows) {
        final cloudBill = SalesBillEntity.fromJson(row);
        if (cloudBill.billNo.isEmpty) {
          continue;
        }
        final existingIdx = _savedBills.indexWhere(
          (SalesBillEntity b) =>
              b.billNo == cloudBill.billNo &&
              b.belongsToRetailer(phone: phone, partyName: partyName),
        );
        if (existingIdx < 0) {
          _savedBills.add(cloudBill);
          changed = true;
        } else if (cloudBill.items.isNotEmpty &&
            _savedBills[existingIdx].items.isEmpty) {
          _savedBills[existingIdx] = cloudBill;
          changed = true;
        }
      }
      if (changed) {
        await _persistBillsToStorage();
      }
    }
    return getSavedBillsForRetailer(phone: phone, partyName: partyName);
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

    final retailerBills = getSavedBillsForRetailer(
      phone: salesmanName,
      partyName: partyName,
    );
    final nextSeq = retailerBills.length + 1;
    final newBill = SalesBillConverter.createNewBill(
      sequenceNumber: nextSeq,
      partyName: partyName,
      deviceUuid: deviceUuid,
      salesmanName: salesmanName,
      cartItems: cartItems,
    );
    _savedBills.insert(0, newBill);
    await _persistBillsToStorage();

    unawaited(
      RestApi.instance.pushBillHeader(
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
      ),
    );

    return ServiceResponse<SalesBillEntity>.success(data: newBill);
  }

  Future<ServiceResponse<SalesBillEntity>> updateBill({
    required SalesBillEntity updatedBill,
  }) async {
    _ensureLoadedFromStorage();
    if (updatedBill.items.isEmpty) {
      await deleteBill(
        billNo: updatedBill.billNo,
        phone: updatedBill.retailerPhone,
        partyName: updatedBill.partyName,
      );
      return ServiceResponse<SalesBillEntity>.success(data: updatedBill);
    }

    final idx = _savedBills.indexWhere(
      (SalesBillEntity b) =>
          b.billNo == updatedBill.billNo &&
          b.belongsToRetailer(
            phone: updatedBill.retailerPhone,
            partyName: updatedBill.partyName,
          ),
    );
    if (idx < 0) {
      return ServiceResponse<SalesBillEntity>.error(
        message: 'Order ${updatedBill.billNo} not found.',
      );
    }

    _savedBills[idx] = updatedBill;
    await _persistBillsToStorage();

    unawaited(
      RestApi.instance.updateCloudBill(
        billNo: updatedBill.billNo,
        billDate: updatedBill.billDate,
        createdTime: updatedBill.createdTime,
        partyName: updatedBill.partyName,
        deviceUuid: updatedBill.deviceUuid,
        salesmanName: updatedBill.salesmanName,
        totalPairs: updatedBill.totalPairs,
        totalAmount: updatedBill.totalAmount,
        items: updatedBill.items
            .map((BillItemEntity item) => item.toJson())
            .toList(),
      ),
    );

    return ServiceResponse<SalesBillEntity>.success(data: updatedBill);
  }

  Future<ServiceResponse<bool>> deleteBill({
    required String billNo,
    required String phone,
    required String partyName,
  }) async {
    _ensureLoadedFromStorage();
    final idx = _savedBills.indexWhere(
      (SalesBillEntity b) =>
          b.billNo == billNo &&
          b.belongsToRetailer(phone: phone, partyName: partyName),
    );
    if (idx < 0) {
      return ServiceResponse<bool>.error(
        message: 'Order $billNo not found.',
      );
    }

    _savedBills.removeAt(idx);
    await _persistBillsToStorage();

    unawaited(RestApi.instance.deleteCloudBill(billNo: billNo));
    return ServiceResponse<bool>.success(data: true);
  }

  String generateMargExportCsv({
    String phone = '',
    String partyName = '',
  }) {
    _ensureLoadedFromStorage();
    if (phone.trim().isNotEmpty || partyName.trim().isNotEmpty) {
      final filtered = getSavedBillsForRetailer(
        phone: phone,
        partyName: partyName,
      );
      return SalesBillConverter.toMargImportCsv(filtered);
    }
    return SalesBillConverter.toMargImportCsv(_savedBills);
  }
}
