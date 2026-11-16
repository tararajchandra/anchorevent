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

  String generateMargCsvContent() {
    return BillingRepository.instance.generateMargExportCsv();
  }
}
