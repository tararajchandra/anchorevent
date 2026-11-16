import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';

class ScannedItemStepperCard extends StatelessWidget {
  final String brand;
  final String itemCode;
  final String productTitle;
  final String categoryAndStock;
  final String rateFormatted;
  final String mrpFormatted;
  final int currentQty;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onAddToCart;

  const ScannedItemStepperCard({
    super.key,
    required this.brand,
    required this.itemCode,
    required this.productTitle,
    required this.categoryAndStock,
    required this.rateFormatted,
    required this.mrpFormatted,
    required this.currentQty,
    required this.onQtyChanged,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: GraphicsColorConsts.surfaceSlate,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: GraphicsColorConsts.primaryTeal),
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
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: GraphicsColorConsts.cardSlate,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            brand,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: GraphicsColorConsts.primaryTeal,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'CODE: $itemCode',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: GraphicsColorConsts.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      productTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: GraphicsColorConsts.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      categoryAndStock,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: GraphicsColorConsts.accentEmerald,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    rateFormatted,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: GraphicsColorConsts.primaryTeal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'MRP: $mrpFormatted',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: GraphicsColorConsts.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      if (currentQty > 1) {
                        onQtyChanged(currentQty - 1);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$currentQty Pairs',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: GraphicsColorConsts.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => onQtyChanged(currentQty + 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GraphicsColorConsts.primaryTeal,
                  foregroundColor: GraphicsColorConsts.backgroundDark,
                ),
                onPressed: onAddToCart,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18.0),
                label: Text(
                  'Add Pairs',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: GraphicsColorConsts.backgroundDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              _buildDozenChip(context, label: '+6 (Half Dz)', pairs: 6),
              const SizedBox(width: 8.0),
              _buildDozenChip(context, label: '+12 (1 Dozen)', pairs: 12),
              const SizedBox(width: 8.0),
              _buildDozenChip(context, label: '+24 (2 Dozen)', pairs: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDozenChip(
    BuildContext context, {
    required String label,
    required int pairs,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentQty == pairs;
    return Expanded(
      child: InkWell(
        onTap: () => onQtyChanged(pairs),
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: GraphicsColorConsts.cardSlate,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isSelected
                  ? GraphicsColorConsts.primaryTeal
                  : GraphicsColorConsts.borderSlate,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? GraphicsColorConsts.primaryTeal
                  : GraphicsColorConsts.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
