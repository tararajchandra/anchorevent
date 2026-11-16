enum RouteDayEnum {
  all('ALL', 'All Routes'),
  saturday('SATURDAY', 'Saturday'),
  sunday('SUNDAY', 'Sunday'),
  monday('MONDAY', 'Monday'),
  tuesday('TUESDAY', 'Tuesday'),
  wednesday('WEDNESDAY', 'Wednesday'),
  thursday('THURSDAY', 'Thursday'),
  friday('FRIDAY', 'Friday');

  final String rawValue;
  final String displayLabel;

  const RouteDayEnum(this.rawValue, this.displayLabel);

  static RouteDayEnum fromString(String? raw) {
    final cleaned = (raw ?? '').trim().toUpperCase();
    for (final value in RouteDayEnum.values) {
      if (value.rawValue == cleaned) {
        return value;
      }
    }
    return RouteDayEnum.all;
  }
}
