import 'bill_item_entity.dart';

class SalesBillEntity {
  final String billNo;
  final String billDate;
  final String createdTime;
  final String partyName;
  final String deviceUuid;
  final String salesmanName;
  final List<BillItemEntity> items;

  const SalesBillEntity({
    required this.billNo,
    required this.billDate,
    required this.createdTime,
    required this.partyName,
    required this.deviceUuid,
    required this.salesmanName,
    required this.items,
  });

  int get totalPairs {
    var sum = 0;
    for (final item in items) {
      sum += item.qtyPairs;
    }
    return sum;
  }

  double get totalAmount {
    var sum = 0.0;
    for (final item in items) {
      sum += item.lineAmount;
    }
    return sum;
  }

  String get brandsSummary {
    final brands = <String>{};
    for (final item in items) {
      if (item.company.isNotEmpty) {
        brands.add(item.company);
      }
    }
    return brands.isEmpty ? 'Footwear' : brands.take(2).join(' & ');
  }

  static String normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  String get retailerPhone {
    final trimmedUuid = deviceUuid.trim();
    if (trimmedUuid.toUpperCase().startsWith('PHONE-')) {
      final fromUuid = normalizePhone(trimmedUuid.substring(6));
      if (fromUuid.length == 10) {
        return fromUuid;
      }
    }
    final fromSalesman = normalizePhone(salesmanName);
    if (fromSalesman.length == 10) {
      return fromSalesman;
    }
    return '';
  }

  bool belongsToRetailer({
    required String phone,
    required String partyName,
  }) {
    final targetPhone = normalizePhone(phone);
    final billPhone = retailerPhone;
    if (targetPhone.length == 10 && billPhone.length == 10) {
      return targetPhone == billPhone;
    }
    final targetParty = partyName.trim().toUpperCase();
    final billParty = this.partyName.trim().toUpperCase();
    if (targetParty.isNotEmpty && billParty.isNotEmpty) {
      return targetParty == billParty;
    }
    return false;
  }

  SalesBillEntity copyWithItems(List<BillItemEntity> updatedItems) {
    return SalesBillEntity(
      billNo: billNo,
      billDate: billDate,
      createdTime: createdTime,
      partyName: partyName,
      deviceUuid: deviceUuid,
      salesmanName: salesmanName,
      items: List<BillItemEntity>.unmodifiable(updatedItems),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'billNo': billNo,
      'billDate': billDate,
      'createdTime': createdTime,
      'partyName': partyName,
      'deviceUuid': deviceUuid,
      'salesmanName': salesmanName,
      'items': items.map((BillItemEntity item) => item.toJson()).toList(),
    };
  }

  factory SalesBillEntity.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['bill_items'];
    final parsedItems = <BillItemEntity>[];
    if (rawItems is List<dynamic>) {
      for (final raw in rawItems) {
        if (raw is Map<String, dynamic>) {
          parsedItems.add(BillItemEntity.fromJson(raw));
        }
      }
    }
    return SalesBillEntity(
      billNo: (json['billNo'] ?? json['bill_no'] ?? '').toString(),
      billDate: (json['billDate'] ?? json['bill_date'] ?? '').toString(),
      createdTime:
          (json['createdTime'] ?? json['created_time'] ?? '').toString(),
      partyName: (json['partyName'] ?? json['party_name'] ?? '').toString(),
      deviceUuid: (json['deviceUuid'] ?? json['device_uuid'] ?? '').toString(),
      salesmanName:
          (json['salesmanName'] ?? json['salesman_name'] ?? 'Salesman')
              .toString(),
      items: parsedItems,
    );
  }
}
