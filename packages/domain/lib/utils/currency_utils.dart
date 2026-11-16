class CurrencyUtils {
  CurrencyUtils._();

  static String formatInr(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  static String formatInrCompact(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  static String formatPairsCount(int pairs) {
    return '$pairs Pairs';
  }
}
