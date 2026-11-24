import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';
import '../../graphics_consts/graphics_string_consts.dart';

class OrdersSummaryHeaderCard extends StatelessWidget {
  final int ordersCount;
  final int totalPairs;
  final String totalValueFormatted;
  final String schemeBannerText;
  final double schemeProgressFraction;
  final bool isSchemeAchieved;
  final VoidCallback? onSchemeTap;

  const OrdersSummaryHeaderCard({
    super.key,
    required this.ordersCount,
    required this.totalPairs,
    required this.totalValueFormatted,
    required this.schemeBannerText,
    required this.schemeProgressFraction,
    required this.isSchemeAchieved,
    this.onSchemeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final schemeAccent = isSchemeAchieved
        ? GraphicsColorConsts.accentEmerald
        : GraphicsColorConsts.warningAmber;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.dividerColor),
        boxShadow: <BoxShadow>[
          if (!isDark)
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12.0,
              offset: const Offset(0.0, 4.0),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                GraphicsStringConsts.totalBookingsSummaryTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: GraphicsColorConsts.accentEmerald
                      .withAlpha(isDark ? 40 : 22),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: GraphicsColorConsts.accentEmerald),
                ),
                child: Text(
                  GraphicsStringConsts.ordersConfirmedBadge(ordersCount),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: GraphicsColorConsts.accentEmerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryMetricTile(
                  icon: Icons.inventory_2_outlined,
                  label: GraphicsStringConsts.totalPairsLabel,
                  value: '$totalPairs Prs',
                  accentColor: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _SummaryMetricTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: GraphicsStringConsts.bookingValueLabel,
                  value: totalValueFormatted,
                  accentColor: GraphicsColorConsts.warningAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          InkWell(
            onTap: onSchemeTap,
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: schemeAccent.withAlpha(isDark ? 30 : 18),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: schemeAccent.withValues(alpha: 0.65),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        isSchemeAchieved
                            ? Icons.workspace_premium_rounded
                            : Icons.stars_rounded,
                        size: 18.0,
                        color: schemeAccent,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          schemeBannerText,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isSchemeAchieved
                                ? GraphicsColorConsts.accentEmerald
                                : (isDark
                                    ? Colors.amber.shade200
                                    : Colors.amber.shade900),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18.0,
                        color: schemeAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: LinearProgressIndicator(
                      value: schemeProgressFraction.clamp(0.0, 1.0),
                      minHeight: 6.0,
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(schemeAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  const _SummaryMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark
            ? GraphicsColorConsts.cardSlate
            : GraphicsColorConsts.backgroundLight,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 14.0, color: accentColor),
              const SizedBox(width: 5.0),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
