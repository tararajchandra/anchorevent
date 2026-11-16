import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';

class PrimaryGradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const PrimaryGradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[
              GraphicsColorConsts.primaryTeal,
              GraphicsColorConsts.accentEmerald,
            ],
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: GraphicsColorConsts.backgroundDark,
              size: 20.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: GraphicsColorConsts.backgroundDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
