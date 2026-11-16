import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';

class CartItemRowCard extends StatelessWidget {
  final String productName;
  final String itemCodeAndRate;
  final String lineTotalFormatted;
  final VoidCallback onRemove;

  const CartItemRowCard({
    super.key,
    required this.productName,
    required this.itemCodeAndRate,
    required this.lineTotalFormatted,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: GraphicsColorConsts.surfaceSlate,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: GraphicsColorConsts.borderSlate),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  productName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: GraphicsColorConsts.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  itemCodeAndRate,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: GraphicsColorConsts.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Text(
                lineTotalFormatted,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: GraphicsColorConsts.primaryTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18.0,
                  color: GraphicsColorConsts.dangerRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
