class FootwearItemEntity {
  final String code;
  final String barcode;
  final String product;
  final String unit;
  final String company;
  final String group;
  final String category;
  final String hsn;
  final double gst;
  final int closingStock;
  final double mrp;
  final double rateA;

  const FootwearItemEntity({
    required this.code,
    required this.barcode,
    required this.product,
    required this.unit,
    required this.company,
    required this.group,
    required this.category,
    required this.hsn,
    required this.gst,
    required this.closingStock,
    required this.mrp,
    required this.rateA,
  });

  double get effectiveRate => rateA > 0 ? rateA : mrp;

  FootwearItemEntity copyWithBarcode(String newBarcode) {
    return FootwearItemEntity(
      code: code,
      barcode: newBarcode,
      product: product,
      unit: unit,
      company: company,
      group: group,
      category: category,
      hsn: hsn,
      gst: gst,
      closingStock: closingStock,
      mrp: mrp,
      rateA: rateA,
    );
  }
}
