import 'package:services/services.dart';

import '../models/billing/entity/bill_item_entity.dart';
import '../models/billing/entity/sales_bill_entity.dart';
import '../repository/billing_repository.dart';

class BillingHandler with ServiceStateMixin<List<SalesBillEntity>> {
  BillingHandler._();

  static final BillingHandler instance = BillingHandler._();

  List<SalesBillEntity> getSavedBills() {
    return BillingRepository.instance.getSavedBills();
  }

  List<SalesBillEntity> getSavedBillsForRetailer({
    required String phone,
    required String partyName,
  }) {
    return BillingRepository.instance.getSavedBillsForRetailer(
      phone: phone,
      partyName: partyName,
    );
  }

  Future<List<SalesBillEntity>> syncRetailerBillsFromCloud({
    required String phone,
    required String partyName,
  }) {
    return BillingRepository.instance.syncRetailerBillsFromCloud(
      phone: phone,
      partyName: partyName,
    );
  }

  Future<ServiceResponse<SalesBillEntity>> createAndSaveBill({
    required String partyName,
    required String deviceUuid,
    required String salesmanName,
    required List<BillItemEntity> cartItems,
  }) async {
    return serviceObserver(() async {
      return BillingRepository.instance.saveBill(
        partyName: partyName,
        deviceUuid: deviceUuid,
        salesmanName: salesmanName,
        cartItems: cartItems,
      );
    });
  }

  Future<ServiceResponse<SalesBillEntity>> updateBill({
    required SalesBillEntity updatedBill,
  }) async {
    return serviceObserver(() async {
      return BillingRepository.instance.updateBill(updatedBill: updatedBill);
    });
  }

  Future<ServiceResponse<bool>> deleteBill({
    required String billNo,
    required String phone,
    required String partyName,
  }) async {
    return serviceObserver(() async {
      return BillingRepository.instance.deleteBill(
        billNo: billNo,
        phone: phone,
        partyName: partyName,
      );
    });
  }

  String generateMargCsvContent({
    String phone = '',
    String partyName = '',
  }) {
    return BillingRepository.instance.generateMargExportCsv(
      phone: phone,
      partyName: partyName,
    );
  }
}
