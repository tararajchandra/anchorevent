import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    required this.title,
    required this.subtitle,
    required this.salesmanBadge,
    super.key,
    this.onLicenseTap,
    this.onThemeTap,
    this.themeIcon = Icons.palette_outlined,
  });

  final String title;
  final String subtitle;
  final String salesmanBadge;
  final VoidCallback? onLicenseTap;
  final VoidCallback? onThemeTap;
  final IconData themeIcon;

  @override
  Size get preferredSize => const Size.fromHeight(68.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarBg = theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
    final fgColor = theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;

    return AppBar(
      backgroundColor: appBarBg,
      elevation: 0,
      titleSpacing: 16.0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        if (onThemeTap != null)
          IconButton(
            icon: Icon(themeIcon, size: 20.0, color: fgColor),
            tooltip: 'Switch Theme',
            onPressed: onThemeTap,
          ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: InkWell(
            onTap: onLicenseTap,
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: const BoxDecoration(
                      color: GraphicsColorConsts.accentEmerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    salesmanBadge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
