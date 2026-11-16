import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';

class RecentBillRowCard extends StatelessWidget {
  const RecentBillRowCard({
    required this.partyName,
    required this.billNo,
    required this.subtitleText,
    required this.amountText,
    super.key,
  });

  final String partyName;
  final String billNo;
  final String subtitleText;
  final String amountText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? GraphicsColorConsts.surfaceSlate : GraphicsColorConsts.surfaceLight,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.dividerColor),
        boxShadow: <BoxShadow>[
          if (!isDark)
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 6.0,
              offset: const Offset(0.0, 2.0),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        partyName,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? GraphicsColorConsts.cardSlate
                            : theme.colorScheme.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        billNo,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitleText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            amountText,
            style: theme.textTheme.titleSmall?.copyWith(
              color: GraphicsColorConsts.warningAmber,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
