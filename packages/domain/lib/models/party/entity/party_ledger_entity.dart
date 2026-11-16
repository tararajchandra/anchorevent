import '../../../utils/enums/balance_type_enum.dart';
import '../../../utils/enums/route_day_enum.dart';

class PartyLedgerEntity {
  final String partyName;
  final RouteDayEnum routeDay;
  final String address;
  final String phone;
  final double closingBalance;
  final BalanceTypeEnum balanceType;

  const PartyLedgerEntity({
    required this.partyName,
    required this.routeDay,
    required this.address,
    required this.phone,
    required this.closingBalance,
    required this.balanceType,
  });

  String get formattedBalance =>
      '₹${closingBalance.toStringAsFixed(2)} ${balanceType.code}';

  String get initials {
    final cleaned = partyName.trim();
    if (cleaned.isEmpty) {
      return 'P';
    }
    return cleaned.substring(0, cleaned.length >= 2 ? 2 : 1).toUpperCase();
  }
}
