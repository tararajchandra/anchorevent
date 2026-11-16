import 'package:flutter/material.dart';

import 'app_theme_mode_enum.dart';
import 'graphics_color_consts.dart';

class GraphicsTheme {
  GraphicsTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: GraphicsColorConsts.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: GraphicsColorConsts.primaryRoyalBlue,
        secondary: GraphicsColorConsts.accentRoyalBlue,
        surface: GraphicsColorConsts.surfaceLight,
        error: GraphicsColorConsts.dangerRed,
      ),
      cardColor: GraphicsColorConsts.cardLight,
      dividerColor: GraphicsColorConsts.borderLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: GraphicsColorConsts.primaryRoyalBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: GraphicsColorConsts.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: GraphicsColorConsts.primaryTeal,
        secondary: GraphicsColorConsts.accentEmerald,
        surface: GraphicsColorConsts.surfaceSlate,
        error: GraphicsColorConsts.dangerRed,
      ),
      cardColor: GraphicsColorConsts.surfaceSlate,
      dividerColor: GraphicsColorConsts.borderSlate,
      appBarTheme: const AppBarTheme(
        backgroundColor: GraphicsColorConsts.surfaceSlate,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get crimsonTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: GraphicsColorConsts.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: GraphicsColorConsts.primaryCrimson,
        secondary: GraphicsColorConsts.accentCrimson,
        surface: GraphicsColorConsts.surfaceLight,
        error: GraphicsColorConsts.dangerRed,
      ),
      cardColor: GraphicsColorConsts.cardLight,
      dividerColor: GraphicsColorConsts.borderCrimson,
      appBarTheme: const AppBarTheme(
        backgroundColor: GraphicsColorConsts.primaryCrimson,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData getTheme(AppThemeModeEnum mode) {
    return switch (mode) {
      AppThemeModeEnum.cleanLight => lightTheme,
      AppThemeModeEnum.executiveDark => darkTheme,
      AppThemeModeEnum.footwearCrimson => crimsonTheme,
    };
  }
}
