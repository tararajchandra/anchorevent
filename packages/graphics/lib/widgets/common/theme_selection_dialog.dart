import 'package:flutter/material.dart';

import '../../graphics_consts/app_theme_mode_enum.dart';

class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({
    required this.currentTheme,
    super.key,
  });

  final AppThemeModeEnum currentTheme;

  static Future<AppThemeModeEnum?> show(
    BuildContext context, {
    required AppThemeModeEnum currentTheme,
  }) {
    return showDialog<AppThemeModeEnum>(
      context: context,
      builder: (ctx) => ThemeSelectionDialog(currentTheme: currentTheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: theme.dividerColor),
      ),
      title: Text(
        'Select App Theme',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppThemeModeEnum.values.map((mode) {
          final isSelected = mode == currentTheme;
          final iconData = switch (mode) {
            AppThemeModeEnum.cleanLight => Icons.light_mode_rounded,
            AppThemeModeEnum.executiveDark => Icons.dark_mode_rounded,
            AppThemeModeEnum.footwearCrimson => Icons.palette_rounded,
          };

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                  color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              leading: Icon(
                iconData,
                color: isSelected ? theme.colorScheme.primary : theme.iconTheme.color,
              ),
              title: Text(
                mode.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? theme.colorScheme.primary : null,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(mode),
            ),
          );
        }).toList(),
      ),
    );
  }
}
