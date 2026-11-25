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

  static List<FootwearItemEntity> fromCloudRows(
    List<Map<String, dynamic>> rows,
    Map<String, String> barcodeLookupByItemCode,
  ) {
    final items = <FootwearItemEntity>[];
    for (final row in rows) {
      final code = (row['code']?.toString() ?? '').trim();
      final product = (row['product']?.toString() ?? '').trim();
      if (code.isEmpty || product.isEmpty) {
        continue;
      }
      final cloudBarcode = (row['barcode']?.toString() ?? '').trim();
      final mappedBarcode = barcodeLookupByItemCode[code] ?? cloudBarcode;
      final unit = (row['unit']?.toString() ?? '').trim();
      final company = (row['company']?.toString() ?? '').trim();
      final group =
          (row['item_group']?.toString() ?? row['group']?.toString() ?? '')
              .trim();
      final hsn = (row['hsn']?.toString() ?? '').trim();

      items.add(
        FootwearItemEntity(
          code: code,
          barcode: mappedBarcode,
          product: product,
          unit: unit.isEmpty ? 'PAIR' : unit,
          company: company.isEmpty ? 'GENERAL' : company,
          group: group,
          category: (row['category']?.toString() ?? '').trim(),
          hsn: hsn.isEmpty ? '6402' : hsn,
          gst: double.tryParse(row['gst']?.toString() ?? '') ?? 5.0,
          closingStock:
              (double.tryParse(row['closing_stock']?.toString() ?? '') ?? 0)
                  .round(),
          mrp: double.tryParse(row['mrp']?.toString() ?? '') ?? 0.0,
          rateA: double.tryParse(row['ratea']?.toString() ?? '') ?? 0.0,
        ),
      );
    }
    return items;
  }
}
