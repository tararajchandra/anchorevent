enum BalanceTypeEnum {
  dr('DR'),
  cr('CR');

  final String code;

  const BalanceTypeEnum(this.code);

  static BalanceTypeEnum fromString(String? raw) {
    final cleaned = (raw ?? '').trim().toUpperCase();
    if (cleaned == 'CR') {
      return BalanceTypeEnum.cr;
    }
    return BalanceTypeEnum.dr;
  }
}
