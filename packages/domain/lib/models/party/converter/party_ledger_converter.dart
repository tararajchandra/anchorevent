import '../../../utils/enums/balance_type_enum.dart';
import '../../../utils/enums/route_day_enum.dart';
import '../entity/party_ledger_entity.dart';

class PartyLedgerConverter {
  PartyLedgerConverter._();

  static List<PartyLedgerEntity> fromCsvRows(List<List<String>> rows) {
    final parties = <PartyLedgerEntity>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) {
        continue;
      }
      final name = row[0].trim();
      if (name.isEmpty) {
        continue;
      }
      final routeStr = row.length > 1 ? row[1].trim() : '';
      final address = row.length > 2 ? row[2].trim() : '';
      final phone = row.length > 3 ? row[3].trim() : '';
      final balStr = row.length > 4 ? row[4].trim() : '0';
      final typeStr = row.length > 5 ? row[5].trim() : 'DR';

      parties.add(
        PartyLedgerEntity(
          partyName: name,
          routeDay: RouteDayEnum.fromString(routeStr),
          address: address.isEmpty ? 'Hooghly' : address,
          phone: phone,
          closingBalance: double.tryParse(balStr) ?? 0.0,
          balanceType: BalanceTypeEnum.fromString(typeStr),
        ),
      );
    }
    return parties;
  }
}
