import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';
import '../../graphics_consts/graphics_string_consts.dart';

class ShopSummaryHeaderCard extends StatelessWidget {
  const ShopSummaryHeaderCard({
    required this.shopName,
    required this.licenseSubtitle,
    required this.billCount,
    required this.totalPairs,
    required this.totalSalesFormatted,
    super.key,
  });

  final String shopName;
  final String licenseSubtitle;
  final int billCount;
  final int totalPairs;
  final String totalSalesFormatted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? GraphicsColorConsts.surfaceSlate : GraphicsColorConsts.surfaceLight,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.dividerColor),
        boxShadow: <BoxShadow>[
          if (!isDark)
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10.0,
              offset: const Offset(0.0, 3.0),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      shopName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      licenseSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(isDark ? 50 : 25),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: theme.colorScheme.primary),
                ),
                child: Text(
                  'Event Ready',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildStatTile(
                  context,
                  label: GraphicsStringConsts.todaysOrdersStatLabel,
                  value: billCount.toString(),
                  valueColor: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _buildStatTile(
                  context,
                  label: 'Total Pairs',
                  value: totalPairs.toString(),
                  valueColor: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _buildStatTile(
                  context,
                  label: 'Booking Value',
                  value: totalSalesFormatted,
                  valueColor: GraphicsColorConsts.warningAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tileBg = isDark
        ? GraphicsColorConsts.cardSlate
        : GraphicsColorConsts.backgroundLight;

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withAlpha(160),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
