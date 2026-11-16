enum AppThemeModeEnum {
  cleanLight('Clean Light', 'light'),
  executiveDark('Executive Dark', 'dark'),
  footwearCrimson('Footwear Crimson', 'crimson');

  const AppThemeModeEnum(this.label, this.storageValue);

  final String label;
  final String storageValue;

  static AppThemeModeEnum fromStorageValue(String? value) {
    if (value == null || value.isEmpty) {
      return AppThemeModeEnum.cleanLight;
    }
    for (final mode in AppThemeModeEnum.values) {
      if (mode.storageValue == value) {
        return mode;
      }
    }
    return AppThemeModeEnum.cleanLight;
  }
}
