import '../../../utils/date_time_utils.dart';
import '../entity/bill_item_entity.dart';
import '../entity/sales_bill_entity.dart';

class SalesBillConverter {
  SalesBillConverter._();

  static const String margCsvHeader =
      'Bill_No,Bill_Date,Party_Name,Item_Code,Item_Name,Qty,Unit,Rate,MRP,Amount,Salesman';

  static String _buildRetailerTag({
    required String salesmanName,
    required String deviceUuid,
    required String partyName,
  }) {
    final salesmanDigits = salesmanName.replaceAll(RegExp(r'\D'), '');
    if (salesmanDigits.length >= 4) {
      return salesmanDigits.substring(salesmanDigits.length - 4);
    }
    final uuidDigits = deviceUuid.toUpperCase().startsWith('PHONE-')
        ? deviceUuid.substring(6).replaceAll(RegExp(r'\D'), '')
        : '';
    if (uuidDigits.length >= 4) {
      return uuidDigits.substring(uuidDigits.length - 4);
    }
    final alnum =
        partyName.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (alnum.length >= 4) {
      return alnum.substring(0, 4);
    }
    return alnum.padRight(4, 'X');
  }

  static SalesBillEntity createNewBill({
    required int sequenceNumber,
    required String partyName,
    required String deviceUuid,
    required String salesmanName,
    required List<BillItemEntity> cartItems,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    final paddedSeq = sequenceNumber.toString().padLeft(3, '0');
    final retailerTag = _buildRetailerTag(
      salesmanName: salesmanName,
      deviceUuid: deviceUuid,
      partyName: partyName,
    );
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    final timeTag = '$hh$mm$ss';

    return SalesBillEntity(
      billNo: 'ORD-$retailerTag-$paddedSeq-$timeTag',
      billDate: DateTimeUtils.formatMargDate(now),
      createdTime: DateTimeUtils.formatTimeShort(now),
      partyName: partyName,
      deviceUuid: deviceUuid,
      salesmanName: salesmanName,
      items: List<BillItemEntity>.from(cartItems),
    );
  }

  static String toMargImportCsv(List<SalesBillEntity> bills) {
    final buffer = StringBuffer()..writeln(margCsvHeader);
    for (final bill in bills) {
      for (final item in bill.items) {
        final safeParty = _escapeCsvField(bill.partyName);
        final safeProduct = _escapeCsvField(item.productName);
        final safeSalesman = _escapeCsvField(bill.salesmanName);
        final rateStr = item.rate.toStringAsFixed(2);
        final mrpStr = item.mrp.toStringAsFixed(2);
        final amtStr = item.lineAmount.toStringAsFixed(2);

        buffer.writeln(
          '${bill.billNo},${bill.billDate},$safeParty,${item.itemCode},'
          '$safeProduct,${item.qtyPairs},${item.unit},$rateStr,$mrpStr,'
          '$amtStr,$safeSalesman',
        );
      }
    }
    return buffer.toString().trimRight();
  }

  static String _escapeCsvField(String value) {
    if (value.contains(',') || value.contains('"')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}
