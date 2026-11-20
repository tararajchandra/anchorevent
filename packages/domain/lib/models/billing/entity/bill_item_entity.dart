import '../../item/entity/article_qr_mapping_entity.dart';
import '../../item/entity/footwear_item_entity.dart';

class BillItemEntity {
  final String itemCode;
  final String barcode;
  final String productName;
  final String company;
  final String unit;
  final int qtyPairs;
  final double rate;
  final double mrp;

  const BillItemEntity({
    required this.itemCode,
    required this.barcode,
    required this.productName,
    required this.company,
    required this.unit,
    required this.qtyPairs,
    required this.rate,
    required this.mrp,
  });

  double get lineAmount => qtyPairs * rate;

  factory BillItemEntity.fromFootwearItem({
    required FootwearItemEntity item,
    required int qtyPairs,
  }) {
    return BillItemEntity(
      itemCode: item.code,
      barcode: item.barcode,
      productName: item.product,
      company: item.company,
      unit: item.unit,
      qtyPairs: qtyPairs,
      rate: item.effectiveRate,
      mrp: item.mrp,
    );
  }

  factory BillItemEntity.fromArticleVariant({
    required ArticleQrVariantEntity variant,
    required int qtyPairs,
  }) {
    final effectiveRate = variant.rate > 0 ? variant.rate : variant.mrp;
    final displayName = variant.productName.isNotEmpty
        ? variant.productName
        : '${variant.color} ${variant.size}';
    return BillItemEntity(
      itemCode: variant.itemCode,
      barcode: variant.itemCode,
      productName: displayName,
      company: variant.company,
      unit: 'PAIR',
      qtyPairs: qtyPairs,
      rate: effectiveRate,
      mrp: variant.mrp > 0 ? variant.mrp : effectiveRate,
    );
  }

  BillItemEntity copyWithQty(int updatedQty) {
    return BillItemEntity(
      itemCode: itemCode,
      barcode: barcode,
      productName: productName,
      company: company,
      unit: unit,
      qtyPairs: updatedQty,
      rate: rate,
      mrp: mrp,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'itemCode': itemCode,
      'barcode': barcode,
      'productName': productName,
      'company': company,
      'unit': unit,
      'qtyPairs': qtyPairs,
      'rate': rate,
      'mrp': mrp,
    };
  }

  factory BillItemEntity.fromJson(Map<String, dynamic> json) {
    return BillItemEntity(
      itemCode: json['itemCode'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      company: json['company'] as String? ?? '',
      unit: json['unit'] as String? ?? 'PAIR',
      qtyPairs: (json['qtyPairs'] as num? ?? 1).toInt(),
      rate: (json['rate'] as num? ?? 0.0).toDouble(),
      mrp: (json['mrp'] as num? ?? 0.0).toDouble(),
    );
  }
}
