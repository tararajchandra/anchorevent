enum SchemeRewardTypeEnum {
  discountPercent('Discount %'),
  giftItem('Gift / Prize'),
  cashback('Cashback Rebate');

  const SchemeRewardTypeEnum(this.label);

  final String label;

  static SchemeRewardTypeEnum fromString(String? value) {
    if (value == null || value.isEmpty) {
      return SchemeRewardTypeEnum.giftItem;
    }
    final normalized = value.toLowerCase().trim();
    if (normalized.contains('discount')) {
      return SchemeRewardTypeEnum.discountPercent;
    } else if (normalized.contains('cash')) {
      return SchemeRewardTypeEnum.cashback;
    }
    return SchemeRewardTypeEnum.giftItem;
  }
}
