import '../entity/footwear_item_entity.dart';

class FootwearItemConverter {
  FootwearItemConverter._();

  static List<FootwearItemEntity> fromCsvRows(
    List<List<String>> rows,
    Map<String, String> barcodeLookupByItemCode,
  ) {
    final items = <FootwearItemEntity>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 18) {
        continue;
      }
      final code = row[0].trim();
      final product = row[2].trim();
      if (code.isEmpty || product.isEmpty) {
        continue;
      }
      final csvBarcode = row[1].trim();
      final mappedBarcode = barcodeLookupByItemCode[code] ?? csvBarcode;

      items.add(
        FootwearItemEntity(
          code: code,
          barcode: mappedBarcode,
          product: product,
          unit: row[4].trim().isEmpty ? 'PAIR' : row[4].trim(),
          company: row[5].trim().isEmpty ? 'GENERAL' : row[5].trim(),
          group: row[6].trim(),
          category: row[7].trim(),
          hsn: row[9].trim().isEmpty ? '6402' : row[9].trim(),
          gst: double.tryParse(row[10].trim()) ?? 5.0,
          closingStock: (double.tryParse(row[13].trim()) ?? 0).round(),
          mrp: double.tryParse(row[15].trim()) ?? 0.0,
          rateA: double.tryParse(row[17].trim()) ?? 0.0,
        ),
      );
    }
    return items;
  }
}
