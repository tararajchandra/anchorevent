import 'package:flutter/services.dart' show rootBundle;

class CsvFileService {
  CsvFileService._();

  static final CsvFileService instance = CsvFileService._();

  Future<String> loadAssetCsv(String assetPath) async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (_) {
      return '';
    }
  }

  List<List<String>> parseCsvLines(String rawCsv) {
    final rows = <List<String>>[];
    final lines = rawCsv.split(RegExp(r'\r?\n'));
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      rows.add(_parseSingleLine(trimmed));
    }
    return rows;
  }

  List<String> _parseSingleLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        fields.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    fields.add(buffer.toString().trim());
    return fields;
  }
}
