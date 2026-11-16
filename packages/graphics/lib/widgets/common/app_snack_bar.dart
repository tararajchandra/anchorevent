import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';

class AppSnackBar {
  AppSnackBar._();

  static void showSuccess(BuildContext context, String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: GraphicsColorConsts.accentEmerald,
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: GraphicsColorConsts.backgroundDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
  }
}
