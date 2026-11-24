import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';
import '../../graphics_consts/graphics_string_consts.dart';

class CartItemRowCard extends StatelessWidget {
  final String productName;
  final String itemCodeAndRate;
  final String lineTotalFormatted;
  final String? mrpFormatted;
  final int? qtyPairs;
  final ValueChanged<int>? onQtyChanged;
  final VoidCallback onRemove;

  const CartItemRowCard({
    super.key,
    required this.productName,
    required this.itemCodeAndRate,
    required this.lineTotalFormatted,
    this.mrpFormatted,
    this.qtyPairs,
    this.onQtyChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentQty = qtyPairs;
    final qtyCallback = onQtyChanged;
    final mrpText = mrpFormatted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark
            ? GraphicsColorConsts.surfaceSlate
            : GraphicsColorConsts.cardLight,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        if (mrpText != null && mrpText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: GraphicsColorConsts.accentCrimson
                                  .withValues(alpha: isDark ? 0.22 : 0.10),
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: GraphicsColorConsts.accentCrimson
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                            child: Text(
                              GraphicsStringConsts.mrpBadgeText(mrpText),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? GraphicsColorConsts.dangerRed
                                    : GraphicsColorConsts.accentCrimson,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        Text(
                          itemCodeAndRate,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: GraphicsColorConsts.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                onPressed: onRemove,
                tooltip: GraphicsStringConsts.deleteOrderLabel,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minWidth: 32.0,
                  minHeight: 32.0,
                ),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20.0,
                  color: GraphicsColorConsts.dangerRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (currentQty != null && qtyCallback != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _QtyStepButton(
                      icon: Icons.remove_rounded,
                      onPressed: () => qtyCallback(currentQty - 1),
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 44.0),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        '$currentQty Prs',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _QtyStepButton(
                      icon: Icons.add_rounded,
                      onPressed: () => qtyCallback(currentQty + 1),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              Text(
                lineTotalFormatted,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: GraphicsColorConsts.primaryTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyStepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QtyStepButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 28.0,
        height: 28.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Icon(icon, size: 16.0),
      ),
    );
  }
}
