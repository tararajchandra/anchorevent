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
    final rawItems = json['items'];
    final parsedItems = <BillItemEntity>[];
    if (rawItems is List<dynamic>) {
      for (final raw in rawItems) {
        if (raw is Map<String, dynamic>) {
          parsedItems.add(BillItemEntity.fromJson(raw));
        }
      }
    }
    return SalesBillEntity(
      billNo: json['billNo'] as String? ?? '',
      billDate: json['billDate'] as String? ?? '',
      createdTime: json['createdTime'] as String? ?? '',
      partyName: json['partyName'] as String? ?? '',
      deviceUuid: json['deviceUuid'] as String? ?? '',
      salesmanName: json['salesmanName'] as String? ?? 'Salesman',
      items: parsedItems,
    );
  }
}
